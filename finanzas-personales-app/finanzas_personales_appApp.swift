//
//  finanzas_personales_appApp.swift
//  finanzas-personales-app
//
//  Created by MacBook Air M2 22C 100% on 30/08/25.
//

import SwiftUI

@main
struct finanzas_personales_appApp: App {
    @StateObject private var authService = AuthService()
    @StateObject private var movementViewModel = MovementViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .environmentObject(movementViewModel)
                .onOpenURL { url in
                    // Handle OAuth callbacks from Google Sign-In
                    Task {
                        await authService.handleOAuthCallback(url)
                    }
                }
        }
    }
}