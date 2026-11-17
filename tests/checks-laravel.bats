#!/usr/bin/env bats
# Gate checks added after the Star Wars run: each test reproduces a defect
# that run shipped without noticing.
load helpers

setup() { make_project; make_fake_laravel; }
teardown() { cleanup_project; }

THROTTLED='["api","Illuminate\\Routing\\Middleware\\ThrottleRequests:api"]'

@test "baseline fake project passes the api-routes and seeders checks" {
  run "$CHECKS"
  [ "$status" -eq 0 ]
  [[ "$output" == *"api-routes"*"pass"* ]]
}

@test "routes/api.php not loaded (install:api never run) fails" {
  set_routes ''
  run "$CHECKS"
  [ "$status" -ne 0 ]
  [[ "$output" == *"install:api"* ]]
}

@test "missing routes/api.php fails unless gate.api is off" {
  rm routes/api.php
  run "$CHECKS"
  [ "$status" -ne 0 ]
  [[ "$output" == *"routes/api.php not found"* ]]
  jq '.gate.api = "off"' factory/config.json > c && mv c factory/config.json
  run "$CHECKS"
  [ "$status" -eq 0 ]
}

@test "unthrottled api route fails" {
  set_routes '[{"method":"GET|HEAD","uri":"api/v1/films","middleware":["api"]}]'
  run "$CHECKS"
  [ "$status" -ne 0 ]
  [[ "$output" == *"not rate limited: GET|HEAD /api/v1/films"* ]]
}

@test "throttle alias in middleware counts as rate limited" {
  set_routes '[{"method":"GET|HEAD","uri":"api/v1/films","middleware":["api","throttle:60,1"]}]'
  run "$CHECKS"
  [ "$status" -eq 0 ]
}

@test "api route with no test referencing it fails" {
  set_routes "[{\"method\":\"GET|HEAD\",\"uri\":\"api/v1/films\",\"middleware\":$THROTTLED},
               {\"method\":\"GET|HEAD\",\"uri\":\"api/v1/characters/{character}\",\"middleware\":$THROTTLED}]"
  run "$CHECKS"
  [ "$status" -ne 0 ]
  [[ "$output" == *"no test references /api/v1/characters"* ]]
}

@test "api_route_ignore exempts a route" {
  set_routes "[{\"method\":\"GET|HEAD\",\"uri\":\"api/user\",\"middleware\":[\"api\"]},
               {\"method\":\"GET|HEAD\",\"uri\":\"api/v1/films\",\"middleware\":$THROTTLED}]"
  jq '.gate.api_route_ignore = ["api/user"]' factory/config.json > c && mv c factory/config.json
  run "$CHECKS"
  [ "$status" -eq 0 ]
}

@test "seeder not called from DatabaseSeeder fails" {
  mkdir -p database/seeders
  echo '<?php class DatabaseSeeder { function run() { User::factory()->create(); } }' > database/seeders/DatabaseSeeder.php
  echo '<?php class StarWarsSeeder {}' > database/seeders/StarWarsSeeder.php
  run "$CHECKS"
  [ "$status" -ne 0 ]
  [[ "$output" == *"seeder StarWarsSeeder is never called"* ]]

  echo '<?php class DatabaseSeeder { function run() { $this->call(StarWarsSeeder::class); } }' > database/seeders/DatabaseSeeder.php
  run "$CHECKS"
  [ "$status" -eq 0 ]
}

@test "seeders_ignore exempts an on-demand seeder" {
  mkdir -p database/seeders
  echo '<?php class DatabaseSeeder {}' > database/seeders/DatabaseSeeder.php
  echo '<?php class DemoSeeder {}' > database/seeders/DemoSeeder.php
  jq '.gate.seeders_ignore = ["DemoSeeder"]' factory/config.json > c && mv c factory/config.json
  run "$CHECKS"
  [ "$status" -eq 0 ]
}

@test "a test that uses the route name counts as a reference" {
  set_routes "[{\"method\":\"GET|HEAD\",\"uri\":\"api/v1/films\",\"middleware\":$THROTTLED},
               {\"method\":\"GET|HEAD\",\"uri\":\"api/v1/characters/{character}\",\"name\":\"characters.show\",\"middleware\":$THROTTLED}]"
  run "$CHECKS"
  [ "$status" -ne 0 ]
  [[ "$output" == *"name characters.show"* ]]
  echo "<?php it('shows', fn () => \$this->getJson(route('characters.show', 1))->assertOk());" > tests/Feature/CharactersTest.php
  run "$CHECKS"
  [ "$status" -eq 0 ]
}

@test "a FACTORY_GATE_ONLY run is marked partial in the report" {
  FACTORY_GATE_ONLY="pint" FACTORY_GATE_REPORT="$PROJECT/r.json" run "$CHECKS"
  [ "$status" -eq 0 ]
  run jq -r '.partial' "$PROJECT/r.json"
  [ "$output" = "true" ]
}
