//
//  Usuario.swift
//  finanzas-personales-app
//
//  Usuario model for mapping auth user to database user
//

import Foundation

struct Usuario: Identifiable, Codable {
    let id: Int
    let userId: String // Auth user ID from Supabase
    let email: String
    let nombre: String
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case email
        case nombre
        case createdAt = "created_at"
    }
}

struct CreateUsuarioRequest: Codable {
    let userId: String
    let email: String
    let nombre: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email
        case nombre
    }
}
