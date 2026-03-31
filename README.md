# Task Manager App

Flutter Task Management app created for Flodo AI take-home assignment.

## Track and Stretch Goal

- Track: B (Mobile Specialist)
- Stretch Goal: Debounced search with highlighted matching text

## Tech Stack

- Flutter + Dart
- SQLite via `sqflite`
- `shared_preferences` for draft persistence
- Material UI

## Features Implemented

- Task model fields:
	- Title
	- Description
	- Due Date
	- Status (`To-Do`, `In Progress`, `Done`)
	- Blocked By (optional task dependency)
- CRUD:
	- Create task
	- Read/list tasks
	- Update task
	- Delete task with confirmation
- Dependency logic:
	- Blocked tasks are visually distinct
	- Blocked tasks are disabled until dependency is done
- Search and filter:
	- Search by title
	- Filter by status
	- Debounced search (300ms)
	- Matching title text highlight
- UX improvements:
	- Loading simulation on create/update (2 seconds)
	- Save button disabled while saving
	- Prevent double-submit
	- Draft persistence for new-task title and description
	- Empty state UI
	- Snackbars for feedback and error handling

## Setup Instructions

1. Clone repository

```bash
git clone https://github.com/RakatiVenukumar/TaskManagementAPP.git
cd TaskManagementAPP/task_manager_app
```

2. Install dependencies

```bash
flutter pub get
```

3. Verify environment

```bash
flutter doctor
```

4. Run app

```bash
flutter run
```

Optional targets:

```bash
flutter run -d chrome
flutter run -d android
```

## Android Notes (Windows)

If Android SDK is not detected, create `android/local.properties` with:

```properties
sdk.dir=C:\\Users\\venuk\\AppData\\Local\\Android\\Sdk
```

Then run:

```bash
flutter doctor --android-licenses
flutter doctor
```

## AI Usage Report

AI tools were used to accelerate implementation, debugging, and refactoring.

Most helpful prompts:

- "Implement a beginner-friendly SQLite helper with insert/get/update/delete for Task model."
- "Add debounced search (300ms) in Flutter list screen using Timer."
- "Highlight matching substring in title using RichText and TextSpan."
- "Add robust form save flow with loading state, snackbars, and error handling."

Example of bad AI suggestion and fix:

- Issue: AI suggested running Android build commands before SDK path was configured.
- Fix applied: configured `ANDROID_HOME`, set `android/local.properties`, installed cmdline-tools, accepted licenses, and re-ran `flutter doctor`.

## Demo Checklist

- Show create, edit, and delete
- Show blocked task behavior
- Show search + status filter
- Show debounced and highlighted search
- Show loading state on save
- Show draft restore after reopening form
