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
                        if let userProfile = authService.userProfile {
                            print("🎯 DEBUG: Cargando datos para usuario DB ID: \(userProfile.id)")
                            await movementViewModel.loadData(userId: userProfile.id)
                        } else {
                            print("❌ DEBUG: No hay usuario disponible para cargar datos")
                        }
                    }
                }
                .onChange(of: authService.userProfile) { oldValue, newValue in
                    // Reload data whenever userProfile changes (gets loaded)
                    Task {
                        if let userProfile = newValue {
                            print("🎯 DEBUG: Usuario cargado, recargando datos para DB ID: \(userProfile.id)")
                            await movementViewModel.loadData(userId: userProfile.id)
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
