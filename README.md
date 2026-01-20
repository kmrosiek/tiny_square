# Tiny Square

A Flutter app that fetches random images and displays them as centered squares with adaptive background colors.

## Demo

<!-- TODO: Add demo video -->
[![Watch the video](https://github.com/kmrosiek/tiny_square/blob/feat/readme/readme_assets/demo.mp4)](https://github.com/kmrosiek/tiny_square/blob/feat/readme/readme_assets/demo.mp4)


![App preview](readme_assets/demo.gif)

![Error preview](readme_assets/error.gif)

<table style="width: 100%;">
  <tr>
    <td>
      <p align="center"><b>App Preview</b></p>
      <img src="readme_assets/demo.gif" alt="App preview" width="100%">
    </td>
    <td>
      <p align="center"><b>Error Preview</b></p>
      <img src="readme_assets/error.gif" alt="Error preview" width="100%">
    </td>
  </tr>
</table>


## Features

- Fetches random images from API
- Adaptive background colors extracted from images
- Smooth animations (fade transitions, animated background)
- Light/dark theme support with toggle
- Accessibility support (semantic labels, screen reader compatible)

## Architecture

Clean Architecture with 4 layers:

```
lib/
├── presentation/    # UI widgets, pages, helpers
├── application/     # BLoC/Cubits, states, theme management
├── domain/          # Entities, abstract repositories & services
├── infrastructure/  # Implementations, datasources, models
└── core/            # DI, failures, shared utilities
```

### Key Patterns

- **BLoC/Cubit** for state management (flutter_bloc)
- **Dependency Injection** via GetIt
- **Functional error handling** with `dartz` package (`Either<Failure, T>` for results, `Option<T>` for nullable values)
- **SOLID principles** throughout (abstractions injected, single responsibility per class)

### Theming

Colors are extracted from images using `palette_generator_master` to derive dominant and vibrant swatches. UI colors respect the current theme while adapting to image content — button and text colors are based on the theme's primary color but use `Color.lerp` to blend towards image-extracted colors for a more immersive experience.

## Getting Started

```bash
flutter pub get
flutter run
```
## Screenshots

### Semantics

<div align="center">
  <img src="readme_assets/semantics.PNG" alt="Semantics Screenshot" width="300">
</div>

### Profiling

Profiling was performed using Flutter DevTools. No jank frames or performance issues were detected.

![Profiling preview](readme_assets/profiling.gif)

### Leak Tracking

Used `leak_tracker` to monitor for memory leaks during development. No leaks were detected.

<!-- TODO: Add leak tracking video -->
[Leak Tracking Video Placeholder]