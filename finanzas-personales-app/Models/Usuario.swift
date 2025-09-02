//
//  Usuario.swift
//  finanzas-personales-app
//
//  Usuario model for mapping auth user to database user
//

import Foundation

struct Usuario: Identifiable, Codable, Equatable {
    let id: String // Database ID (String UUID, primary key)
    let userId: String // Auth user ID from Supabase (String UUID)
    let email: String
    let nombre: String? // Can be null in database
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case email
        case nombre
        case createdAt = "created_at"
    }
    
    // Custom decoder to handle date formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        email = try container.decode(String.self, forKey: .email)
        nombre = try container.decodeIfPresent(String.self, forKey: .nombre)
        
        // Handle createdAt date
        if let createdAtString = try container.decodeIfPresent(String.self, forKey: .createdAt) {
            createdAt = Self.decodeDate(from: createdAtString)
        } else {
            createdAt = nil
        }
    }
    
    static func decodeDate(from dateString: String) -> Date? {
        // Try ISO 8601 format first (with time)
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: dateString) {
            return date
        }
        
        // Try date-only format (YYYY-MM-DD)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current
        if let date = dateFormatter.date(from: dateString) {
            return date
        }
        
        // Try with timestamp format
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS+HH:mm"
        if let date = dateFormatter.date(from: dateString) {
            return date
        }
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss+HH:mm"
        if let date = dateFormatter.date(from: dateString) {
            return date
        }
        
        return nil
    }
}

struct CreateUsuarioRequest: Codable {
    let userId: String
    let email: String
    let nombre: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email
        case nombre
    }
}
