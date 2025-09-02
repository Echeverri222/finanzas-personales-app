//
//  MovementsView.swift
//  finanzas-personales-app
//
//  List and management of financial movements
//

import SwiftUI

struct MovementsView: View {
    @EnvironmentObject var movementViewModel: MovementViewModel
    @EnvironmentObject var authService: AuthService
    @State private var showingAddMovement = false
    @State private var searchText = ""
    @State private var showingFilters = false
    @State private var selectedMovement: Movement?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and filter bar
                searchAndFilterBar
                
                // Movements list
                movementsList
            }
            .navigationTitle("Movimientos")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddMovement = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingFilters = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddMovement) {
                AddMovementView()
            }
            .sheet(isPresented: $showingFilters) {
                FiltersView()
            }
            .sheet(item: $selectedMovement) { movement in
                EditMovementView(movement: movement)
            }
            .refreshable {
                if let userProfile = authService.userProfile {
                    await movementViewModel.loadData(userId: userProfile.id)
                }
            }
        }
    }
    
    private var searchAndFilterBar: some View {
        VStack(spacing: 12) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Buscar movimientos...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            
            // Active filters indicator
            if hasActiveFilters {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        if movementViewModel.selectedMonth != nil {
                            FilterChip(title: monthName(for: movementViewModel.selectedMonth!)) {
                                movementViewModel.setMonthFilter(nil)
                            }
                        }
                        
                        if let category = movementViewModel.selectedCategory {
                            FilterChip(title: category.nombre) {
                                movementViewModel.setCategoryFilter(nil)
                            }
                        }
                        
                        Button("Limpiar todo") {
                            movementViewModel.resetFilters()
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical, 8)
        .background(Color(UIColor.systemBackground))
    }
    
    private var movementsList: some View {
        Group {
            if movementViewModel.loading {
                ProgressView("Cargando movimientos...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if filteredMovements.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(filteredMovements) { movement in
                        MovementCard(movement: movement) {
                            selectedMovement = movement
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button("Eliminar", role: .destructive) {
                                deleteMovement(movement)
                            }
                            
                            Button("Editar") {
                                selectedMovement = movement
                            }
                            .tint(.blue)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No hay movimientos")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Comienza agregando tu primer movimiento financiero")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                showingAddMovement = true
            } label: {
                Text("Agregar movimiento")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var filteredMovements: [Movement] {
        var movements = movementViewModel.filteredMovements
        
        if !searchText.isEmpty {
            movements = movements.filter { movement in
                movement.nombre.localizedCaseInsensitiveContains(searchText) ||
                movement.tipoNombre?.localizedCaseInsensitiveContains(searchText) == true ||
                movement.descripcion?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        return movements
    }
    
    private var hasActiveFilters: Bool {
        movementViewModel.selectedMonth != nil || 
        movementViewModel.selectedCategory != nil
    }
    
    private func deleteMovement(_ movement: Movement) {
        guard let userProfile = authService.userProfile else { return }
        
        Task {
            await movementViewModel.deleteMovement(movement, userId: userProfile.id)
        }
    }
    
    private func monthName(for month: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.monthSymbols[month - 1]
    }
}

// MARK: - Supporting Views

struct MovementCard: View {
    let movement: Movement
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Category icon
                Image(systemName: movement.categoryIcon)
                    .font(.title2)
                    .foregroundColor(movement.categoryColor)
                    .frame(width: 44, height: 44)
                    .background(movement.categoryColor.opacity(0.1))
                    .cornerRadius(22)
                
                // Movement details
                VStack(alignment: .leading, spacing: 4) {
                    Text(movement.nombre)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Text(movement.tipoNombre ?? "Sin categoría")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(movement.fecha.formatted(date: .abbreviated, time: .omitted))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if let description = movement.descripcion, !description.isEmpty {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Amount
                VStack(alignment: .trailing, spacing: 4) {
                    Text(movement.formattedAmount)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(movement.isIncome ? .green : .red)
                    
                    if movement.isIncome {
                        Text("Ingreso")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.1))
                            .foregroundColor(.green)
                            .cornerRadius(4)
                    } else if movement.isSaving {
                        Text("Ahorro")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

struct FilterChip: View {
    let title: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.caption)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption2)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.1))
        .foregroundColor(.blue)
        .cornerRadius(6)
    }
}

struct FiltersView: View {
    @EnvironmentObject var movementViewModel: MovementViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Período") {
                    Picker("Año", selection: $movementViewModel.selectedYear) {
                        ForEach(movementViewModel.availableYears, id: \.self) { year in
                            Text("\(year)").tag(year)
                        }
                    }
                    
                    Picker("Mes", selection: Binding(
                        get: { movementViewModel.selectedMonth ?? 0 },
                        set: { movementViewModel.setMonthFilter($0 == 0 ? nil : $0) }
                    )) {
                        Text("Todo el año").tag(0)
                        ForEach(1...12, id: \.self) { month in
                            Text(monthName(for: month)).tag(month)
                        }
                    }
                }
                
                Section("Categoría") {
                    Picker("Categoría", selection: Binding(
                        get: { movementViewModel.selectedCategory?.id ?? "" },
                        set: { newValue in
                            if newValue.isEmpty {
                                movementViewModel.setCategoryFilter(nil)
                            } else {
                                let category = movementViewModel.movementTypes.first { $0.id == newValue }
                                movementViewModel.setCategoryFilter(category)
                            }
                        }
                    )) {
                        Text("Todas las categorías").tag("")
                        ForEach(movementViewModel.movementTypes, id: \.self) { type in
                            if let id = type.id {
                                Text(type.nombre).tag(id)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filtros")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Restablecer") {
                        movementViewModel.resetFilters()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func monthName(for month: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.monthSymbols[month - 1]
    }
}

#Preview {
    MovementsView()
        .environmentObject(AuthService())
        .environmentObject(MovementViewModel())
}
