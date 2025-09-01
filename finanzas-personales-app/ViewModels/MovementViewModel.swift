//
//  MovementViewModel.swift
//  finanzas-personales-app
//
//  ViewModel for managing movements data and operations
//

import Foundation
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
            let color = movements.first?.categoryColor ?? "gray"
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
    
    func loadData(userId: String? = nil, isDemoMode: Bool = false) async {
        loading = true
        errorMessage = ""
        
        if isDemoMode {
            // Load demo data for testing
            loadDemoData()
            loading = false
            return
        }
        
        guard let userId = userId else {
            errorMessage = "ID de usuario requerido"
            loading = false
            return
        }
        
        do {
            async let movementsTask = databaseService.fetchMovements(for: userId)
            async let typesTask = databaseService.fetchMovementTypes(for: userId)
            
            let (fetchedMovements, fetchedTypes) = try await (movementsTask, typesTask)
            
            movements = fetchedMovements
            movementTypes = fetchedTypes
        } catch {
            errorMessage = "Error loading data: \(error.localizedDescription)"
        }
        
        loading = false
    }
    
    private func loadDemoData() {
        // Create demo movement types
        let demoTypes = [
            MovementType(id: 1, nombre: "Ingresos", meta: 5000, usuarioId: "demo", createdAt: Date()),
            MovementType(id: 2, nombre: "Alimentacion", meta: 800, usuarioId: "demo", createdAt: Date()),
            MovementType(id: 3, nombre: "Transporte", meta: 300, usuarioId: "demo", createdAt: Date()),
            MovementType(id: 4, nombre: "Compras", meta: 400, usuarioId: "demo", createdAt: Date()),
            MovementType(id: 5, nombre: "Gastos fijos", meta: 1200, usuarioId: "demo", createdAt: Date()),
            MovementType(id: 6, nombre: "Ahorro", meta: 1000, usuarioId: "demo", createdAt: Date()),
            MovementType(id: 7, nombre: "Salidas", meta: 200, usuarioId: "demo", createdAt: Date())
        ]
        
        // Create demo movements
        let calendar = Calendar.current
        let today = Date()
        var demoMovements: [Movement] = []
        
        // Generate movements for the last 3 months
        for monthOffset in 0..<3 {
            guard let monthDate = calendar.date(byAdding: .month, value: -monthOffset, to: today) else { continue }
            
            // Income
            var income = Movement(
                id: demoMovements.count + 1,
                nombre: "Salario Mensual",
                importe: 4500,
                fecha: calendar.date(byAdding: .day, value: -5, to: monthDate) ?? monthDate,
                descripcion: "Salario del mes",
                idTipoMovimiento: 1,
                usuarioId: "demo",
                createdAt: monthDate
            )
            income.tipoNombre = "Ingresos"
            demoMovements.append(income)
            
            // Expenses
            let expenses = [
                ("Supermercado", 200.0, 2, "Alimentacion"),
                ("Gasolina", 80.0, 3, "Transporte"),
                ("Renta", 1000.0, 5, "Gastos fijos"),
                ("Servicios", 150.0, 5, "Gastos fijos"),
                ("Ropa", 120.0, 4, "Compras"),
                ("Cine", 40.0, 7, "Salidas"),
                ("Ahorro mensual", 800.0, 6, "Ahorro")
            ]
            
            for (index, (name, amount, typeId, typeName)) in expenses.enumerated() {
                var movement = Movement(
                    id: demoMovements.count + 1,
                    nombre: name,
                    importe: amount,
                    fecha: calendar.date(byAdding: .day, value: -(10 + index * 2), to: monthDate) ?? monthDate,
                    descripcion: "Demo transaction",
                    idTipoMovimiento: typeId,
                    usuarioId: "demo",
                    createdAt: monthDate
                )
                movement.tipoNombre = typeName
                demoMovements.append(movement)
            }
        }
        
        movementTypes = demoTypes
        movements = demoMovements.sorted { $0.fecha > $1.fecha }
    }
    
    func addMovement(_ movement: Movement) async {
        do {
            let newMovement = try await databaseService.createMovement(movement)
            movements.insert(newMovement, at: 0)
        } catch {
            errorMessage = "Error adding movement: \(error.localizedDescription)"
        }
    }
    
    func updateMovement(_ movement: Movement) async {
        do {
            let updatedMovement = try await databaseService.updateMovement(movement)
            if let index = movements.firstIndex(where: { $0.id == movement.id }) {
                movements[index] = updatedMovement
            }
        } catch {
            errorMessage = "Error updating movement: \(error.localizedDescription)"
        }
    }
    
    func deleteMovement(_ movement: Movement, userId: String) async {
        guard let id = movement.id else { return }
        
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
    let color: String
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
