//
//  AuthView.swift
//  finanzas-personales-app
//
//  Authentication view with email magic link
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authService: AuthService
    @State private var showingSuccessMessage = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    
                    Text("Finanzas Personales")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Gestiona tus finanzas de manera inteligente")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 50)
                
                Spacer()
                
                // Login Options
                    
                VStack(spacing: 20) {
                    // Google Sign In Button
                    GoogleSignInButton(
                        action: {
                            Task {
                                await authService.signInWithGoogle()
                            }
                        },
                        isLoading: authService.loading
                    )
                    
                    // Divider
                    HStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                        
                        Text("O")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                    }
                    
                    // Demo Mode Button
                    Button(action: {
                        Task {
                            await authService.signInDemo()
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "person.crop.circle.fill")
                                .foregroundColor(.white)
                            Text("Modo Demo (Solo Testing)")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .padding(.horizontal)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .disabled(authService.loading)
                }
                .padding(.horizontal)
                
                // Messages
                if !authService.errorMessage.isEmpty {
                    Text(authService.errorMessage)
                        .font(.subheadline)
                        .foregroundColor(authService.errorMessage.contains("Error") ? .red : .green)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // App Features Preview
                VStack(spacing: 12) {
                    HStack(spacing: 20) {
                        FeatureIcon(icon: "chart.line.uptrend.xyaxis", title: "Dashboard", color: .blue)
                        FeatureIcon(icon: "list.bullet.rectangle", title: "Movimientos", color: .green)
                        FeatureIcon(icon: "target", title: "Metas", color: .orange)
                        FeatureIcon(icon: "chart.pie", title: "Análisis", color: .purple)
                    }
                    
                    Text("Visualiza • Controla • Ahorra • Crece")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 30)
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

struct FeatureIcon: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(width: 60, height: 60)
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthService())
}
