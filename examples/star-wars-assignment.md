# Assignment: Star Wars Encyclopedia API

Build a professional, API-driven Star Wars encyclopedia using Laravel.

## Goal

A clean, versioned REST API that lets clients explore the Star Wars universe: films, characters, planets, species, vehicles, and starships, with their relationships.

## Non-goals

- No frontend (API only).
- No real-time features.
- No user-generated content in the first version.
- No complex search ranking (simple filters are enough).

## Resources

| Resource   | Key fields (example)                  | Relationships                  |
|------------|---------------------------------------|--------------------------------|
| Film       | title, episode_id, opening_crawl, release_date, director | characters, planets, species, vehicles, starships |
| Character  | name, height, mass, hair_color, birth_year, gender | homeworld, films, species, vehicles, starships |
| Planet     | name, rotation_period, orbital_period, diameter, climate, gravity, terrain, population | residents, films |
| Species    | name, classification, designation, average_height, skin_colors, language | people, films |
| Vehicle    | name, model, manufacturer, cost_in_credits, length, crew, passengers | pilots, films |
| Starship   | name, model, manufacturer, cost_in_credits, length, crew, passengers, hyperdrive_rating | pilots, films |

## Required endpoints (v1)

All under `/api/v1`.

- `GET /films` — paginated list, filter by title, director
- `GET /films/{id}` — single film with related resources (summary)
- `GET /characters` — paginated, filter by name, gender
- `GET /characters/{id}`
- `GET /planets` and `GET /planets/{id}`
- `GET /species` and `GET /species/{id}`
- `GET /vehicles` and `GET /vehicles/{id}`
- `GET /starships` and `GET /starships/{id}`

Optional but recommended:
- `GET /films/{id}/characters`
- Similar nested routes for other relationships

## Technical requirements

- Laravel API Resources for all responses.
- Consistent pagination (Laravel default or cursor).
- Consistent error format.
- Database seeded with a realistic subset of Star Wars data (at least 6 films, 10+ characters, several planets/species/vehicles/starships).
- Full Pest Feature test coverage for every endpoint (happy path + validation/404).
- Architecture tests enforcing thin controllers and no direct Eloquent in controllers.
- Form Requests even for query parameters where useful.
- Factories for every model.
- OpenAPI / Swagger documentation (optional but professional: use a package or hand-written).

## Acceptance criteria

- `php artisan test` (or `vendor/bin/pest`) is green.
- `vendor/bin/pint --test` is clean.
- A new developer can clone the repo, run migrations + seed, and hit the API locally.
- README explains how to run and lists the main endpoints.
- All tickets that implement the above are closed with linked PRs.

## How the factory should attack this

1. Grill any remaining open questions (data source for seeding, exact pagination style, etc.).
2. Write the Spec.
3. Create GitHub Issues for:
   - Models + migrations + factories
   - Seeders
   - API Resources
   - Controllers + routes
   - Feature tests
   - Architecture tests
   - Documentation
4. Implement in parallel where possible (models first, then endpoints).
5. Review and merge.

This assignment is intentionally complete enough that the factory can produce a professional result without further invention.
