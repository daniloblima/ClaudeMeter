//
//  NotificationState.swift
//  ClaudeMeter
//
//  Created by Edd on 2025-11-14.
//

import Foundation

/// Tracks which notification thresholds have been triggered
struct NotificationState: Codable, Equatable, Sendable {
    /// Whether warning (75%) notification has been sent
    var warningNotified: Bool = false

    /// Whether critical (90%) notification has been sent
    var criticalNotified: Bool = false

    /// Last known usage percentage to detect reset
    var lastPercentage: Double = 0

    enum CodingKeys: String, CodingKey {
        case warningNotified = "warning_notified"
        case criticalNotified = "critical_notified"
        case lastPercentage = "last_percentage"
    }
}

extension NotificationState {
    /// Reset tracking when usage drops below thresholds
    mutating func resetIfNeeded(currentPercentage: Double, warningThreshold: Double, criticalThreshold: Double) {
        if currentPercentage < warningThreshold {
            warningNotified = false
        }
        if currentPercentage < criticalThreshold {
            criticalNotified = false
        }
        lastPercentage = currentPercentage
    }

    /// Check if threshold should trigger notification
    func shouldNotify(
        currentPercentage: Double,
        threshold: Double,
        isWarning: Bool
    ) -> Bool {
        // Check if crossing warning threshold
        if isWarning && !warningNotified && currentPercentage >= threshold {
            return true
        }
        // Check if crossing critical threshold
        if !isWarning && !criticalNotified && currentPercentage >= threshold {
            return true
        }
        return false
    }

    /// Check if session reset should trigger notification
    func shouldNotifyReset(currentPercentage: Double) -> Bool {
        lastPercentage > 0 && currentPercentage == 0
    }
}
