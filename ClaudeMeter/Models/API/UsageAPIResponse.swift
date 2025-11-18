//
//  UsageAPIResponse.swift
//  ClaudeMeter
//
//  Created by Edd on 2025-11-14.
//

import Foundation

/// API response for usage data
struct UsageAPIResponse: Codable {
    let fiveHour: UsageLimitResponse
    let sevenDay: UsageLimitResponse
    let sevenDayOpus: UsageLimitResponse?

    enum CodingKeys: String, CodingKey {
        case fiveHour = "five_hour"
        case sevenDay = "seven_day"
        case sevenDayOpus = "seven_day_opus"
    }
}

/// Individual usage limit response from API
struct UsageLimitResponse: Codable {
    let utilization: Double // Percentage 0-100
    let resetsAt: String? // ISO8601 string, can be null

    enum CodingKeys: String, CodingKey {
        case utilization
        case resetsAt = "resets_at"
    }
}

/// Mapping error for API response conversion
enum MappingError: LocalizedError {
    case invalidDateFormat
    case missingCriticalField(field: String)

    var errorDescription: String? {
        switch self {
        case .invalidDateFormat:
            return "Server returned invalid date format"
        case .missingCriticalField(let field):
            return "Server response missing critical field: \(field)"
        }
    }
}

/// Extension to map API response to domain model
extension UsageAPIResponse {
    func toDomain(timezone: TimeZone = .current) throws -> UsageData {
        // Configure ISO8601 formatter with proper options
        let iso8601Formatter = ISO8601DateFormatter()
        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        // Convert utilization percentage to tokens (use 100 as limit for direct percentage mapping)
        // This allows the domain model's percentage calculation to work correctly
        let sessionTokensUsed = Int(fiveHour.utilization)
        let weeklyTokensUsed = Int(sevenDay.utilization)

        // Parse reset dates (must be present and valid)
        let sessionResetDate: Date
        let weeklyResetDate: Date

        guard let sessionResetString = fiveHour.resetsAt,
              let parsedDate = iso8601Formatter.date(from: sessionResetString) else {
            throw MappingError.missingCriticalField(field: "fiveHour.resetsAt")
        }
        sessionResetDate = parsedDate

        guard let weeklyResetString = sevenDay.resetsAt,
              let parsedDate = iso8601Formatter.date(from: weeklyResetString) else {
            throw MappingError.missingCriticalField(field: "sevenDay.resetsAt")
        }
        weeklyResetDate = parsedDate

        // Handle optional opus usage
        let opusLimit: UsageLimit? = sevenDayOpus.flatMap { opus in
            let opusTokensUsed = Int(opus.utilization)
            let opusResetDate: Date

            if let opusResetString = opus.resetsAt,
               let parsedDate = iso8601Formatter.date(from: opusResetString) {
                opusResetDate = parsedDate
            } else {
                // Default to 7 days in the future if no reset date
                opusResetDate = Date().addingTimeInterval(7 * 24 * 3600)
            }

            return UsageLimit(
                tokensUsed: opusTokensUsed,
                tokensLimit: 100,
                resetAt: opusResetDate
            )
        }

        return UsageData(
            sessionUsage: UsageLimit(
                tokensUsed: sessionTokensUsed,
                tokensLimit: 100,
                resetAt: sessionResetDate
            ),
            weeklyUsage: UsageLimit(
                tokensUsed: weeklyTokensUsed,
                tokensLimit: 100,
                resetAt: weeklyResetDate
            ),
            opusUsage: opusLimit,
            lastUpdated: Date(),
            timezone: timezone
        )
    }
}
