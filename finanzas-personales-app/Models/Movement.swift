//
//  Movement.swift
//  finanzas-personales-app
//
//  Data model for financial movements
//

import Foundation
import SwiftUI

struct Movement: Identifiable, Codable, Hashable {
    let id: String?
    let nombre: String
    let importe: Double
    let fecha: Date
    let descripcion: String?
    let idTipoMovimiento: String
    let usuarioId: String // References usuarios.id (String UUID)
    let createdAt: Date?
    
    // Related data from JOIN (mutable for manual assignment)
    var tipoNombre: String?
    var tipoMeta: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case nombre
        case importe
        case fecha
        case descripcion
        case idTipoMovimiento = "id_tipo_movimiento"
        case usuarioId = "usuario_id"
        case createdAt = "created_at"
        case tipoNombre = "tipo_nombre"
        case tipoMeta = "tipo_meta"
    }
    
    init(id: String? = nil, nombre: String, importe: Double, fecha: Date, descripcion: String? = nil, idTipoMovimiento: String, usuarioId: String, createdAt: Date? = nil) {
        self.id = id
        self.nombre = nombre
        self.importe = importe
        self.fecha = fecha
        self.descripcion = descripcion
        self.idTipoMovimiento = idTipoMovimiento
        self.usuarioId = usuarioId
        self.createdAt = createdAt
    }
    
    // Custom decoder to handle date formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(String.self, forKey: .id)
        nombre = try container.decode(String.self, forKey: .nombre)
        importe = try container.decode(Double.self, forKey: .importe)
        descripcion = try container.decodeIfPresent(String.self, forKey: .descripcion)
        idTipoMovimiento = try container.decode(String.self, forKey: .idTipoMovimiento)
        usuarioId = try container.decode(String.self, forKey: .usuarioId)
        tipoNombre = try container.decodeIfPresent(String.self, forKey: .tipoNombre)
        tipoMeta = try container.decodeIfPresent(Double.self, forKey: .tipoMeta)
        
        // Handle date decoding with multiple formats
        let dateString = try container.decode(String.self, forKey: .fecha)
        fecha = Self.decodeDate(from: dateString) ?? Date()
        
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
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: importe)) ?? "$0"
    }
    
    var isIncome: Bool {
        return tipoNombre == "Ingresos"
    }
    
    var isExpense: Bool {
        return !isIncome && tipoNombre != "Ahorro"
    }
    
    var isSaving: Bool {
        return tipoNombre == "Ahorro"
    }
    
    var categoryColor: Color {
        switch tipoNombre {
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
        switch tipoNombre {
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
    
    // MARK: - Hashable Implementation
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(nombre)
        hasher.combine(importe)
        hasher.combine(fecha)
        hasher.combine(descripcion)
        hasher.combine(idTipoMovimiento)
        hasher.combine(usuarioId)
        // Exclude tipoNombre and tipoMeta as they are mutable
    }
    
    static func == (lhs: Movement, rhs: Movement) -> Bool {
        return lhs.id == rhs.id &&
               lhs.nombre == rhs.nombre &&
               lhs.importe == rhs.importe &&
               lhs.fecha == rhs.fecha &&
               lhs.descripcion == rhs.descripcion &&
               lhs.idTipoMovimiento == rhs.idTipoMovimiento &&
               lhs.usuarioId == rhs.usuarioId
    }
}
