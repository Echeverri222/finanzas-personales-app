//
//  ChartsView.swift
//  finanzas-personales-app
//
//  Charts and analytics view
//

import SwiftUI
import Charts

struct ChartsView: View {
    @EnvironmentObject var movementViewModel: MovementViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Period selector
                    periodSelector
                    
                    // Monthly trend chart
                    monthlyTrendChart
                    
                    // Category breakdown
                    categoryBreakdownChart
                    
                    // Income vs Expenses comparison
                    incomeExpensesComparison
                    
                    // Savings progress
                    savingsProgress
                }
                .padding()
            }
            .navigationTitle("Análisis")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var periodSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Período de análisis")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
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
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                }
                
                Spacer()
                
                Button("Restablecer filtros") {
                    movementViewModel.resetFilters()
                }
                .font(.subheadline)
                .foregroundColor(.orange)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var monthlyTrendChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Evolución mensual \(movementViewModel.selectedYear)")
                .font(.headline)
                .fontWeight(.semibold)
            
            if !movementViewModel.monthlyData.isEmpty {
                Chart {
                    ForEach(movementViewModel.monthlyData) { data in
                        AreaMark(
                            x: .value("Mes", data.month),
                            y: .value("Ingresos", data.income)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green.opacity(0.6), .green.opacity(0.1)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                        
                        LineMark(
                            x: .value("Mes", data.month),
                            y: .value("Gastos", data.expenses)
                        )
                        .foregroundStyle(.red)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .interpolationMethod(.catmullRom)
                    }
                }
                .frame(height: 200)
                .chartYAxisLabel("Monto ($)")
                .chartXAxisLabel("Mes")
                .chartLegend(position: .top, alignment: .leading)
            } else {
                emptyChartState
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var categoryBreakdownChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Distribución de gastos por categoría")
                .font(.headline)
                .fontWeight(.semibold)
            
            if !movementViewModel.categoryExpenses.isEmpty {
                Chart {
                    ForEach(movementViewModel.categoryExpenses.prefix(8)) { expense in
                        BarMark(
                            x: .value("Categoría", expense.name),
                            y: .value("Monto", expense.amount)
                        )
                        .foregroundStyle(expense.color)
                        .cornerRadius(4)
                    }
                }
                .frame(height: 200)
                .chartYAxisLabel("Monto ($)")
                .chartXAxisLabel("Categoría")
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisValueLabel {
                            if let category = value.as(String.self) {
                                Text(category)
                                    .font(.caption)
                                    .rotationEffect(.degrees(-45))
                            }
                        }
                    }
                }
            } else {
                emptyChartState
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var incomeExpensesComparison: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Comparación Ingresos vs Gastos")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("Ingresos")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(formatCurrency(movementViewModel.totalIncome))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
                
                VStack(spacing: 8) {
                    Text("Gastos")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(formatCurrency(movementViewModel.totalExpenses))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(10)
            }
            
            // Balance
            VStack(spacing: 8) {
                Text("Balance Neto")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(formatCurrency(movementViewModel.netBalance))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(movementViewModel.netBalance >= 0 ? .green : .red)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                (movementViewModel.netBalance >= 0 ? Color.green : Color.red).opacity(0.1)
            )
            .cornerRadius(10)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var savingsProgress: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progreso de ahorros")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                HStack {
                    Text("Total ahorrado en el período")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(formatCurrency(movementViewModel.totalSavings))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                // Savings rate
                let savingsRate = movementViewModel.totalIncome > 0 ? 
                    (movementViewModel.totalSavings / movementViewModel.totalIncome) * 100 : 0
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Tasa de ahorro")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(savingsRate, specifier: "%.1f")%")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    
                    ProgressView(value: savingsRate, total: 100)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var emptyChartState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            Text("No hay datos para mostrar")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

#Preview {
    ChartsView()
        .environmentObject(AuthService())
        .environmentObject(MovementViewModel())
}
