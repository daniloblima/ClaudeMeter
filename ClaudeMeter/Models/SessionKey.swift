//
//  SessionKey.swift
//  ClaudeMeter
//
//  Created by Edd on 2025-11-14.
//

import Foundation

/// Errors that can occur when working with session keys
enum SessionKeyError: LocalizedError {
    case invalidFormat
    case tooShort
    case validationFailed

    var errorDescription: String? {
        switch self {
        case .invalidFormat:
            return "Session key must start with 'sk-ant-'"
        case .tooShort:
            return "Session key is too short"
        case .validationFailed:
            return "Session key could not be validated with Claude API"
        }
    }
}

/// Validated Claude session key
/// Note: Not Codable to prevent accidental serialization - use Keychain instead
struct SessionKey: Equatable, Sendable {
    /// The session key value (format: sk-ant-*)
    let value: String

    /// Organization associated with this key (cached)
    var organizationId: UUID?

    /// Throwing initializer that validates format
    init(_ value: String) throws {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmed.hasPrefix("sk-ant-") else {
            throw SessionKeyError.invalidFormat
        }

        guard trimmed.count > 10 else {
            throw SessionKeyError.tooShort
        }

        self.value = trimmed
    }
}
