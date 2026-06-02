//
//  CH3App.swift
//  CH3
//
//  Created by Javohir Muhammad on 28/05/26.
//

import SwiftUI

@main
struct CH3App: App {
    @State private var isRegistered = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await registerDevice()
                }
        }
    }

    /// Register this device with the backend.
    /// Idempotent — backend returns 200 if already registered.
    private func registerDevice() async {
        let deviceId = DeviceIdentityService.shared.deviceId
        do {
            _ = try await UserService.shared.register(deviceId: deviceId)
            isRegistered = true
        } catch {
            // Registration failed — the app can still function in offline mode.
            // The error will surface when API calls are attempted.
            print("[CH3App] Device registration failed: \(error.localizedDescription)")
        }
    }
}
