# Flutter AI Tutor

Flutter AI Tutor is a production-oriented Flutter learning app that teaches Dart, Flutter, software engineering, and AI-assisted mobile development through structured lessons, progress tracking, and an in-app AI tutor.

## Project Overview

- Day-wise curriculum and roadmap navigation
- Lesson content with runnable examples
- Local progress tracking
- AI tutor assistant with Gemini, OpenAI, and Claude support
- Dedicated AI assistant settings screen
- Secure local storage for provider keys
- Persisted default model selection

## Technology Stack

- Flutter / Dart
- `flutter_bloc`
- `go_router`
- `hive`
- `dio`
- `google_generative_ai`
- `flutter_secure_storage`
- `shared_preferences`

## Setup

1. Install Flutter stable.
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run code generation when needed:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

## Configuration

- Provider API keys are entered inside the app from the AI Assistant Settings screen.
- Keys are stored locally using encrypted platform storage.
- The selected default model is stored locally and restored automatically.
- No remote database is used for assistant configuration or conversation state.

## Running the App

```bash
flutter run
```

## Build

Android:

```bash
flutter build apk
```

iOS:

```bash
flutter build ios
```

Web:

```bash
flutter build web
```

## Architecture Overview

- Presentation: Flutter screens, widgets, and Bloc/Cubit state
- Domain: Use cases and repository contracts
- Data: Local and remote data sources
- Infrastructure: DI, routing, constants, and app bootstrap

## Folder Structure

- `lib/core` - DI, routing, constants, utilities, and shared errors
- `lib/data` - local storage and remote API sources
- `lib/domain` - models, repositories, and use cases
- `lib/features` - feature UI, blocs, and screen widgets
- `lib/shared` - reusable shared widgets

## Key Features

- Curriculum browsing by phase, module, and lesson
- Lesson completion tracking
- AI tutor chat with streamed responses
- Model persistence across app launches
- Secure BYOK setup for Gemini, OpenAI, and Claude

## Contribution Guide

- Follow the existing feature-first structure.
- Keep changes localized.
- Update documentation when behavior or architecture changes.
- Prefer reusable components and consistent Bloc patterns.

