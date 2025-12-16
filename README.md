# Catatan Ibay

Minimal B&W daily notes + to-do app for internship journaling.

## Run

1. flutter pub get
2. flutter run

Run tests:

- flutter test

Build APK (release):

- flutter build apk --release

Build & Download Debug APK (GitHub Actions) (fast, unsigned):

- A GitHub Actions workflow is included at `.github/workflows/build-debug-apk.yml`.
- Trigger it manually from the Actions tab (Workflow: **Build Debug APK**) or push to `main`.
- After the run completes, download the artifact named `app-debug-apk` (contains `app-debug.apk`).

Notes:
- After changing dependencies run `flutter pub get`.
- The app uses Hive for local storage; if running tests you may want to run them on an emulator or device.

Features added:
- Drawer (hamburger menu) with profile photo and horizontal date scroller for current month — tap a date to open that day's detail.
- Change profile photo (gallery) from Drawer. Photo is shown next to Notes on Today page.
- App uses Montserrat font (via google_fonts) for clean, professional typography.

Notes about new features:
- Font: App uses Montserrat (via `google_fonts`).
- Profile photo: open the hamburger menu (left drawer) and use "Ganti Foto" to pick an image from gallery. The photo appears near notes.
- Drawer: shows days for the focused month (swipe months with chevrons) — tap a date to open that day's detail page.

## Features

- Auto-creates today entry each day
- Notes with auto-save
- To-do list per day with done/undone and delete
- History of dates (open and edit old days)
- Local storage using Hive
- Light / Dark toggle (stored locally)


## Project structure

lib/
 ┣ models/
 ┣ pages/
 ┣ services/
 ┣ main.dart


**Notes:** Run `flutter pub get` after pulling the repo to fetch dependencies.

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
