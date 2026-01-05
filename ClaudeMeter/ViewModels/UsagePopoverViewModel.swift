//
//  UsagePopoverViewModel.swift
//  ClaudeMeter
//
//  Created by Edd on 2025-11-14.
//

import Foundation
import Combine

/// ViewModel for usage popover
@MainActor
final class UsagePopoverViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var usageData: UsageData?
    @Published var isRefreshing: Bool = false
    @Published var errorMessage: String?
    @Published var isSonnetUsageShown: Bool = false

    // MARK: - Dependencies

    private let settingsRepository: SettingsRepositoryProtocol
    private let onRefreshRequest: (() async -> Void)?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(
        settingsRepository: SettingsRepositoryProtocol,
        onRefreshRequest: (() async -> Void)? = nil
    ) {
        self.settingsRepository = settingsRepository
        self.onRefreshRequest = onRefreshRequest

        // Load initial settings
        Task {
            await loadSettings()
        }

        // Listen for settings changes
        NotificationCenter.default.publisher(for: .settingsDidChange)
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    await self?.loadSettings()
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    /// Load settings from repository
    private func loadSettings() async {
        let settings = await settingsRepository.load()
        self.isSonnetUsageShown = settings.isSonnetUsageShown
    }

    /// Manual refresh - delegates to parent via callback
    func refresh() async {
        guard let onRefreshRequest = onRefreshRequest else { return }
        isRefreshing = true
        errorMessage = nil
        await onRefreshRequest()
        isRefreshing = false
    }
}
