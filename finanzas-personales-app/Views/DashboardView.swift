//
//  DashboardView.swift
//  finanzas-personales-app
//
//  Main dashboard with financial overview
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var movementViewModel: MovementViewModel
    @EnvironmentObject var authService: AuthService
    @State private var showingAddMovement = false
    @State private var selectedMovementType: String = "income"
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background with subtle gradient
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemGray6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 20) {
                        // Header with filters
                        headerSection
                        
                        // Stats cards
                        statsCardsSection
                        
                        // Quick actions
                        quickActionsSection
                        
                        // Charts section
                        chartsSection
                        
                        // Recent movements
                        recentMovementsSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                if authService.isDemoMode {
                    await movementViewModel.loadData(isDemoMode: true)
                } else if let userProfile = authService.userProfile {
                    await movementViewModel.loadData(userId: userProfile.id)
                }
            }
            .sheet(isPresented: $showingAddMovement) {
                AddMovementView(initialType: selectedMovementType)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Período seleccionado")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(periodText)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                Button(action: {
                    movementViewModel.resetFilters()
                }) {
                    Text("Restablecer")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            // Filter buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Year picker
                    Menu {
                        ForEach(movementViewModel.availableYears, id: \.self) { year in
                            Button("\(year)") {
                                movementViewModel.selectedYear = year
                            }
                        }
                    } label: {
                        HStack {
                            Text("\(movementViewModel.selectedYear)")
                            Image(systemName: "chevron.down")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                    }
                    
                    // Month picker
                    Menu {
                        Button("Todo el año") {
                            movementViewModel.setMonthFilter(nil)
                        }
                        
                        ForEach(1...12, id: \.self) { month in
                            Button(monthName(for: month)) {
                                movementViewModel.setMonthFilter(month)
                            }
                        }
                    } label: {
                        HStack {
                            Text(movementViewModel.selectedMonth != nil ? monthName(for: movementViewModel.selectedMonth!) : "Todo el año")
                            Image(systemName: "chevron.down")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .cornerRadius(8)
                    }
                    
                    // Category picker
                    Menu {
                        Button("Todas las categorías") {
                            movementViewModel.setCategoryFilter(nil)
                        }
                        
                        ForEach(movementViewModel.movementTypes, id: \.id) { type in
                            Button(type.nombre) {
                                movementViewModel.setCategoryFilter(type)
                            }
                        }
                    } label: {
                        HStack {
                            Text(movementViewModel.selectedCategory?.nombre ?? "Todas")
                            Image(systemName: "chevron.down")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.purple.opacity(0.1))
                        .foregroundColor(.purple)
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 1)
            }
        }
    }
    
    private var statsCardsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatsCard(
                title: "Ingresos",
                amount: movementViewModel.totalIncome,
                color: .green,
                icon: "arrow.down.circle.fill"
            ) {
                selectedMovementType = "income"
                showingAddMovement = true
            }
            
            StatsCard(
                title: "Gastos",
                amount: movementViewModel.totalExpenses,
                color: .red,
                icon: "arrow.up.circle.fill"
            ) {
                selectedMovementType = "expense"
                showingAddMovement = true
            }
            
            StatsCard(
                title: "Balance",
                amount: movementViewModel.netBalance,
                color: movementViewModel.netBalance >= 0 ? .green : .red,
                icon: "equal.circle.fill",
                showAddButton: false
            )
            
            StatsCard(
                title: "Ahorros",
                amount: movementViewModel.totalSavings,
                color: .blue,
                icon: "banknote.fill"
            ) {
                selectedMovementType = "savings"
                showingAddMovement = true
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Acciones rápidas")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                QuickActionButton(
                    title: "Ingreso",
                    icon: "plus.circle.fill",
                    color: .green
                ) {
                    selectedMovementType = "income"
                    showingAddMovement = true
                }
                
                QuickActionButton(
                    title: "Gasto",
                    icon: "minus.circle.fill",
                    color: .red
                ) {
                    selectedMovementType = "expense"
                    showingAddMovement = true
                }
                
                QuickActionButton(
                    title: "Ahorro",
                    icon: "banknote.fill",
                    color: .blue
                ) {
                    selectedMovementType = "savings"
                    showingAddMovement = true
                }
            }
        }
    }
    
    private var chartsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Resumen visual")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Category expenses chart
            if !movementViewModel.categoryExpenses.isEmpty {
                CategoryExpenseChart(expenses: movementViewModel.categoryExpenses)
                    .frame(height: 200)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
        }
    }
    
    private var recentMovementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Movimientos recientes")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                NavigationLink("Ver todos") {
                    MovementsView()
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            LazyVStack(spacing: 8) {
                ForEach(Array(movementViewModel.filteredMovements.prefix(5))) { movement in
                    MovementRowView(movement: movement)
                }
            }
            
            if movementViewModel.filteredMovements.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("No hay movimientos en este período")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            }
        }
    }
    
    private var periodText: String {
        if let month = movementViewModel.selectedMonth {
            return "\(monthName(for: month)) \(movementViewModel.selectedYear)"
        } else {
            return "Año \(movementViewModel.selectedYear)"
        }
    }
    
    private func monthName(for month: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.monthSymbols[month - 1]
    }
}

// MARK: - Supporting Views

struct StatsCard: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    var showAddButton: Bool = true
    let action: (() -> Void)?
    
    init(title: String, amount: Double, color: Color, icon: String, showAddButton: Bool = true, action: (() -> Void)? = nil) {
        self.title = title
        self.amount = amount
        self.color = color
        self.icon = icon
        self.showAddButton = showAddButton
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top section with title and add button
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text(formatCurrency(amount))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .minimumScaleFactor(0.8)
                }
                
                Spacer()
                
                if showAddButton, let action = action {
                    Button(action: action) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(color)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)
            
            // Bottom section with icon
            HStack {
                Spacer()
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(color)
                    .opacity(0.2)
                    .padding(.bottom, 12)
                    .padding(.trailing, 12)
            }
        }
        .frame(minHeight: 100)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color)
            .cornerRadius(12)
        }
    }
}

struct MovementRowView: View {
    let movement: Movement
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: movement.categoryIcon)
                .font(.title2)
                .foregroundColor(movement.categoryColor)
                .frame(width: 40, height: 40)
                .background(movement.categoryColor.opacity(0.1))
                .cornerRadius(20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(movement.nombre)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                HStack {
                    Text(movement.fecha.formatted(date: .abbreviated, time: .omitted))
                    Text("•")
                    Text(movement.tipoNombre ?? "Sin categoría")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(movement.formattedAmount)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(movement.isIncome ? .green : .red)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
}

struct CategoryExpenseChart: View {
    let expenses: [CategoryExpense]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Distribución de gastos")
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal)
            
            if expenses.isEmpty {
                Text("No hay datos de gastos disponibles")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(expenses.prefix(5)) { expense in
                            VStack(spacing: 8) {
                                VStack(spacing: 4) {
                                    Text(formatCurrency(expense.amount))
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    
                                    // Improved bar height calculation
                                    let maxAmount = expenses.first?.amount ?? 1.0
                                    let heightRatio = maxAmount > 0 ? (expense.amount / maxAmount) : 0
                                    let barHeight = max(20, heightRatio * 80)
                                    
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(expense.color)
                                        .frame(width: 50, height: barHeight)
                                        .animation(.easeInOut(duration: 0.6), value: barHeight)
                                }
                                
                                Text(expense.name)
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .frame(width: 60)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Helper Functions

private func formatCurrency(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "USD"
    formatter.maximumFractionDigits = 0
    return formatter.string(from: NSNumber(value: amount)) ?? "$0"
}

#Preview {
    DashboardView()
        .environmentObject(AuthService())
        .environmentObject(MovementViewModel())
}
