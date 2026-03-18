# CLAUDE.md — iOS Swift Development Guidelines

This file defines the standards, architecture, and workflow for this project.
Claude should follow these guidelines in every response, suggestion, and code generation.

---

## Architecture

Use **MVVM + SwiftUI** as the default architecture.

- **Views** are dumb — they render state and forward user actions. No business logic.
- **ViewModels** hold business logic and expose state to Views.
- **Repositories** abstract data access (network, cache, persistence).
- **Domain models** are plain Swift structs/classes with no framework dependencies.

For complex features with strict testability requirements, consider **TCA (The Composable Architecture)**.

---

## Project Structure

Organise by **feature first**, not by type.

```
MyApp/
├── App/
│   ├── MyApp.swift
│   └── AppDelegate.swift
├── Features/
│   ├── Auth/
│   │   ├── AuthView.swift
│   │   ├── AuthViewModel.swift
│   │   └── AuthModels.swift
│   └── Home/
│       ├── HomeView.swift
│       └── HomeViewModel.swift
├── Core/
│   ├── Network/
│   │   ├── APIClient.swift
│   │   ├── Endpoint.swift
│   │   └── NetworkError.swift
│   ├── Persistence/
│   │   └── Database.swift
│   └── Extensions/
├── Domain/
│   ├── Models/
│   ├── Repositories/      # Protocol + concrete implementation
│   └── UseCases/          # For complex, multi-step business logic
├── UI/
│   ├── Components/        # Reusable SwiftUI views
│   └── Theme/             # Colors, typography, spacing
└── Resources/
    ├── Assets.xcassets
    └── Localizable.strings
```

**Rules:**
- Deleting a feature = deleting one folder. If that's not true, the structure is wrong.
- `Core/` and `UI/` are shared infrastructure — keep them feature-agnostic.
- `Domain/` contains pure Swift — no UIKit, SwiftUI, or networking imports.

---

## Test-Driven Development (TDD)

**Always write tests first.** Follow the Red → Green → Refactor cycle:

1. **Red** — Write a failing test that describes the desired behaviour.
2. **Green** — Write the minimum code to make the test pass.
3. **Refactor** — Clean up without breaking the test.

### Test Structure

Mirror the source tree:

```
MyAppTests/
├── Features/
│   └── Auth/
│       └── AuthViewModelTests.swift
├── Core/
│   └── APIClientTests.swift
└── Mocks/
    ├── MockUserRepository.swift
    └── MockAPIClient.swift

MyAppUITests/
└── Auth/
    └── LoginFlowUITests.swift
```

### Test Naming

Use the **Given / When / Then** pattern:

```swift
func test_login_whenCredentialsAreValid_shouldNavigateToHome() { }
func test_login_whenPasswordIsEmpty_shouldShowValidationError() { }
```

### What to Test

| Layer | What to test |
|---|---|
| ViewModel | State transitions, error handling, side effects |
| Repository | Correct parsing, caching behaviour, error mapping |
| UseCase | Business rule correctness |
| View | UI flows via UITests for critical paths only |

### Mocking

Define protocols at every layer boundary and inject mocks in tests:

```swift
protocol UserRepositoryProtocol {
    func fetchUser(id: String) async throws -> User
}

// In tests
class MockUserRepository: UserRepositoryProtocol {
    var stubbedUser: User?
    var fetchCallCount = 0

    func fetchUser(id: String) async throws -> User {
        fetchCallCount += 1
        return stubbedUser ?? .mock
    }
}
```

Never test against real network calls, databases, or system state in unit tests.

---

## Dependency Injection

**Never use singletons in business logic.** Pass dependencies through `init`.

```swift
// ❌ Bad
class HomeViewModel {
    let api = APIClient.shared
}

// ✅ Good
class HomeViewModel {
    private let api: APIClientProtocol
    init(api: APIClientProtocol = APIClient.shared) {
        self.api = api
    }
}
```

Use SwiftUI's `Environment` for injecting dependencies into the View layer:

```swift
// Register at app root
.environment(\.userRepository, LiveUserRepository())

// Consume in any child View
@Environment(\.userRepository) var userRepository
```

---

## Concurrency

Use **async/await** everywhere. Avoid Combine for new code unless integrating with existing Combine-based APIs.

```swift
// ✅ Prefer
func loadUser() async throws -> User {
    try await repository.fetchUser(id: currentUserID)
}

// ❌ Avoid for new code
func loadUser() -> AnyPublisher<User, Error> { ... }
```

- Run async work from ViewModels using `Task { }`.
- Use `@MainActor` on ViewModels to ensure state updates happen on the main thread.
- Use `actor` for shared mutable state that needs thread safety.

```swift
@Observable
@MainActor
class HomeViewModel {
    var users: [User] = []

    func load() async {
        do {
            users = try await repository.fetchUsers()
        } catch {
            // handle error
        }
    }
}
```

---

## SwiftUI & State Management

Use the modern `@Observable` macro (iOS 17+). Fall back to `ObservableObject` / `@Published` for iOS 16 targets.

| Property Wrapper | Use for |
|---|---|
| `@State` | Local, view-owned value types |
| `@Binding` | Passing mutable state down to child views |
| `@Environment` | Injected dependencies or environment values |
| `@StateObject` / `@Observable` | ViewModel owned by a view |
| `@ObservedObject` | ViewModel passed into a view |

**One ViewModel per screen.** Shared state lives in a parent ViewModel or a dedicated store passed via Environment.

---

## Navigation

Use `NavigationStack` with `navigationDestination` (iOS 16+). Keep navigation logic out of Views — use a **Coordinator / Router** object.

```swift
enum Route: Hashable {
    case profile(userID: String)
    case settings
}

@Observable
@MainActor
class AppRouter {
    var path = NavigationPath()

    func push(_ route: Route) { path.append(route) }
    func popToRoot() { path.removeLast(path.count) }
}
```

Pass the router via Environment so any ViewModel can trigger navigation without the View being involved.

---

## Networking

Define endpoints as an enum or struct, not as raw string URLs scattered through the codebase.

```swift
enum Endpoint {
    case fetchUser(id: String)
    case updateProfile(UserUpdateRequest)

    var path: String { ... }
    var method: HTTPMethod { ... }
    var body: Encodable? { ... }
}
```

- All API responses are mapped to **domain models** in the repository layer. Views never see raw API DTOs.
- Use typed `NetworkError` cases — never expose raw HTTP errors or `URLError` to the ViewModel.
- Always handle and propagate errors explicitly. Never silence them with empty `catch` blocks.

---

## Code Style

Follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/).

- **Clarity over brevity.** `fetchActiveUsers()` beats `getUsers()` or `fetch()`.
- **No force unwrapping** (`!`) in production code. Use `guard let`, `if let`, or provide sensible defaults.
- **No `// TODO` left in merged code.** File a ticket instead.
- Extensions that add conformances go in separate files: `User+Identifiable.swift`.
- Keep files under ~300 lines. If a file is growing, it's doing too much — split it.

---

## Git Workflow

- Branch naming: `feature/auth-login`, `fix/profile-crash`, `chore/update-dependencies`
- Commit messages follow **Conventional Commits**: `feat:`, `fix:`, `refactor:`, `test:`, `chore:`
- Every PR must include tests for new behaviour.
- No PR merges with failing tests or unresolved warnings.

---

## Dependency Management

- Use **Swift Package Manager (SPM)** exclusively for new dependencies.
- Avoid CocoaPods unless a required library has no SPM support.
- Evaluate every new dependency: prefer small, well-maintained packages over large frameworks.
- Prefer stdlib or Foundation solutions over adding a dependency for trivial utilities.

---

## What Claude Should Always Do

- Write tests alongside every new function or feature.
- Use protocols at layer boundaries to enable mocking and loose coupling.
- Inject dependencies — never reach for a singleton from within business logic.
- Prefer `async/await` over callbacks or Combine for new async code.
- Keep Views as thin as possible — if logic is creeping into a View, move it to a ViewModel.
- Name things clearly and consistently with the conventions in this file.
- Flag when a request would violate one of these guidelines and suggest the correct approach.
