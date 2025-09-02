//
//  MovementType.swift
//  finanzas-personales-app
//
//  Data model for movement types/categories
//

import Foundation
import SwiftUI

struct MovementType: Identifiable, Codable, Hashable {
    let id: String?
    let nombre: String
    let meta: Double
    let usuarioId: String // References usuarios.id (String UUID)
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case nombre
        case meta
        case usuarioId = "usuario_id"
        case createdAt = "created_at"
    }
    
    init(id: String? = nil, nombre: String, meta: Double = 0, usuarioId: String, createdAt: Date? = nil) {
        self.id = id
        self.nombre = nombre
        self.meta = meta
        self.usuarioId = usuarioId
        self.createdAt = createdAt
    }
    
    // Custom decoder to handle date formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(String.self, forKey: .id)
        nombre = try container.decode(String.self, forKey: .nombre)
        meta = try container.decode(Double.self, forKey: .meta)
        usuarioId = try container.decode(String.self, forKey: .usuarioId)
        
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
    
    var categoryColor: Color {
        switch nombre {
        case "Ingresos":
            return .green
        case "Ahorro":
            return .blue
        case "Alimentacion":
            return .orange
        case "Transporte":
            return .purple
        case "Compras":
            return .pink
        case "Gastos fijos":
            return .yellow
        case "Salidas":
            return .cyan
        default:
            return .gray
        }
    }
    
    var categoryIcon: String {
        switch nombre {
        case "Ingresos":
            return "dollarsign.circle.fill"
        case "Ahorro":
            return "banknote.fill"
        case "Alimentacion":
            return "fork.knife"
        case "Transporte":
            return "car.fill"
        case "Compras":
            return "bag.fill"
        case "Gastos fijos":
            return "house.fill"
        case "Salidas":
            return "party.popper.fill"
        default:
            return "questionmark.circle.fill"
        }
    }
}
