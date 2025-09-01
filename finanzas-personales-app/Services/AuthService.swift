//
//  AuthService.swift
//  finanzas-personales-app
//
//  Authentication service using Supabase Auth
//

import Foundation
import Supabase
import Combine

@MainActor
class AuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var loading = false
    @Published var errorMessage = ""
    
    private let supabase = FinanzasSupabaseManager.shared.client
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Check initial auth state
        Task {
            await checkInitialAuthState()
        }
        
        // Listen to auth state changes
        Task {
            for await (event, session) in supabase.auth.authStateChanges {
                handleAuthStateChange(event: event, session: session)
            }
        }
    }
    
    private func handleAuthStateChange(event: AuthChangeEvent, session: Session?) {
        Task { @MainActor in
            switch event {
            case .signedIn:
                if let session = session {
                    isAuthenticated = true
                    currentUser = session.user
                }
            case .signedOut:
                isAuthenticated = false
                currentUser = nil
            case .tokenRefreshed:
                if let session = session {
                    currentUser = session.user
                }
            default:
                break
            }
        }
    }
    
    private func checkInitialAuthState() async {
        do {
            let session = try await supabase.auth.session
            await MainActor.run {
                isAuthenticated = session.user != nil
                currentUser = session.user
            }
        } catch {
            print("Error checking auth state: \(error)")
            await MainActor.run {
                isAuthenticated = false
                currentUser = nil
            }
        }
    }
    
    // MARK: - Google Sign In
    
    func signInWithGoogle() async {
        await MainActor.run {
            loading = true
            errorMessage = ""
        }
        
        do {
            // Using Supabase OAuth with Google provider
            try await supabase.auth.signInWithOAuth(
                provider: .google,
                redirectTo: URL(string: "finanzas-personales-app://auth/callback")
            )
            
            await MainActor.run {
                errorMessage = "¡Iniciando sesión con Google!"
            }
        } catch {
            await MainActor.run {
                errorMessage = "Error al iniciar sesión con Google: \(error.localizedDescription)"
            }
        }
        
        await MainActor.run {
            loading = false
        }
    }
    
    // MARK: - OAuth Callback Handling
    
    func handleOAuthCallback(_ url: URL) async {
        print("🔗 OAuth callback received: \(url.absoluteString)")
        
        do {
            _ = try await supabase.auth.session(from: url)
            await checkInitialAuthState()
            
            await MainActor.run {
                errorMessage = "¡Autenticación con Google exitosa!"
            }
        } catch {
            await MainActor.run {
                errorMessage = "Error procesando autenticación: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Demo Mode for Development
    
    func signInDemo() async {
        await MainActor.run {
            loading = true
            errorMessage = ""
        }
        
        // Create a demo user session
        await MainActor.run {
            isAuthenticated = true
            // Create a fake user for demo purposes
            currentUser = nil // We'll handle this differently
            errorMessage = "¡Sesión demo iniciada! Todas las funciones están disponibles."
            loading = false
        }
    }
    
    var isDemoMode: Bool {
        return isAuthenticated && (currentUser == nil)
    }
    
    func signOut() async {
        do {
            try await supabase.auth.signOut()
            await MainActor.run {
                isAuthenticated = false
                currentUser = nil
            }
        } catch {
            await MainActor.run {
                errorMessage = "Error al cerrar sesión: \(error.localizedDescription)"
            }
        }
    }
    
    func refreshSession() async {
        do {
            try await supabase.auth.refreshSession()
            let session = try await supabase.auth.session
            await MainActor.run {
                currentUser = session.user
            }
        } catch {
            print("Error refreshing session: \(error)")
        }
    }
}
