# domodachi

Flutter app scaffold for `domodachi`, with a minimal root structure that can
grow into a mobile-first product backed by Supabase.

## Structure

```text
lib/
  app/
  features/
assets/
supabase/
```

## Run

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Test

```bash
flutter test
```

Reusable test boilerplate lives under `test/test_helpers/`.

- `TestApp`: wraps a widget with the app theme and `MaterialApp`.
- `pumpDomodachiApp(...)`: lets widget tests boot a screen with one line.
- `configureTestDependencies(...)`: resets `get_it` and registers test doubles.

## Supabase

The `supabase/` directory is reserved for local Supabase config, migrations, and
edge functions when you wire up the backend.

At startup, `lib/core/bootstrap/bootstrap.dart` initializes Supabase and then
registers app dependencies with `get_it` + `injectable`.

Environment values are injected from `.env.local` via `envied`.

Example access:

```dart
final supabaseClient = getIt<SupabaseClient>();
final authService = getIt<SupabaseAuthService>();
```
