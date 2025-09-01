//
//  ContentView.swift
//  finanzas-personales-app
//
//  Main content view that handles authentication state
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var movementViewModel: MovementViewModel
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                MainTabView()
                                    .onAppear {
                    Task {
                        if authService.isDemoMode {
                            await movementViewModel.loadData(isDemoMode: true)
                        } else if let userId = authService.currentUser?.id {
                            await movementViewModel.loadData(userId: userId.uuidString)
                        }
                    }
                }
            } else {
                AuthView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthService())
        .environmentObject(MovementViewModel())
}
