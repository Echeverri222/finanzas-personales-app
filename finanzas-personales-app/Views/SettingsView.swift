//
//  SettingsView.swift
//  finanzas-personales-app
//
//  Settings and user profile view
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var movementViewModel: MovementViewModel
    @State private var showingSignOutAlert = false
    @State private var showingAbout = false
    
    var body: some View {
        NavigationView {
            List {
                // User profile section
                userProfileSection
                
                // App settings
                appSettingsSection
                
                // Data management
                dataManagementSection
                
                // Support and info
                supportSection
                
                // Sign out
                signOutSection
            }
            .navigationTitle("Ajustes")
            .navigationBarTitleDisplayMode(.large)
            .alert("Cerrar sesión", isPresented: $showingSignOutAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Cerrar sesión", role: .destructive) {
                    Task {
                        await authService.signOut()
                    }
                }
            } message: {
                Text("¿Estás seguro de que quieres cerrar sesión?")
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
        }
    }
    
    private var userProfileSection: some View {
        Section {
            HStack(spacing: 16) {
                // User avatar
                Circle()
                    .fill(LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 60, height: 60)
                    .overlay {
                        Text(userInitials)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(authService.isDemoMode ? "Usuario Demo" : (authService.currentUser?.email ?? "Usuario"))
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Text(authService.isDemoMode ? "Sesión de prueba" : "Cuenta activa")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
    
    private var appSettingsSection: some View {
        Section("Aplicación") {
            NavigationLink {
                MovementTypesView()
            } label: {
                Label("Gestionar categorías", systemImage: "list.bullet.circle")
            }
            
            NavigationLink {
                GoalsView()
            } label: {
                Label("Metas financieras", systemImage: "target")
            }
            
            HStack {
                Label("Notificaciones", systemImage: "bell.circle")
                Spacer()
                Toggle("", isOn: .constant(true))
                    .disabled(true)
            }
        }
    }
    
    private var dataManagementSection: some View {
        Section("Datos") {
            Button {
                refreshData()
            } label: {
                Label("Actualizar datos", systemImage: "arrow.clockwise.circle")
            }
            
            NavigationLink {
                ExportDataView()
            } label: {
                Label("Exportar datos", systemImage: "square.and.arrow.up")
            }
            
            Button {
                // TODO: Implement data backup
            } label: {
                Label("Respaldar datos", systemImage: "icloud.and.arrow.up")
            }
        }
    }
    
    private var supportSection: some View {
        Section("Soporte e información") {
            Button {
                showingAbout = true
            } label: {
                Label("Acerca de la app", systemImage: "info.circle")
            }
            
            Link("Reportar problema", destination: URL(string: "mailto:support@finanzaspersonales.com")!)
                .foregroundColor(.primary)
                .overlay(alignment: .leading) {
                    Label("", systemImage: "envelope")
                        .foregroundColor(.blue)
                }
            
            Link("Calificar la app", destination: URL(string: "https://apps.apple.com")!)
                .foregroundColor(.primary)
                .overlay(alignment: .leading) {
                    Label("", systemImage: "star")
                        .foregroundColor(.yellow)
                }
        }
    }
    
    private var signOutSection: some View {
        Section {
            Button {
                showingSignOutAlert = true
            } label: {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.red)
                    
                    Text("Cerrar sesión")
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    private var userInitials: String {
        guard let email = authService.currentUser?.email else { return "U" }
        let components = email.components(separatedBy: "@")
        let username = components.first ?? email
        
        if username.count >= 2 {
            let firstChar = username.prefix(1).uppercased()
            let secondChar = username.dropFirst().prefix(1).uppercased()
            return firstChar + secondChar
        } else {
            return username.prefix(1).uppercased()
        }
    }
    
    private func refreshData() {
        Task {
            if authService.isDemoMode {
                await movementViewModel.loadData(isDemoMode: true)
            } else if let userId = authService.currentUser?.id {
                await movementViewModel.loadData(userId: userId.uuidString)
            }
        }
    }
}

// MARK: - Supporting Views

struct MovementTypesView: View {
    var body: some View {
        List {
            Text("Gestión de categorías")
            Text("Próximamente disponible")
                .foregroundColor(.secondary)
        }
        .navigationTitle("Categorías")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GoalsView: View {
    var body: some View {
        List {
            Text("Metas financieras")
            Text("Próximamente disponible")
                .foregroundColor(.secondary)
        }
        .navigationTitle("Metas")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ExportDataView: View {
    var body: some View {
        List {
            Text("Exportación de datos")
            Text("Próximamente disponible")
                .foregroundColor(.secondary)
        }
        .navigationTitle("Exportar")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // App icon
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.green)
                    
                    VStack(spacing: 8) {
                        Text("Finanzas Personales")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Versión 1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Características principales:")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Dashboard interactivo", description: "Visualiza tus finanzas de un vistazo")
                            FeatureRow(icon: "list.bullet.rectangle", title: "Gestión de movimientos", description: "Controla ingresos, gastos y ahorros")
                            FeatureRow(icon: "chart.pie", title: "Análisis detallado", description: "Gráficos y estadísticas avanzadas")
                            FeatureRow(icon: "icloud.and.arrow.up", title: "Sincronización en la nube", description: "Tus datos seguros con Supabase")
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                    
                    Text("Desarrollado con ❤️ usando Swift y SwiftUI")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Acerca de")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthService())
        .environmentObject(MovementViewModel())
}
