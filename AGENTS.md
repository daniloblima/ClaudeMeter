# AGENTS.md

## Project Overview

macOS 14+ menu bar app monitoring Claude.ai usage limits. Swift 6 / SwiftUI with @MainActor @Observable state management and actor-isolated services.

## Setup

```bash
# Clone and open
git clone git@github.com:eddmann/ClaudeMeter.git
cd ClaudeMeter
open ClaudeMeter.xcodeproj

# Build from CLI (requires Xcode 16+)
xcodebuild clean build \
  -project ClaudeMeter.xcodeproj \
  -scheme ClaudeMeter \
  -configuration Debug
```

Press ⌘R in Xcode to run. App appears in menu bar (not Dock).

## Common Commands

| Task | Command |
|------|---------|
| Build (Debug) | `xcodebuild clean build -project ClaudeMeter.xcodeproj -scheme ClaudeMeter -configuration Debug` |
| Build (Release) | `xcodebuild clean build -project ClaudeMeter.xcodeproj -scheme ClaudeMeter -configuration Release -derivedDataPath ./build -arch x86_64 -arch arm64` |
| Run Tests | `xcodebuild test -project ClaudeMeter.xcodeproj -scheme ClaudeMeter -configuration Debug` |
| Open in Xcode | `open ClaudeMeter.xcodeproj` |

No linting or formatting tools configured.

## Code Conventions

### File Organization
```
ClaudeMeter/
├── App/           # AppModel.swift, ClaudeMeterApp.swift (entry point)
├── Models/        # Data types, API/, Errors/
├── Services/      # Actor-isolated business logic, Protocols/
├── Repositories/  # Data persistence (Keychain, UserDefaults, Cache), Protocols/
└── Views/         # SwiftUI components: MenuBar/, Settings/, Setup/
```

### Naming
- One type per file, filename matches type: `UsageData.swift`, `NetworkService.swift`
- Protocols in `Protocols/` subdirectory: `UsageServiceProtocol.swift`
- Error types suffixed: `AppError.swift`, `NetworkError.swift`

### Concurrency Model
- `@MainActor @Observable` for AppModel and all views
- `actor` for services and repositories (thread-safe)
- `async/await` end-to-end
- Mark non-published dependencies `@ObservationIgnored`

### Pattern Examples

**Observable state owner:**
```swift
@MainActor @Observable final class AppModel {
    var settings: AppSettings = .default
    @ObservationIgnored private let service: ServiceProtocol
}
```

**Actor-isolated service:**
```swift
actor UsageService: UsageServiceProtocol {
    private static let logger = Logger(subsystem: "com.claudemeter", category: "UsageService")
    func fetchUsage() async throws -> UsageData { }
}
```

**Dependency injection (constructor with defaults):**
```swift
init(
    settingsRepository: SettingsRepositoryProtocol = SettingsRepository(),
    keychainRepository: KeychainRepositoryProtocol = KeychainRepository()
) { }
```

### Imports
System frameworks first, no third-party deps in main target:
```swift
import SwiftUI
import Observation
import os
```

## Tests & CI

### Running Tests
```bash
# All tests
xcodebuild test -project ClaudeMeter.xcodeproj -scheme ClaudeMeter

# Specific test class
xcodebuild test -project ClaudeMeter.xcodeproj -scheme ClaudeMeter \
  -only-testing ClaudeMeterTests/AppModelTests
```

### Test Structure
- `ClaudeMeterTests/` - XCTest with `@MainActor` async tests
- `TestDoubles/` - Stubs, fakes, spies for protocol-based DI
- `__Snapshots__/` - Snapshot test reference images (SnapshotTesting library)

### CI
- No automated PR checks (build/tests not run on PRs)
- Release workflow: manual trigger via GitHub Actions
- Builds universal binary, signs with Developer ID, notarizes with Apple

## PR & Workflow Rules

### Commit Format
```
type(scope): description
```

Examples:
```
feat(menu-bar): add battery icon style
fix(settings): remove icon preview flicker
refactor(app): modernize app lifecycle
docs: add session key instructions
```

Types: `feat`, `fix`, `refactor`, `docs`, `test`

### Branch
- `main` is the release branch
- No PR templates or CODEOWNERS

### Release Process
1. Trigger GitHub Actions workflow with version (e.g., `1.0.0`)
2. Builds, signs, notarizes automatically
3. Creates GitHub release with signed ZIP
4. Updates Homebrew tap

## Security & Gotchas

### Session Keys
- Format: `sk-ant-*` (validated by `SessionKey` initializer)
- Stored in Keychain only (service: `com.claudemeter.sessionkey`)
- Never serialize to disk or logs
- May contain embedded org UUID

### Files to Never Commit
- `*.p12`, `*.mobileprovision` (certificates)
- API keys, session keys
- `xcuserdata/`, `DerivedData/`
- `build/` output directory

### Non-Obvious Patterns
- Cache TTL is 55 seconds (< 60s minimum refresh interval)
- Staleness threshold: 1200 seconds (shows "stale" indicator)
- Retry: 2^n for network errors, 3^n for rate limits, no retry for auth failures
- `@ObservationIgnored` required for non-UI dependencies in AppModel
- Cancel existing `Task` before creating new ones (prevent duplicates)

### Constants
Key values in `ClaudeMeter/Models/Constants.swift`:
- `Constants.Cache.ttl` = 55 seconds
- `Constants.Network.maxRetries` = 3
- `Constants.Refresh.minimum` = 60 seconds
- `Constants.Refresh.maximum` = 600 seconds

### Adding a New Setting
1. Add property to `AppSettings` struct
2. Settings auto-persist via `SettingsRepository` on change
3. Add UI control in `SettingsView` bound to `appModel.settings`
4. If behavior depends on setting, react in `AppModel.scheduleSettingsSave()`

### Adding a New API Endpoint
1. Define response model in `Models/API/`
2. Add method to protocol in `Services/Protocols/`
3. Implement in service with retry logic
4. Call from `AppModel` or helper
