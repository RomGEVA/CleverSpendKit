import SwiftUI

struct StatisticsView: View {
    @State private var selectedPeriod: DatePeriod = .month
    @State private var expenses: [Expense] = []
    @State private var categories: [Category] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color(.systemPurple).opacity(0.13), Color(.systemBlue).opacity(0.10)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 28) {
                        GlassCard(cornerRadius: 18, opacity: 0.22) {
                            CustomSegmentedControl(selection: $selectedPeriod)
                        }
                        .padding(.horizontal)
                        
                        GlassCard(cornerRadius: 22, opacity: 0.32) {
                            VStack(spacing: 8) {
                                Text("Total expenses")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text(String(format: "$%.2f", totalExpenses))
                                    .font(.system(size: 34, weight: .bold))
                                    .foregroundStyle(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                            }
                        }
                        .padding(.horizontal)
                        
                        GlassCard(cornerRadius: 22, opacity: 0.32) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("By category")
                                    .font(.headline)
                                    .padding(.horizontal, 2)
                                if !expenses.isEmpty {
                                    PieChartView(data: categoryData, showPercentages: true)
                                        .frame(height: 220)
                                        .padding(.vertical, 8)
                                } else {
                                    Text("No data to display")
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding()
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        GlassCard(cornerRadius: 22, opacity: 0.32) {
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Category breakdown")
                                    .font(.headline)
                                    .padding(.horizontal, 2)
                                ForEach(categoryData) { item in
                                    HStack(spacing: 14) {
                                        Circle()
                                            .fill(Color(item.color))
                                            .frame(width: 16, height: 16)
                                            .shadow(color: Color(item.color).opacity(0.18), radius: 4, x: 0, y: 2)
                                        Text(item.name)
                                            .font(.subheadline)
                                        Spacer()
                                        Text(String(format: "$%.2f", item.amount))
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(.systemGray6).opacity(0.18))
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Statistics")
            .onAppear {
                loadData()
            }
            .onChange(of: selectedPeriod) { _ in
                loadData()
            }
        }
    }
    
    private var totalExpenses: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    private var categoryData: [CategoryData] {
        let groupedExpenses = Dictionary(grouping: expenses) { $0.category }
        let total = totalExpenses
        
        return groupedExpenses.compactMap { category, expenses in
            guard let category = category else { return nil }
            let amount = expenses.reduce(0) { $0 + $1.amount }
            let percentage = total > 0 ? amount / total : 0
            
            return CategoryData(
                id: category.id ?? UUID(),
                name: category.name ?? "",
                amount: amount,
                percentage: percentage,
                color: category.color ?? "blue"
            )
        }
        .sorted { $0.amount > $1.amount }
    }
    
    private func loadData() {
        expenses = CoreDataManager.shared.fetchExpenses(period: selectedPeriod)
        categories = CoreDataManager.shared.fetchCategories()
    }
}

struct CategoryData: Identifiable {
    let id: UUID
    let name: String
    let amount: Double
    let percentage: Double
    let color: String
}

#Preview {
    StatisticsView()
} 