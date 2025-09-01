//
//  AddMovementView.swift
//  finanzas-personales-app
//
//  Form for adding new movements
//

import SwiftUI

struct AddMovementView: View {
    @EnvironmentObject var movementViewModel: MovementViewModel
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) private var dismiss
    
    let initialType: String?
    
    @State private var name = ""
    @State private var amount = ""
    @State private var description = ""
    @State private var date = Date()
    @State private var selectedType: MovementType?
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    init(initialType: String? = nil) {
        self.initialType = initialType
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Información básica") {
                    TextField("Nombre del movimiento", text: $name)
                        .autocorrectionDisabled()
                    
                    TextField("Monto", text: $amount)
                        .keyboardType(.decimalPad)
                        .autocorrectionDisabled()
                    
                    DatePicker("Fecha", selection: $date, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }
                
                Section("Categoría") {
                    Picker("Tipo de movimiento", selection: $selectedType) {
                        Text("Seleccionar categoría")
                            .foregroundColor(.secondary)
                            .tag(nil as MovementType?)
                        
                        ForEach(movementViewModel.movementTypes, id: \.self) { type in
                            HStack {
                                Image(systemName: type.categoryIcon)
                                    .foregroundColor(Color(type.categoryColor))
                                Text(type.nombre)
                            }
                            .tag(Optional(type))
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                Section("Descripción (opcional)") {
                    TextField("Agregar una descripción...", text: $description, axis: .vertical)
                        .lineLimit(3...5)
                        .autocorrectionDisabled()
                }
                
                if !errorMessage.isEmpty {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Nuevo Movimiento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveMovement()
                    }
                    .disabled(!isFormValid || isLoading)
                }
            }
            .onAppear {
                setupInitialType()
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !amount.isEmpty &&
        Double(amount) != nil &&
        selectedType != nil
    }
    
    private func setupInitialType() {
        guard let initialType = initialType else { return }
        
        switch initialType {
        case "income":
            selectedType = movementViewModel.movementTypes.first { $0.nombre == "Ingresos" }
        case "expense":
            // Select first non-income, non-savings type
            selectedType = movementViewModel.movementTypes.first { 
                $0.nombre != "Ingresos" && $0.nombre != "Ahorro" 
            }
        case "savings":
            selectedType = movementViewModel.movementTypes.first { $0.nombre == "Ahorro" }
        default:
            break
        }
    }
    
    private func saveMovement() {
        guard let selectedType = selectedType,
              let typeId = selectedType.id,
              let amountValue = Double(amount) else {
            errorMessage = "Por favor completa todos los campos requeridos"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        // Check if we're in demo mode
        if authService.isDemoMode {
            // In demo mode, just show success and dismiss
            Task {
                try? await Task.sleep(for: .seconds(1))
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            }
            return
        }
        
        guard let userId = authService.currentUser?.id else {
            errorMessage = "Error: Usuario no autenticado"
            isLoading = false
            return
        }
        
        let movement = Movement(
            nombre: name.trimmingCharacters(in: .whitespacesAndNewlines),
            importe: amountValue,
            fecha: date,
            descripcion: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
            idTipoMovimiento: typeId,
            usuarioId: userId.uuidString
        )
        
        Task {
            await movementViewModel.addMovement(movement)
            
            await MainActor.run {
                isLoading = false
                if movementViewModel.errorMessage.isEmpty {
                    dismiss()
                } else {
                    errorMessage = movementViewModel.errorMessage
                }
            }
        }
    }
}

struct EditMovementView: View {
    @EnvironmentObject var movementViewModel: MovementViewModel
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) private var dismiss
    
    let movement: Movement
    
    @State private var name: String
    @State private var amount: String
    @State private var description: String
    @State private var date: Date
    @State private var selectedType: MovementType?
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    init(movement: Movement) {
        self.movement = movement
        _name = State(initialValue: movement.nombre)
        _amount = State(initialValue: String(movement.importe))
        _description = State(initialValue: movement.descripcion ?? "")
        _date = State(initialValue: movement.fecha)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Información básica") {
                    TextField("Nombre del movimiento", text: $name)
                        .autocorrectionDisabled()
                    
                    TextField("Monto", text: $amount)
                        .keyboardType(.decimalPad)
                        .autocorrectionDisabled()
                    
                    DatePicker("Fecha", selection: $date, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }
                
                Section("Categoría") {
                    Picker("Tipo de movimiento", selection: $selectedType) {
                        Text("Seleccionar categoría")
                            .foregroundColor(.secondary)
                            .tag(nil as MovementType?)
                        
                        ForEach(movementViewModel.movementTypes, id: \.self) { type in
                            HStack {
                                Image(systemName: type.categoryIcon)
                                    .foregroundColor(Color(type.categoryColor))
                                Text(type.nombre)
                            }
                            .tag(Optional(type))
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                Section("Descripción (opcional)") {
                    TextField("Agregar una descripción...", text: $description, axis: .vertical)
                        .lineLimit(3...5)
                        .autocorrectionDisabled()
                }
                
                if !errorMessage.isEmpty {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Editar Movimiento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Actualizar") {
                        updateMovement()
                    }
                    .disabled(!isFormValid || isLoading)
                }
            }
            .onAppear {
                setupCurrentType()
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !amount.isEmpty &&
        Double(amount) != nil &&
        selectedType != nil
    }
    
    private func setupCurrentType() {
        selectedType = movementViewModel.movementTypes.first { $0.id == movement.idTipoMovimiento }
    }
    
    private func updateMovement() {
        guard let userId = authService.currentUser?.id,
              let selectedType = selectedType,
              let typeId = selectedType.id,
              let amountValue = Double(amount) else {
            errorMessage = "Por favor completa todos los campos requeridos"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        var updatedMovement = movement
        updatedMovement = Movement(
            id: movement.id,
            nombre: name.trimmingCharacters(in: .whitespacesAndNewlines),
            importe: amountValue,
            fecha: date,
            descripcion: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
            idTipoMovimiento: typeId,
            usuarioId: userId.uuidString,
            createdAt: movement.createdAt
        )
        
        Task {
            await movementViewModel.updateMovement(updatedMovement)
            
            await MainActor.run {
                isLoading = false
                if movementViewModel.errorMessage.isEmpty {
                    dismiss()
                } else {
                    errorMessage = movementViewModel.errorMessage
                }
            }
        }
    }
}

#Preview {
    AddMovementView(initialType: "income")
        .environmentObject(AuthService())
        .environmentObject(MovementViewModel())
}
