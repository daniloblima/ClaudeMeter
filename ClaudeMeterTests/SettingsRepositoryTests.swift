//
//  SettingsRepositoryTests.swift
//  ClaudeMeterTests
//
//  Created by Edd on 2026-01-09.
//

import XCTest
@testable import ClaudeMeter

final class SettingsRepositoryTests: XCTestCase {
    func test_settingsPersistAcrossLaunches() async throws {
        let suiteName = "SettingsRepositoryTests.\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName)
        defer { userDefaults?.removePersistentDomain(forName: suiteName) }

        let repository = SettingsRepository(userDefaults: userDefaults ?? .standard)
        var settings = AppSettings.default
        settings.refreshInterval = 300
        settings.hasNotificationsEnabled = false
        settings.isFirstLaunch = false
        settings.cachedOrganizationId = UUID(uuidString: TestConstants.organizationUUIDString)
        settings.iconStyle = .segments

        try await repository.save(settings)
        let loaded = await repository.load()

        XCTAssertEqual(loaded, settings)
    }

    func test_notificationStatePersistsAcrossLaunches() async throws {
        let suiteName = "SettingsRepositoryTests.\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName)
        defer { userDefaults?.removePersistentDomain(forName: suiteName) }

        let repository = SettingsRepository(userDefaults: userDefaults ?? .standard)
        var state = NotificationState()
        state.hasWarningBeenNotified = true
        state.hasCriticalBeenNotified = true
        state.lastPercentage = 85

        try await repository.saveNotificationState(state)
        let loaded = await repository.loadNotificationState()

        XCTAssertEqual(loaded, state)
    }
}
