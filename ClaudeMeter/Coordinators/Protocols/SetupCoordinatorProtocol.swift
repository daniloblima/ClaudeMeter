//
//  SetupCoordinatorProtocol.swift
//  ClaudeMeter
//
//  Created by Edd on 2025-11-14.
//

import Foundation

/// Protocol for setup wizard navigation coordination
@MainActor
protocol SetupCoordinatorProtocol {
    /// Show the setup wizard window
    func showSetup()

    /// Close the setup wizard window
    func closeSetup()

    /// Handle setup completion
    func handleSetupComplete()
}
