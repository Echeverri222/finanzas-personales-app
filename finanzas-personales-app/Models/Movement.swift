//
//  Movement.swift
//  finanzas-personales-app
//
//  Data model for financial movements
//

import Foundation

struct Movement: Identifiable, Codable, Hashable {
    let id: Int?
    let nombre: String
    let importe: Double
    let fecha: Date
    let descripcion: String?
    let idTipoMovimiento: Int
    let usuarioId: String
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
    
    init(id: Int? = nil, nombre: String, importe: Double, fecha: Date, descripcion: String? = nil, idTipoMovimiento: Int, usuarioId: String, createdAt: Date? = nil) {
        self.id = id
        self.nombre = nombre
        self.importe = importe
        self.fecha = fecha
        self.descripcion = descripcion
        self.idTipoMovimiento = idTipoMovimiento
        self.usuarioId = usuarioId
        self.createdAt = createdAt
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
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
    
    var categoryColor: String {
        switch tipoNombre {
        case "Ingresos":
            return "green"
        case "Ahorro":
            return "blue"
        case "Alimentacion":
            return "orange"
        case "Transporte":
            return "purple"
        case "Compras":
            return "pink"
        case "Gastos fijos":
            return "yellow"
        case "Salidas":
            return "cyan"
        default:
            return "gray"
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
