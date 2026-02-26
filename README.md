# CineNest

A premium movie and TV show tracking app built with Flutter. Browse trending content, manage your watchlist, and rate what you've watched — all with a sleek dark theme UI.

![Flutter](https://img.shields.io/badge/Flutter-3.8+-02569B?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-FFCA28?logo=firebase)
![TMDB](https://img.shields.io/badge/TMDB-API-01B4E4?logo=themoviedatabase)
![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux-blue)

---

## Features

- **Browse** trending, popular, and top-rated movies & TV shows via TMDB
- **Search** with an animated expandable search bar
- **Filter by genre** (Action, Comedy, Drama, Horror, Sci-Fi, Romance, Thriller, Crime)
- **Watchlist** — add movies/shows, toggle grid/list view, filter by type or recency, mark as watched
- **Ratings** — rate content, sort by recent/highest/lowest/title, filter by score
- **Authentication** — email/password login and signup via Firebase Auth
- **Cloud sync** — watchlist and ratings stored in Firestore per user
- **Responsive layout** — 2 to 8 grid columns depending on screen size
- **Dark theme** with warm gold accent colors

---

## Tech Stack

| Category | Library |
|---|---|
| Framework | Flutter 3.8+ / Dart |
| State management | [Riverpod](https://riverpod.dev/) |
| Dependency injection | [GetIt](https://pub.dev/packages/get_it) |
| Backend | Firebase Auth, Cloud Firestore |
| Movie data | [TMDB API](https://www.themoviedb.org/documentation/api) |
| HTTP client | Dio |
| Image loading | CachedNetworkImage + Shimmer |
| Error handling | dartz (`Either<Failure, T>`) |
| Desktop window | window_manager |
| Environment config | flutter_dotenv |

---

## Project Structure

```
lib/
├── UI/
│   ├── screens/
│   │   ├── home/          # Browse, search, genre filter
│   │   ├── watchlist/     # Watchlist management
│   │   ├── ratings/       # Ratings management
│   │   └── auth/          # Login, signup, auth wrapper
│   └── widgets/
│       ├── cards/         # MovieCard, GenreCard, MovieListItem
│       ├── common/        # AppBar, Dropdown, EmptyState
│       └── dialogs/       # MovieDetailsSheet, RatingSheet, WatchlistSheet
├── core/
│   ├── constants/         # Colors, API config, app constants
│   ├── di/                # GetIt injection container
│   ├── errors/            # Failures and exceptions
│   ├── network/           # API client (Dio), network info
│   └── utils/             # Logger, responsive helper, validators
├── data/
│   ├── datasources/       # Remote (TMDB) and local data sources
│   ├── models/            # Movie, Genre, Rating models
│   ├── repositories/      # Repository implementations
│   └── services/          # Firebase Auth and Firestore services
├── providers/             # Riverpod providers
└── main.dart
```

---

## Getting Started

### Prerequisites

- Flutter 3.8+
- A [TMDB API key](https://developer.themoviedb.org/docs/getting-started)
- A Firebase project with Auth and Firestore enabled
- For Windows: Visual Studio Build Tools with C++ workload
- For iOS/macOS: Xcode

### 1. Clone the repo

```bash
git clone https://github.com/your-username/cinenest.git
cd cinenest
```

### 2. Set up environment variables

Create a `.env` file in the project root:

```env
TMDB_API_KEY=your_tmdb_api_key_here
TMDB_API_READ_ACCESS_TOKEN=your_tmdb_read_access_token_here
```

### 3. Set up Firebase

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Authentication** (Email/Password) and **Cloud Firestore**
3. Run the FlutterFire CLI to generate config files:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This generates `lib/firebase_options.dart` and platform-specific config files (`google-services.json`, `GoogleService-Info.plist`).

### 4. Install dependencies

```bash
flutter pub get
```

### 5. Run the app

```bash
flutter run -d chrome      # Web
flutter run -d windows     # Windows
flutter run -d android     # Android
flutter run -d ios         # iOS (macOS required)
```

---

## Build

```bash
flutter build apk          # Android APK
flutter build web          # Web
flutter build windows      # Windows
```

---

## Architecture

Clean Architecture with three layers:

- **UI** — screens and widgets, consumes Riverpod providers
- **Data** — repository implementations, models, data sources (TMDB API + Firebase)
- **Core** — DI setup, constants, error types, network client, utilities

Error handling uses `Either<Failure, T>` (dartz) throughout the data layer. The UI layer accesses services via GetIt (`sl<ServiceType>()`) and state via Riverpod providers.

---

## Responsive Grid

| Screen width | Grid columns |
|---|---|
| Phone | 2 |
| Tablet | 4 |
| Desktop | 6 |
| Ultra-wide | 8 |

---

## Secrets & Environment Files

The following files are **not committed** and must be created locally:

| File | How to get it |
|---|---|
| `.env` | Create manually — add your TMDB API keys |
| `lib/firebase_options.dart` | Run `flutterfire configure` |
| `android/app/google-services.json` | Download from Firebase Console |
| `ios/Runner/GoogleService-Info.plist` | Download from Firebase Console |

---

## Contributing

1. Fork the repo
2. Create a feature branch: `git checkout -b feat/your-feature`
3. Commit using [Conventional Commits](https://www.conventionalcommits.org/): `feat(scope): description`
4. Open a pull request

---

## License

This project uses the [TMDB API](https://www.themoviedb.org/documentation/api) but is not endorsed or certified by TMDB.
