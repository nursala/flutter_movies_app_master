# Flutter Movie Browser

A Flutter app for discovering movies and TV shows, searching titles, filtering by genre, and viewing details from TMDb. The home and detail screens use BLoC for loading, success, and error states.

## What is in the repository

- Movie and TV discovery, search, pagination, and genre filters
- Detail pages with cast and video information
- TMDb requests through Dio, cached poster images, and loading placeholders
- English and Arabic interface labels

## Run locally

Install a Flutter SDK compatible with Dart `^3.7.2`, then run:

```bash
flutter pub get
flutter run --dart-define=TMDB_API_KEY=YOUR_TMDB_KEY
```

Get an API key from [TMDb](https://www.themoviedb.org/settings/api). The app reads `TMDB_API_KEY` at build time. Do not commit a real key. A mobile app distributes its configured key to clients, so restrict or proxy the credential if you need stronger protection.

## Code map

| Path | Responsibility |
| --- | --- |
| `lib/pages/home/` | Discovery UI and HomeBloc |
| `lib/pages/movie_details/` | Detail UI and detail BLoC |
| `lib/services/tmdb_service.dart` | TMDb HTTP requests |
| `lib/models/` | API response models |
| `lib/widgets/` | Shared UI elements |

## Demo

A verified app screenshot or recording has not been added yet. The source and instructions above are the current way to inspect the app.