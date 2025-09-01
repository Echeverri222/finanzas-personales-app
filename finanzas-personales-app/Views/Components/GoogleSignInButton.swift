//
//  GoogleSignInButton.swift
//  finanzas-personales-app
//
//  Custom Google Sign-In button with proper branding
//

import SwiftUI

struct GoogleSignInButton: View {
    let action: () -> Void
    let isLoading: Bool
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                } else {
                    // Google G logo recreated in SwiftUI
                    GoogleGLogo()
                        .frame(width: 20, height: 20)
                }
                
                Text(isLoading ? "Conectando..." : "Continuar con Google")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(red: 0.74, green: 0.74, blue: 0.74), lineWidth: 1)
            )
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .disabled(isLoading)
        .scaleEffect(isLoading ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isLoading)
    }
}

struct GoogleGLogo: View {
    var body: some View {
        ZStack {
            // Background circle (white)
            Circle()
                .fill(Color.white)
                .frame(width: 20, height: 20)
            
            // Google G logo paths
            Path { path in
                // Blue section (top right)
                path.move(to: CGPoint(x: 18.48, y: 6.24))
                path.addCurve(to: CGPoint(x: 10, y: 2),
                            control1: CGPoint(x: 15.84, y: 3.6),
                            control2: CGPoint(x: 13.2, y: 2))
                path.addCurve(to: CGPoint(x: 2, y: 10),
                            control1: CGPoint(x: 5.6, y: 2),
                            control2: CGPoint(x: 2, y: 5.6))
                path.addCurve(to: CGPoint(x: 3.84, y: 16.32),
                            control1: CGPoint(x: 2, y: 12.72),
                            control2: CGPoint(x: 2.64, y: 14.88))
                path.addLine(to: CGPoint(x: 6.24, y: 13.92))
                path.addCurve(to: CGPoint(x: 6.24, y: 6.24),
                            control1: CGPoint(x: 4.8, y: 11.52),
                            control2: CGPoint(x: 4.8, y: 7.68))
                path.addCurve(to: CGPoint(x: 13.92, y: 6.24),
                            control1: CGPoint(x: 7.68, y: 4.8),
                            control2: CGPoint(x: 11.52, y: 4.8))
                path.addCurve(to: CGPoint(x: 18.48, y: 6.24),
                            control1: CGPoint(x: 15.36, y: 5.28),
                            control2: CGPoint(x: 16.8, y: 5.52))
                path.closeSubpath()
            }
            .fill(Color(red: 0.259, green: 0.522, blue: 0.957))
            
            // Red section (left)
            Path { path in
                path.move(to: CGPoint(x: 2, y: 10))
                path.addCurve(to: CGPoint(x: 10, y: 18),
                            control1: CGPoint(x: 2, y: 14.4),
                            control2: CGPoint(x: 5.6, y: 18))
                path.addCurve(to: CGPoint(x: 16.32, y: 16.16),
                            control1: CGPoint(x: 12.72, y: 18),
                            control2: CGPoint(x: 14.88, y: 17.36))
                path.addLine(to: CGPoint(x: 13.92, y: 13.76))
                path.addCurve(to: CGPoint(x: 6.24, y: 13.76),
                            control1: CGPoint(x: 11.52, y: 15.2),
                            control2: CGPoint(x: 7.68, y: 15.2))
                path.addLine(to: CGPoint(x: 3.84, y: 16.16))
                path.addCurve(to: CGPoint(x: 2, y: 10),
                            control1: CGPoint(x: 2.64, y: 14.88),
                            control2: CGPoint(x: 2, y: 12.72))
                path.closeSubpath()
            }
            .fill(Color(red: 0.918, green: 0.259, blue: 0.208))
            
            // Yellow section (bottom left)
            Path { path in
                path.move(to: CGPoint(x: 3.84, y: 16.32))
                path.addLine(to: CGPoint(x: 6.24, y: 13.92))
                path.addCurve(to: CGPoint(x: 13.92, y: 13.92),
                            control1: CGPoint(x: 7.68, y: 15.36),
                            control2: CGPoint(x: 11.52, y: 15.36))
                path.addLine(to: CGPoint(x: 16.32, y: 16.32))
                path.addCurve(to: CGPoint(x: 10, y: 18),
                            control1: CGPoint(x: 14.88, y: 17.36),
                            control2: CGPoint(x: 12.72, y: 18))
                path.addCurve(to: CGPoint(x: 3.84, y: 16.32),
                            control1: CGPoint(x: 7.2, y: 18),
                            control2: CGPoint(x: 5.04, y: 17.28))
                path.closeSubpath()
            }
            .fill(Color(red: 0.984, green: 0.737, blue: 0.020))
            
            // Green section (bottom right)
            Path { path in
                path.move(to: CGPoint(x: 16.32, y: 16.16))
                path.addLine(to: CGPoint(x: 13.92, y: 13.76))
                path.addCurve(to: CGPoint(x: 13.92, y: 6.24),
                            control1: CGPoint(x: 15.36, y: 11.52),
                            control2: CGPoint(x: 15.36, y: 7.68))
                path.addLine(to: CGPoint(x: 18.48, y: 6.24))
                path.addCurve(to: CGPoint(x: 18, y: 10),
                            control1: CGPoint(x: 18, y: 7.2),
                            control2: CGPoint(x: 18, y: 8.64))
                path.addCurve(to: CGPoint(x: 16.32, y: 16.16),
                            control1: CGPoint(x: 18, y: 12.72),
                            control2: CGPoint(x: 17.28, y: 14.64))
                path.closeSubpath()
            }
            .fill(Color(red: 0.208, green: 0.659, blue: 0.322))
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        GoogleSignInButton(action: {}, isLoading: false)
        GoogleSignInButton(action: {}, isLoading: true)
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
