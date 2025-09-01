//
//  MainTabView.swift
//  finanzas-personales-app
//
//  Main tab navigation structure
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Dashboard")
                }
                .tag(0)
            
            MovementsView()
                .tabItem {
                    Image(systemName: "list.bullet.rectangle")
                    Text("Movimientos")
                }
                .tag(1)
            
            ChartsView()
                .tabItem {
                    Image(systemName: "chart.pie")
                    Text("Análisis")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Ajustes")
                }
                .tag(3)
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthService())
        .environmentObject(MovementViewModel())
}
