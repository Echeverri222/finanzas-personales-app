//
//  DatabaseService.swift
//  finanzas-personales-app
//
//  Database service for all Supabase operations
//

import Foundation
import Supabase

class DatabaseService {
    static let instance = DatabaseService()
    
    private let supabase = FinanzasSupabaseManager.shared.client
    private init() {}
    
    // MARK: - Movement Types
    
    func fetchMovementTypes(for userId: Int) async throws -> [MovementType] {
        let response: [MovementType] = try await supabase
            .from("tipo_movimiento")
            .select()
            .eq("usuario_id", value: userId)
            .order("created_at", ascending: true)
            .execute()
            .value
        
        return response
    }
    
    func createMovementType(_ type: MovementType) async throws -> MovementType {
        let response: MovementType = try await supabase
            .from("tipo_movimiento")
            .insert(type)
            .select()
            .single()
            .execute()
            .value
        
        return response
    }
    
    // MARK: - Movements
    
    func fetchMovements(for userId: Int) async throws -> [Movement] {
        // First get the movement types
        let movementTypes = try await fetchMovementTypes(for: userId)
        
        // Then get movements
        let movementsResponse: [Movement] = try await supabase
            .from("movimientos")
            .select()
            .eq("usuario_id", value: userId)
            .order("fecha", ascending: false)
            .execute()
            .value
        
        // Manually join the data
        var movements = movementsResponse
        for i in 0..<movements.count {
            if let tipo = movementTypes.first(where: { $0.id == movements[i].idTipoMovimiento }) {
                movements[i].tipoNombre = tipo.nombre
                movements[i].tipoMeta = tipo.meta
            }
        }
        
        return movements
    }
    
    func createMovement(_ movement: Movement) async throws -> Movement {
        let response: Movement = try await supabase
            .from("movimientos")
            .insert(movement)
            .select()
            .single()
            .execute()
            .value
        
        return response
    }
    
    func updateMovement(_ movement: Movement) async throws -> Movement {
        guard let id = movement.id else {
            throw DatabaseError.invalidData
        }
        
        let response: Movement = try await supabase
            .from("movimientos")
            .update(movement)
            .eq("id", value: id)
            .select()
            .single()
            .execute()
            .value
        
        return response
    }
    
    func deleteMovement(id: Int, userId: String) async throws {
        try await supabase
            .from("movimientos")
            .delete()
            .eq("id", value: id)
            .eq("usuario_id", value: userId)
            .execute()
    }
    

}

// MARK: - Database Errors

enum DatabaseError: LocalizedError {
    case noData
    case invalidData
    case parseError
    
    var errorDescription: String? {
        switch self {
        case .noData:
            return "No data received from database"
        case .invalidData:
            return "Invalid data format"
        case .parseError:
            return "Failed to parse database response"
        }
    }
}
