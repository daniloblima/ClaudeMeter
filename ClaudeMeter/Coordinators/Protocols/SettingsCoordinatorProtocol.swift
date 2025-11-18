//
//  SettingsCoordinatorProtocol.swift
//  ClaudeMeter
//
//  Created by Edd on 2025-11-14.
//

import Foundation

/// Protocol for settings window navigation coordination
@MainActor
protocol SettingsCoordinatorProtocol {
    /// Show the settings window
    func showSettings()

    /// Close the settings window
    func closeSettings()

    /// Handle settings changes
    func handleSettingsChanged()
}
