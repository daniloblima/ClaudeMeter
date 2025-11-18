//
//  SettingsCoordinator.swift
//  ClaudeMeter
//
//  Created by Edd on 2025-11-14.
//

import AppKit
import SwiftUI

/// Coordinator for settings window navigation
@MainActor
final class SettingsCoordinator: NSObject, SettingsCoordinatorProtocol, NSWindowDelegate {
    private var window: NSWindow?
    private let container: DIContainer

    init(container: DIContainer) {
        self.container = container
        super.init()
    }

    /// Show the settings window
    func showSettings() {
        if let existingWindow = window {
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        // Create settings view model
        let viewModel = SettingsViewModel(
            keychainRepository: container.keychainRepository,
            settingsRepository: container.settingsRepository,
            usageService: container.usageService,
            notificationService: container.notificationService
        )

        // Create settings view
        let settingsView = SettingsView(viewModel: viewModel)
        let hostingController = NSHostingController(rootView: settingsView)

        let newWindow = NSWindow(contentViewController: hostingController)
        newWindow.title = "Settings"
        newWindow.styleMask = [.titled, .closable]
        newWindow.setContentSize(NSSize(width: 500, height: 540))
        newWindow.center()
        newWindow.delegate = self
        newWindow.makeKeyAndOrderFront(nil)

        // Show dock icon during settings
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        self.window = newWindow
    }

    /// Close the settings window
    func closeSettings() {
        window?.close()
        window = nil

        // Hide dock icon
        NSApp.setActivationPolicy(.accessory)
    }

    /// Handle settings changes
    func handleSettingsChanged() {
        // Post notification for settings changes
        NotificationCenter.default.post(
            name: .settingsDidChange,
            object: nil
        )
    }

    // MARK: - NSWindowDelegate

    func windowWillClose(_ notification: Notification) {
        // Restore accessory mode when window closes
        window = nil
        NSApp.setActivationPolicy(.accessory)
    }
}
