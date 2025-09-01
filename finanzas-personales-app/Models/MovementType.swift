//
//  MovementType.swift
//  finanzas-personales-app
//
//  Data model for movement types/categories
//

import Foundation

struct MovementType: Identifiable, Codable, Hashable {
    let id: Int?
    let nombre: String
    let meta: Double
    let usuarioId: String
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case nombre
        case meta
        case usuarioId = "usuario_id"
        case createdAt = "created_at"
    }
    
    init(id: Int? = nil, nombre: String, meta: Double = 0, usuarioId: String, createdAt: Date? = nil) {
        self.id = id
        self.nombre = nombre
        self.meta = meta
        self.usuarioId = usuarioId
        self.createdAt = createdAt
    }
    
    var categoryColor: String {
        switch nombre {
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
