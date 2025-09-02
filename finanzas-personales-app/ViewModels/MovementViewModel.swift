//
//  MovementViewModel.swift
//  finanzas-personales-app
//
//  ViewModel for managing movements data and operations
//

import Foundation
import SwiftUI
import Combine

@MainActor
class MovementViewModel: ObservableObject {
    @Published var movements: [Movement] = []
    @Published var movementTypes: [MovementType] = []
    @Published var loading = false
    @Published var errorMessage = ""
    
    // Filters
    @Published var selectedYear = Calendar.current.component(.year, from: Date())
    @Published var selectedMonth: Int? = Calendar.current.component(.month, from: Date())
    @Published var selectedCategory: MovementType?
    
    private let databaseService = DatabaseService.instance
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Auto-refresh when filters change
        Publishers.CombineLatest3($selectedYear, $selectedMonth, $selectedCategory)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { _, _, _ in
                // Filtering is done in computed properties, no need to refetch
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Computed Properties
    
    var filteredMovements: [Movement] {
        var filtered = movements
        
        // Filter by year
        filtered = filtered.filter { movement in
            Calendar.current.component(.year, from: movement.fecha) == selectedYear
        }
        
        // Filter by month if selected
        if let month = selectedMonth {
            filtered = filtered.filter { movement in
                Calendar.current.component(.month, from: movement.fecha) == month
            }
        }
        
        // Filter by category if selected
        if let category = selectedCategory {
            filtered = filtered.filter { movement in
                movement.idTipoMovimiento == category.id
            }
        }
        
        return filtered.sorted { $0.fecha > $1.fecha }
    }
    
    var totalIncome: Double {
        filteredMovements
            .filter { $0.isIncome }
            .reduce(0) { $0 + $1.importe }
    }
    
    var totalExpenses: Double {
        filteredMovements
            .filter { $0.isExpense }
            .reduce(0) { $0 + $1.importe }
    }
    
    var totalSavings: Double {
        filteredMovements
            .filter { $0.isSaving }
            .reduce(0) { $0 + $1.importe }
    }
    
    var netBalance: Double {
        totalIncome - totalExpenses
    }
    
    var categoryExpenses: [CategoryExpense] {
        let expenses = filteredMovements.filter { $0.isExpense }
        
        let grouped = Dictionary(grouping: expenses) { $0.tipoNombre ?? "Sin categoría" }
        
        return grouped.compactMap { (category, movements) in
            let total = movements.reduce(0) { $0 + $1.importe }
            let color = movements.first?.categoryColor ?? .gray
            return CategoryExpense(name: category, amount: total, color: color)
        }.sorted { $0.amount > $1.amount }
    }
    
    var monthlyData: [MonthlyData] {
        let calendar = Calendar.current
        let yearMovements = movements.filter { movement in
            calendar.component(.year, from: movement.fecha) == selectedYear
        }
        
        let grouped = Dictionary(grouping: yearMovements) { movement in
            calendar.component(.month, from: movement.fecha)
        }
        
        return (1...12).compactMap { month in
            let monthMovements = grouped[month] ?? []
            let income = monthMovements.filter { $0.isIncome }.reduce(0) { $0 + $1.importe }
            let expenses = monthMovements.filter { $0.isExpense }.reduce(0) { $0 + $1.importe }
            
            let monthName = DateFormatter().monthSymbols[month - 1]
            
            return MonthlyData(
                month: String(monthName.prefix(3)),
                income: income,
                expenses: expenses,
                monthNumber: month
            )
        }
    }
    
    var availableYears: [Int] {
        let years = Set(movements.map { Calendar.current.component(.year, from: $0.fecha) })
        return Array(years).sorted(by: >)
    }
    
    // MARK: - Data Loading
    
    func loadData(userId: String) async {
        loading = true
        errorMessage = ""
        
        do {
            print("📊 DEBUG: Cargando datos para usuario ID: \(userId)")
            
            // Use String directly (usuarios.id is String UUID)
            async let movementsTask = databaseService.fetchMovements(for: userId)
            async let typesTask = databaseService.fetchMovementTypes(for: userId)
            
            let (fetchedMovements, fetchedTypes) = try await (movementsTask, typesTask)
            
            print("📊 DEBUG: Movimientos encontrados: \(fetchedMovements.count)")
            print("📊 DEBUG: Tipos encontrados: \(fetchedTypes.count)")
            
            movements = fetchedMovements
            movementTypes = fetchedTypes
        } catch {
            print("❌ DEBUG: Error cargando datos: \(error)")
            errorMessage = "Error loading data: \(error.localizedDescription)"
        }
        
        loading = false
    }
    

    
    func addMovement(_ movement: Movement) async {
        errorMessage = "" // Clear any previous error
        do {
            var newMovement = try await databaseService.createMovement(movement)
            
            // Manually assign the tipo information based on the loaded movement types
            if let tipo = movementTypes.first(where: { $0.id == newMovement.idTipoMovimiento }) {
                newMovement.tipoNombre = tipo.nombre
                newMovement.tipoMeta = tipo.meta
            }
            
            movements.insert(newMovement, at: 0)
        } catch {
            errorMessage = "Error adding movement: \(error.localizedDescription)"
        }
    }
    
    func updateMovement(_ movement: Movement) async {
        errorMessage = "" // Clear any previous error
        do {
            var updatedMovement = try await databaseService.updateMovement(movement)
            
            // Manually assign the tipo information based on the loaded movement types
            if let tipo = movementTypes.first(where: { $0.id == updatedMovement.idTipoMovimiento }) {
                updatedMovement.tipoNombre = tipo.nombre
                updatedMovement.tipoMeta = tipo.meta
            }
            
            if let index = movements.firstIndex(where: { $0.id == movement.id }) {
                movements[index] = updatedMovement
            }
        } catch {
            errorMessage = "Error updating movement: \(error.localizedDescription)"
        }
    }
    
    func deleteMovement(_ movement: Movement, userId: String) async {
        guard let id = movement.id else { return }
        
        errorMessage = "" // Clear any previous error
        do {
            try await databaseService.deleteMovement(id: id, userId: userId)
            movements.removeAll { $0.id == id }
        } catch {
            errorMessage = "Error deleting movement: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Filter Methods
    
    func resetFilters() {
        selectedMonth = nil
        selectedCategory = nil
    }
    
    func setMonthFilter(_ month: Int?) {
        selectedMonth = month
    }
    
    func setCategoryFilter(_ category: MovementType?) {
        selectedCategory = category
    }
}

// MARK: - Helper Models

struct CategoryExpense: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let color: Color
}

struct MonthlyData: Identifiable {
    let id = UUID()
    let month: String
    let income: Double
    let expenses: Double
    let monthNumber: Int
    
    var netBalance: Double {
        income - expenses
    }
}
