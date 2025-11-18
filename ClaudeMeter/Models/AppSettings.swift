//
//  AppSettings.swift
//  ClaudeMeter
//
//  Created by Edd on 2025-11-14.
//

import Foundation

/// User preferences and app configuration
struct AppSettings: Codable, Equatable, Sendable {
    /// Refresh interval in seconds (60-600)
    var refreshInterval: TimeInterval

    /// Whether notifications are enabled
    var notificationsEnabled: Bool

    /// Notification thresholds
    var notificationThresholds: NotificationThresholds

    /// Whether this is first launch
    var isFirstLaunch: Bool

    /// Last known organization ID (cached)
    var cachedOrganizationId: UUID?

    /// Whether to show Opus usage in the popover
    var showOpusUsage: Bool

    static let `default` = AppSettings(
        refreshInterval: 60,
        notificationsEnabled: true,
        notificationThresholds: .default,
        isFirstLaunch: true,
        cachedOrganizationId: nil,
        showOpusUsage: false
    )

    enum CodingKeys: String, CodingKey {
        case refreshInterval = "refresh_interval"
        case notificationsEnabled = "notifications_enabled"
        case notificationThresholds = "notification_thresholds"
        case isFirstLaunch = "is_first_launch"
        case cachedOrganizationId = "cached_organization_id"
        case showOpusUsage = "show_opus_usage"
    }
}

extension AppSettings {
    /// Validate refresh interval is within bounds
    mutating func setRefreshInterval(_ interval: TimeInterval) {
        refreshInterval = max(60, min(600, interval))
    }
}
