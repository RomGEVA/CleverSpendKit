import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            AddExpenseView()
                .tabItem {
                    Label("Add Expense", systemImage: "plus.circle.fill")
                }
            
            CategoriesView()
                .tabItem {
                    Label("Categories", systemImage: "folder.fill")
                }
            
            StatisticsView()
                .tabItem {
                    Label("Statistics", systemImage: "chart.pie.fill")
                }
            
            TipsView()
                .tabItem {
                    Label("Tips", systemImage: "lightbulb.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(.blue)
    }
}

#Preview {
    MainTabView()
} 