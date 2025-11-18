//
//  ClaudeMeterApp.swift
//  ClaudeMeter
//
//  Created by Edd on 2025-11-14.
//

import SwiftUI
import AppKit

/// Main app entry point
@main
struct ClaudeMeterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

/// App delegate to handle menu bar app lifecycle
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var appCoordinator: AppCoordinator?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize coordinator and start app flow
        let coordinator = AppCoordinator(container: DIContainer.shared)
        self.appCoordinator = coordinator

        Task {
            await coordinator.start()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Don't terminate when windows close (menu bar app behavior)
        return false
    }
}
