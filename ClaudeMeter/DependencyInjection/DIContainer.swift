//
//  DIContainer.swift
//  ClaudeMeter
//
//  Created by Edd on 2025-11-14.
//

import Foundation

/// Dependency injection container (Principle IV: Protocol-Oriented Testability)
@MainActor
final class DIContainer {
    // MARK: - Singleton

    static let shared = DIContainer()

    // MARK: - Repositories

    let keychainRepository: KeychainRepositoryProtocol
    let settingsRepository: SettingsRepositoryProtocol
    let cacheRepository: CacheRepositoryProtocol

    // MARK: - Services

    let networkService: NetworkServiceProtocol
    let usageService: UsageServiceProtocol
    let notificationService: NotificationServiceProtocol

    // MARK: - Initialization

    private init() {
        self.keychainRepository = KeychainRepository()
        self.settingsRepository = SettingsRepository()
        self.cacheRepository = CacheRepository()

        self.networkService = NetworkService()
        self.notificationService = NotificationService(settingsRepository: settingsRepository)
        self.usageService = UsageService(
            networkService: networkService,
            cacheRepository: cacheRepository,
            keychainRepository: keychainRepository,
            settingsRepository: settingsRepository
        )

        // Setup notification delegate from MainActor context
        self.notificationService.setupDelegate()
    }

    /// Test initializer accepting protocol mocks
    init(
        keychainRepository: KeychainRepositoryProtocol,
        settingsRepository: SettingsRepositoryProtocol,
        cacheRepository: CacheRepositoryProtocol,
        networkService: NetworkServiceProtocol,
        notificationService: NotificationServiceProtocol,
        usageService: UsageServiceProtocol
    ) {
        self.keychainRepository = keychainRepository
        self.settingsRepository = settingsRepository
        self.cacheRepository = cacheRepository
        self.networkService = networkService
        self.notificationService = notificationService
        self.usageService = usageService
    }
}
