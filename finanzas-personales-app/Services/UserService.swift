//
//  UserService.swift
//  finanzas-personales-app
//
//  Service for managing user profile mapping between auth and database
//

import Foundation
import Supabase

class UserService {
    static let instance = UserService()
    
    private let supabase = FinanzasSupabaseManager.shared.client
    private init() {}
    
    // MARK: - User Profile Management
    
    /// Fetch or create user profile from usuarios table using auth user ID
    func fetchOrCreateUserProfile(authUserId: String, email: String?, name: String?) async throws -> Usuario {
        print("👤 DEBUG: Buscando usuario con auth ID: \(authUserId)")
        
        // First try to fetch existing user
        do {
            let usuario: Usuario = try await supabase
                .from("usuarios")
                .select()
                .eq("user_id", value: authUserId)
                .single()
                .execute()
                .value
            
            print("👤 DEBUG: Usuario encontrado con DB ID: \(usuario.id)")
            return usuario
        } catch {
            print("👤 DEBUG: Usuario no encontrado, creando nuevo...")
            
            // User doesn't exist, create new profile
            let createRequest = CreateUsuarioRequest(
                userId: authUserId,
                email: email ?? "user@example.com",
                nombre: name ?? "Usuario"
            )
            
            let newUsuario: Usuario = try await supabase
                .from("usuarios")
                .insert(createRequest)
                .select()
                .single()
                .execute()
                .value
            
            print("👤 DEBUG: Nuevo usuario creado con DB ID: \(newUsuario.id)")
            return newUsuario
        }
    }
    
    /// Update user profile
    func updateUserProfile(authUserId: String, updates: [String: Any]) async throws {
        let _ = try await supabase
            .from("usuarios")
            .update(updates)
            .eq("user_id", value: authUserId)
            .execute()
    }
}
