# Magic Bench Workout Tracker

A Flutter mobile application for tracking strength training workouts with clean architecture and comprehensive testing.

![image_int](https://github.com/Fmaj1234/magic_bench/blob/926064207ae8c209a00a51fdd3d4790bdbed4eb4/IMG_5286.jpg)

## Features

- Create, edit, and delete workout sessions
- Track 5 core exercises: Bench Press, Squat, Deadlift, Barbell Row, Shoulder Press
- Add, edit, and remove individual sets within workouts
- Local data persistence
- Input validation for weight and repetitions
- Workout history sorted by date

## Architecture

### Project Structure

lib/
├── models/           # Data models (Exercise, WorkoutSet, Workout)
├── repositories/     # Data access layer (WorkoutRepository)
├── providers/        # State management (WorkoutProvider)
├── widgets/          # Reusable UI components
├── screens/          # Application screens
└── main.dart        # Application entry point
test/
├── models/          # Model tests
├── repositories/    # Repository tests
├── providers/       # Provider tests
├── widgets/         # Widget tests
└── helpers/         # Test utilities
integration_test/
└── app_test.dart   # End-to-end tests

### Design Patterns

**Provider Pattern**: Chosen for state management due to its simplicity, excellent Flutter integration, and ease of testing.

**Repository Pattern**: Abstracts data access, enabling easy testing through mocking and future storage migrations.

**Component-Based UI**: Reusable widgets promote consistency and maintainability.

## Dependencies

### Core
- `provider: ^6.1.1` - State management with minimal boilerplate
- `shared_preferences: ^2.2.2` - Cross-platform local storage for small datasets

### Development
- `flutter_test` - Built-in testing framework
- `integration_test: ^3.1.5` - Official Flutter integration testing
- `mockito: ^5.4.4` - Dependency mocking for isolated unit tests

## Technology Choices

**SharedPreferences over Database**: Simple key-value storage suits the straightforward data model without added complexity.

**Provider over Bloc/Riverpod**: Gentle learning curve and sufficient for the app's scope.

**Material Design**: Platform-appropriate UI without external dependencies.

## Testing Strategy

- **Unit Tests**: Models, repositories, providers with mocked dependencies
- **Widget Tests**: Individual UI component behavior
- **Integration Tests**: Complete user workflows end-to-end

Test coverage includes edge cases, validation scenarios, and error conditions.

## Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Dart SDK 2.17+



