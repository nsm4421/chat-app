# Profiles Schema

## Purpose

`public.profiles` stores app-facing profile data for authenticated users.
It is a `1:1` extension of `auth.users`.

## Relationship

- `public.profiles.id = auth.users.id`
- delete policy: `on delete cascade`
- `auth.users` remains the authentication source of truth
- `public.profiles` becomes the profile/domain source of truth

## Columns

- `id`: UUID primary key, references `auth.users(id)`
- `email`: convenience copy of auth email
- `display_name`: visible display name
- `username`: optional public handle
- `avatar_url`: optional avatar URL
- `bio`: optional short introduction
- `onboarding_completed`: whether profile onboarding is complete
- `created_at`: UTC creation timestamp
- `updated_at`: UTC update timestamp

## Validation

Database constraints and client validation are intentionally aligned.

- `display_name`: 2-30 characters
- `username`: optional, regex `^[a-z0-9_]{3,20}$`
- `bio`: max 160 characters

Client-side source of truth:
- [auth_input_validator.dart](/Users/n/Desktop/pg/lib/features/auth/domain/validation/auth_input_validator.dart)
- [profile_field_rules.dart](/Users/n/Desktop/pg/lib/features/auth/domain/validation/profile_field_rules.dart)

Database source of truth:
- [20260319232610_create_profiles.sql](/Users/n/Desktop/pg/supabase/migrations/20260319232610_create_profiles.sql)

## RLS

- authenticated users can read profiles
- authenticated users can insert only their own profile row
- authenticated users can update only their own profile row

## Lifecycle

An `after insert` trigger on `auth.users` creates the matching `public.profiles` row.
