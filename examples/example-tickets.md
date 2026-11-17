# Example ticket breakdown (Star Wars API)

These are the tickets the factory would create after grilling. Each is sized for one Implementer session.

## Minimal tier (golden-ticket run)

The smallest set that still exercises every gate check. Use it for a first
reference run or to evaluate agent changes; each ticket goes through the full pipeline.

1. **Foundation**: `install:api`, `throttleApi()`, `v1` prefix, `factory doctor` clean, gate green on the empty app
   (test or remove the scaffolded `/api/user` route).
2. **Films**: migration (unique `episode_id`), model, factory, seeder called from `DatabaseSeeder`,
   `IndexFilmsRequest` (`title`, `director`, capped `per_page`), Resource, index + show.
   Tests: no-filter baseline, each filter, invalid filter → 422, page-size cap, show, 404.
3. **Characters + planets**: same shape, plus `homeworld` and the `character_film` / `film_planet` pivots.
   Tests as above, plus a character with a null `gender` appears in the unfiltered list.

Done means a job file per ticket with `gate_report.result == "pass"`, a Review and an Approver block.

## Full breakdown

## Phase 1 — Foundation
- [ ] Setup Pest, PAO, Pint, PHPStan
- [ ] Run `php artisan install:api`; enable `throttleApi()`; base API structure (v1 prefix, error handling)
- [ ] Add architecture tests skeleton

## Phase 2 — Domain
- [ ] Films: migration, model, factory, seeder
- [ ] Characters: migration, model, factory, seeder + relationships
- [ ] Planets, Species, Vehicles, Starships: migrations, models, factories, seeders
- [ ] Seed realistic Star Wars data (every seeder called from `DatabaseSeeder`)

## Phase 3 — API
- [ ] Film Form Request (filters) + Resource + index/show endpoints + tests
- [ ] Character Resource + index/show endpoints + tests
- [ ] Planet / Species / Vehicle / Starship Resources + endpoints + tests
- [ ] Nested relationship endpoints (optional)

## Phase 4 — Polish
- [ ] Consistent pagination and error responses
- [ ] README with setup and endpoint list
- [ ] Final architecture test pass
- [ ] OpenAPI documentation (optional)

Each ticket must include:
- Acceptance criteria
- Links to related tickets
- Definition of done from AGENTS.md
