# Clean Architecture for Flutter (Uncle Bob's Architecture)

## Overview
This document outlines the Clean Architecture principles as defined by Robert C. Martin (Uncle Bob) and their application in Flutter development. Clean Architecture promotes separation of concerns, testability, and maintainability by organizing code into distinct layers with clear dependencies.

## Core Principles

### 1. Dependency Rule
- Dependencies can only point inward toward higher-level policies
- Inner layers should not know about outer layers
- Business rules should not depend on frameworks, UI, or external concerns

### 2. Independence
- **Framework Independence**: Architecture doesn't depend on Flutter widgets or external libraries
- **UI Independence**: Business logic works regardless of UI implementation
- **Database Independence**: Business rules are not bound to specific data storage
- **External Agency Independence**: Business rules don't know about external services

## Layer Structure

### 1. Entities (Core/Domain Layer)
**Location**: `lib/core/entities/` or `lib/domain/entities/`

- Contains enterprise-wide business rules
- Pure Dart classes with no external dependencies
- Represent the most general and high-level rules
- Should be the most stable layer

```dart
// Example Entity
class User {
  final String id;
  final String email;
  final String name;
  
  User({required this.id, required this.email, required this.name});
}
```

### 2. Use Cases (Application Business Rules)
**Location**: `lib/core/usecases/` or `lib/domain/usecases/`

- Contains application-specific business rules
- Orchestrates data flow to and from entities
- Implements the application's use cases
- Independent of UI and data sources

```dart
// Example Use Case
abstract class GetUserUseCase {
  Future<Either<Failure, User>> call(String userId);
}
```

### 3. Interface Adapters (Presentation & Data)
**Location**: `lib/presentation/` and `lib/data/`

#### Presentation Layer
- **Widgets**: Flutter UI components
- **Controllers/Blocs**: State management (BLoC, Provider, Riverpod)
- **View Models**: Data formatting for UI

#### Data Layer
- **Repositories**: Implement domain repository interfaces
- **Data Sources**: Remote (API) and Local (Database) data sources
- **Models**: Data transfer objects with JSON serialization

### 4. Frameworks & Drivers (External Layer)
**Location**: `lib/core/network/`, `lib/core/database/`, external packages

- Web frameworks, databases, external APIs
- Flutter framework, HTTP clients, local storage
- Most volatile layer - changes frequently

## Folder Structure

```
lib/
├── core/
│   ├── entities/
│   ├── usecases/
│   ├── repositories/          # Abstract repository interfaces
│   ├── errors/
│   ├── utils/
│   └── constants/
├── data/
│   ├── models/
│   ├── repositories/          # Repository implementations
│   ├── datasources/
│   │   ├── remote/
│   │   └── local/
│   └── mappers/
├── presentation/
│   ├── pages/
│   ├── widgets/
│   ├── controllers/           # BLoC, Cubit, or other state management
│   └── utils/
└── injection/                 # Dependency injection setup
```

## Key Patterns

### 1. Repository Pattern
- Abstract repository in domain layer
- Concrete implementation in data layer
- Handles data source switching logic

### 2. Dependency Injection
- Use packages like `get_it`, `injectable`, or `riverpod`
- Register dependencies at app startup
- Inject dependencies into use cases and repositories

### 3. Error Handling
- Use `Either<Failure, Success>` pattern (dartz package)
- Define custom failure types
- Handle errors at appropriate layers

### 4. State Management
- Use BLoC pattern for complex state
- Controllers/Cubits call use cases
- UI reacts to state changes

## Benefits

1. **Testability**: Each layer can be tested independently
2. **Maintainability**: Clear separation of concerns
3. **Flexibility**: Easy to change external dependencies
4. **Scalability**: Architecture supports large applications
5. **Team Collaboration**: Clear boundaries for different team members

## Testing Strategy

- **Unit Tests**: Entities, Use Cases, Repositories
- **Widget Tests**: UI components
- **Integration Tests**: Full feature flows
- **Mock Dependencies**: Use mockito or mocktail for testing

## Dependencies Flow Example

```
UI Widget → BLoC/Controller → Use Case → Repository Interface → Repository Implementation → Data Source
```

## Common Mistakes to Avoid

1. **Violating Dependency Rule**: Inner layers depending on outer layers
2. **Fat Controllers**: Business logic in presentation layer
3. **Direct Database Access**: Bypassing repository pattern
4. **Framework Coupling**: Business logic tied to Flutter widgets
5. **Missing Abstractions**: Concrete implementations in domain layer

## Recommended Packages

- **State Management**: `flutter_bloc`, `riverpod`
- **Dependency Injection**: `get_it`, `injectable`
- **Functional Programming**: `dartz`
- **HTTP Client**: `dio`
- **Local Storage**: `hive`, `sqflite`
- **Code Generation**: `freezed`, `json_annotation`

## Getting Started Checklist

- [ ] Set up folder structure according to Clean Architecture
- [ ] Define entities for your domain
- [ ] Create repository interfaces in domain layer
- [ ] Implement use cases for business logic
- [ ] Set up dependency injection
- [ ] Create repository implementations in data layer
- [ ] Build presentation layer with state management
- [ ] Write comprehensive tests for each layer

Remember: Clean Architecture is about creating boundaries and managing dependencies. Start simple and refactor as your application grows in complexity.
