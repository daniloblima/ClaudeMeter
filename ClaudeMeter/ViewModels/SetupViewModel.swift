//
//  SetupViewModel.swift
//  ClaudeMeter
//
//  Created by Edd on 2025-11-14.
//

import Foundation
import SwiftUI
import Combine

/// ViewModel for setup wizard
@MainActor
final class SetupViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var sessionKeyInput: String = ""
    @Published var isValidating: Bool = false
    @Published var errorMessage: String?
    @Published var validationSuccess: Bool = false

    // MARK: - Dependencies

    private let keychainRepository: KeychainRepositoryProtocol
    private let usageService: UsageServiceProtocol
    private let settingsRepository: SettingsRepositoryProtocol

    // MARK: - Callbacks

    var onSetupComplete: (() -> Void)?

    // MARK: - Initialization

    init(
        keychainRepository: KeychainRepositoryProtocol,
        usageService: UsageServiceProtocol,
        settingsRepository: SettingsRepositoryProtocol
    ) {
        self.keychainRepository = keychainRepository
        self.usageService = usageService
        self.settingsRepository = settingsRepository
    }

    // MARK: - Actions

    /// Validate session key format
    var isFormatValid: Bool {
        let trimmed = sessionKeyInput.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.hasPrefix("sk-ant-") && trimmed.count > 10
    }

    /// Validate and save session key
    func validateAndSave() async {
        isValidating = true
        errorMessage = nil

        do {
            // Validate format
            let sessionKey = try SessionKey(sessionKeyInput)

            // Validate with API
            let isValid = try await usageService.validateSessionKey(sessionKey)

            guard isValid else {
                errorMessage = "Session key is invalid or expired"
                isValidating = false
                return
            }

            // Fetch organizations to cache org ID
            let organizations = try await usageService.fetchOrganizations(sessionKey: sessionKey)
            guard let firstOrg = organizations.first,
                  let orgUUID = firstOrg.organizationUUID else {
                errorMessage = "No organizations found for this account"
                isValidating = false
                return
            }

            // Save to Keychain
            try await keychainRepository.save(
                sessionKey: sessionKey.value,
                account: "default"
            )

            // Update settings with cached org ID
            var settings = await settingsRepository.load()
            settings.cachedOrganizationId = orgUUID
            settings.isFirstLaunch = false
            try await settingsRepository.save(settings)

            validationSuccess = true
            isValidating = false

            // Trigger setup completion callback
            onSetupComplete?()

        } catch let error as SessionKeyError {
            errorMessage = error.localizedDescription
            isValidating = false
        } catch let error as NetworkError {
            errorMessage = "Network error: \(error.localizedDescription)"
            isValidating = false
        } catch let error as AppError {
            errorMessage = error.localizedDescription
            isValidating = false
        } catch {
            errorMessage = "Validation failed: \(error.localizedDescription)"
            isValidating = false
        }
    }
}
