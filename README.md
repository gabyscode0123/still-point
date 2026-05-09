# Stillpoint

Stillpoint is a Flutter wellness-tracking app that helps users notice the relationship between daily habits and how they feel.

The app turns daily check-ins into calm, visual summaries: a wellness score, recent check-ins, mood and stress patterns, a sleep and mood relationship graph, and a time-use breakdown. It uses a soft Japandi-inspired palette with accessible contrast and intentionally simple language.

## Features

- Daily check-ins for sleep, mood, stress, focus, screen time, exercise, and social time
- Wellness score based on the last 14 check-ins
- Analytics based on the previous 14 days
- Recent check-ins capped at one week, with a full history view
- Demo data that reflects a typical college student routine
- Custom chart painters for lightweight, dependency-free visualizations

## Tech Stack

- Flutter
- Dart
- Material 3
- Custom `CustomPainter` charts

## Run Locally

```sh
flutter pub get
flutter run
```

## Verify

```sh
flutter analyze
flutter test
```

## GitHub Description

Track daily habits and visualize patterns in sleep, mood, stress, and time use with a calm Flutter wellness dashboard.
