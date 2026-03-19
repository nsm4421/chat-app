# domodachi Project Rules

## Purpose

This file defines local engineering rules for the `domodachi` project.
Prefer these rules when making code changes in this repository.

## Architecture

- Use feature-first structure under `lib/features/<feature_name>`.
- Keep dependency direction one-way:
  `presentation -> domain/use_case -> domain/repository -> data -> core/external`
- Do not let `presentation` depend directly on data sources.
- Do not let `domain` depend on Flutter UI packages.

## Auth Feature Rule

- Treat `AuthUseCases` as the feature facade for auth business actions.
- Presentation layer may depend on `AuthUseCases`, but should not depend on `AuthRepository` directly.
- Individual auth use case classes are implementation details owned by `AuthUseCases`.
- Supabase access should live behind `SupabaseAuthDataSource`.
- Inside auth feature, only data source classes may import Supabase SDK types.
- Data sources should return data models, not Supabase SDK models.
- Repositories should map data models into domain entities and expose only domain types.

## Dependency Injection

- Use `injectable` + `get_it` for app-level wiring.
- Register feature facade classes such as `AuthUseCases` in DI.
- Do not register tiny per-action use case classes in DI if they are only used through a facade.
- Prefer `@lazySingleton` for long-lived coordinators:
  router, feature facades, session state holders, repositories, external clients.
- Prefer `@injectable` or `factory` scope for short-lived presentation helpers.

## Naming

- Use `DataSource` for SDK or API facing classes.
- Use `Repository` for domain-facing persistence abstractions.
- Use `UseCase` for a single business action.
- Use `<Feature>UseCases` for a grouped facade over feature actions.
- Use `Page` for route-level screens.
- Use `Cubit` or `Bloc` consistently inside a feature. Avoid mixing both for the same responsibility.

## Router

- Route path constants live in `lib/app/router/app_route_path.dart`.
- Router assembly lives in `lib/app/router/app_router.dart`.
- App-wide navigation policy such as auth redirects belongs in `AppRoute`.
- Do not scatter redirect logic across pages.

## Theme

- Theme code belongs under `lib/app/theme/`.
- Keep theme layers separated:
  `palette`, `color scheme`, `typography`, `theme data`.
- Prefer semantic colors through theme or palette instead of ad-hoc hex values inside feature widgets.

## State Models

- Prefer `freezed` for feature state/event/request models that benefit from copy, unions, or equality.
- If a `freezed` model is not a union, prefer the field-declared class style with `final` fields and a normal constructor.
- Reserve `const factory` union cases for actual sum types such as event/state/request variants.
- Generated files are not edited manually.
- If a model does not need unions or copy semantics, a simple `final class` is acceptable.

## Error Handling

- Domain and data failures should be mapped into project-specific `Failure` types.
- UI should not handle raw Supabase exceptions directly.
- Repositories are responsible for translating external exceptions into domain failures.
- If an external SDK is used, convert its exceptions inside the data source into project-owned data exceptions before they reach repositories.

## Extensions

- Common extensions live under `lib/core/extensions/`.
- Prefer direct file imports over a barrel file unless a stable shared entrypoint is clearly needed.

## Testing

- Add or update tests when changing business flow, routing rules, or shared extensions.
- Prefer testing behavior at the public boundary of the layer being changed.
- Do not test generated files directly.

## Generated Files

- Never hand-edit:
  `*.freezed.dart`, `*.g.dart`, `*.config.dart`
- After changing `freezed`, `envied`, or `injectable` inputs, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Practical Defaults

- Start simple. Add layers only when they clarify responsibility.
- When in doubt, prefer consistency with the existing feature over introducing a new pattern.
- Refactors should preserve clear ownership:
  page/widget for UI, use case facade for business actions, repository for domain persistence, data source for SDK access.
