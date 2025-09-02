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
    @Published var userProfile: Usuario?
    @Published var loading = false
    @Published var errorMessage = ""
    
    private let supabase = FinanzasSupabaseManager.shared.client
    private let userService = UserService.instance
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
                    print("🔐 DEBUG: Evento signedIn - Verificando userProfile...")
                    
                    // Only mark as authenticated after successfully fetching userProfile
                    Task {
                        do {
                            let usuario = try await userService.fetchOrCreateUserProfile(
                                authUserId: session.user.id.uuidString,
                                email: session.user.email,
                                name: nil
                            )
                            
                            await MainActor.run {
                                isAuthenticated = true
                                currentUser = session.user
                                userProfile = usuario
                                print("✅ DEBUG: SignIn exitoso - DB ID: \(usuario.id)")
                            }
                        } catch {
                            await MainActor.run {
                                isAuthenticated = false
                                currentUser = nil
                                userProfile = nil
                                errorMessage = "Error validando usuario: \(error.localizedDescription)"
                                print("❌ DEBUG: Error en signIn: \(error)")
                            }
                        }
                    }
                }
            case .signedOut:
                isAuthenticated = false
                currentUser = nil
                userProfile = nil
                print("🚪 DEBUG: Usuario desconectado")
            case .tokenRefreshed:
                if let session = session {
                    currentUser = session.user
                    print("🔄 DEBUG: Token refrescado")
                }
            default:
                break
            }
        }
    }
    
    private func checkInitialAuthState() async {
        do {
            let session = try await supabase.auth.session
            print("🔐 DEBUG: Sesión encontrada, verificando validez...")
            
            // Try to fetch user profile to validate session
            do {
                let usuario = try await userService.fetchOrCreateUserProfile(
                    authUserId: session.user.id.uuidString,
                    email: session.user.email,
                    name: nil
                )
                
                // Only mark as authenticated if we have both session AND valid userProfile
                await MainActor.run {
                    isAuthenticated = true
                    currentUser = session.user
                    userProfile = usuario
                    print("✅ DEBUG: Sesión válida - Usuario autenticado con DB ID: \(usuario.id)")
                }
            } catch {
                // Session exists but userProfile failed - force login
                print("❌ DEBUG: Sesión inválida o userProfile falló: \(error)")
                await MainActor.run {
                    isAuthenticated = false
                    currentUser = nil
                    userProfile = nil
                    print("🚪 DEBUG: Redirigiendo a login...")
                }
            }
        } catch {
            print("❌ DEBUG: No hay sesión válida: \(error)")
            await MainActor.run {
                isAuthenticated = false
                currentUser = nil
                userProfile = nil
                print("🚪 DEBUG: Mostrando login...")
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
    

    

    
    func signOut() async {
        do {
            try await supabase.auth.signOut()
            await MainActor.run {
                isAuthenticated = false
                currentUser = nil
                userProfile = nil
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
