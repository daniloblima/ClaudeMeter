//
//  SetupCoordinator.swift
//  ClaudeMeter
//
//  Created by Edd on 2025-11-14.
//

import AppKit
import SwiftUI

/// Coordinator for setup wizard navigation
@MainActor
final class SetupCoordinator: SetupCoordinatorProtocol {
    private var window: NSWindow?
    private let container: DIContainer
    private var onSetupComplete: (() -> Void)?

    init(container: DIContainer, onSetupComplete: @escaping () -> Void) {
        self.container = container
        self.onSetupComplete = onSetupComplete
    }

    /// Show the setup wizard window
    func showSetup() {
        if let existingWindow = window {
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        // Create ViewModel with completion callback
        let viewModel = SetupViewModel(
            keychainRepository: container.keychainRepository,
            usageService: container.usageService,
            settingsRepository: container.settingsRepository
        )

        viewModel.onSetupComplete = { [weak self] in
            self?.handleSetupComplete()
        }

        // Create SwiftUI view
        let setupView = SetupWizardView(viewModel: viewModel)
        let hostingController = NSHostingController(rootView: setupView)

        // Create window
        let newWindow = NSWindow(contentViewController: hostingController)
        newWindow.title = "ClaudeMeter Setup"
        newWindow.styleMask = [.titled, .closable]
        newWindow.setContentSize(NSSize(width: 500, height: 400))
        newWindow.center()
        newWindow.makeKeyAndOrderFront(nil)

        // Show dock icon during setup
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        self.window = newWindow
    }

    /// Close the setup wizard window
    func closeSetup() {
        window?.close()
        window = nil

        // Hide dock icon after setup
        NSApp.setActivationPolicy(.accessory)
    }

    /// Handle setup completion
    func handleSetupComplete() {
        // Small delay to show success message
        Task {
            try? await Task.sleep(for: .seconds(1))
            closeSetup()
            onSetupComplete?()
        }
    }
}
