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
            print("👤 DEBUG: Query usuarios con user_id: \(authUserId)")
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
            print("👤 DEBUG: Error en búsqueda: \(error)")
            print("👤 DEBUG: Usuario no encontrado, creando nuevo...")
            
            // User doesn't exist, create new profile
                    let createRequest = CreateUsuarioRequest(
            userId: authUserId,
            email: email ?? "user@example.com",
            nombre: name // Keep as optional
        )
            
            print("👤 DEBUG: Creando usuario con datos: \(createRequest)")
            
            do {
                let newUsuario: Usuario = try await supabase
                    .from("usuarios")
                    .insert(createRequest)
                    .select()
                    .single()
                    .execute()
                    .value
                
                print("👤 DEBUG: Nuevo usuario creado con DB ID: \(newUsuario.id)")
                return newUsuario
            } catch let insertError {
                print("👤 DEBUG: Error al crear usuario: \(insertError)")
                // If user already exists (duplicate key), try to fetch it again
                if insertError.localizedDescription.contains("duplicate key") || insertError.localizedDescription.contains("23505") {
                    print("👤 DEBUG: Usuario ya existe, intentando búsqueda alternativa...")
                    // Try a different approach to find the user
                    let usuarios: [Usuario] = try await supabase
                        .from("usuarios")
                        .select()
                        .eq("user_id", value: authUserId)
                        .execute()
                        .value
                    
                    if let usuario = usuarios.first {
                        print("👤 DEBUG: Usuario encontrado en segunda búsqueda con DB ID: \(usuario.id)")
                        return usuario
                    }
                }
                throw insertError
            }
        }
    }
    
    /// Update user profile
    func updateUserProfile(authUserId: String, nombre: String? = nil, email: String? = nil) async throws {
        var updates: [String: String] = [:]
        
        if let nombre = nombre {
            updates["nombre"] = nombre
        }
        if let email = email {
            updates["email"] = email
        }
        
        guard !updates.isEmpty else { return }
        
        let _ = try await supabase
            .from("usuarios")
            .update(updates)
            .eq("user_id", value: authUserId)
            .execute()
    }
}
