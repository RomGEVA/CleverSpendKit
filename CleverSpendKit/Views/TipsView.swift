import SwiftUI

struct Tip: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: TipCategory
    let icon: String
}

enum TipCategory: String, CaseIterable {
    case saving = "Saving"
    case investing = "Investing"
    case habits = "Habits"
    
    var icon: String {
        switch self {
        case .saving: return "dollarsign.circle.fill"
        case .investing: return "chart.line.uptrend.xyaxis.circle.fill"
        case .habits: return "person.fill.checkmark"
        }
    }
    
    var color: String {
        switch self {
        case .saving: return "green"
        case .investing: return "blue"
        case .habits: return "purple"
        }
    }
}

struct TipsView: View {
    @State private var selectedCategory: TipCategory?
    @State private var searchText = ""
    
    private let tips: [Tip] = [
        // Saving Tips
        Tip(title: "50/30/20 Rule",
            description: "Distribute your income: 50% for needs, 30% for wants, 20% for savings.",
            category: .saving,
            icon: "percent"),
        Tip(title: "Automatic Transfers",
            description: "Set up automatic transfers of part of your salary to a savings account.",
            category: .saving,
            icon: "arrow.left.arrow.right"),
        Tip(title: "Cashback and Bonuses",
            description: "Use cashback cards and loyalty programs to get some of your spending back.",
            category: .saving,
            icon: "gift"),
        
        // Investing Tips
        Tip(title: "Diversification",
            description: "Distribute investments among different instruments to reduce risks.",
            category: .investing,
            icon: "chart.pie"),
        Tip(title: "Long-term Perspective",
            description: "Invest for the long term, don't react to short-term market fluctuations.",
            category: .investing,
            icon: "clock"),
        Tip(title: "Regular Investments",
            description: "Invest a fixed amount regularly, regardless of market conditions.",
            category: .investing,
            icon: "calendar"),
        
        // Habits Tips
        Tip(title: "Budgeting",
            description: "Regularly record all expenses for control and analysis.",
            category: .habits,
            icon: "list.bullet"),
        Tip(title: "Planned Purchases",
            description: "Make a shopping list in advance and stick to it.",
            category: .habits,
            icon: "checklist"),
        Tip(title: "Financial Goals",
            description: "Set specific financial goals and track your progress regularly.",
            category: .habits,
            icon: "target")
    ]
    
    var filteredTips: [Tip] {
        tips.filter { tip in
            let matchesCategory = selectedCategory == nil || tip.category == selectedCategory
            let matchesSearch = searchText.isEmpty || 
                tip.title.localizedCaseInsensitiveContains(searchText) ||
                tip.description.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesSearch
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color(.systemPurple).opacity(0.13), Color(.systemBlue).opacity(0.10)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ).ignoresSafeArea()
                
                VStack(spacing: 18) {
                    // Category Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            CategoryFilterButton(title: "All", isSelected: selectedCategory == nil) {
                                withAnimation { selectedCategory = nil }
                            }
                            ForEach(TipCategory.allCases, id: \.self) { category in
                                CategoryFilterButton(
                                    title: category.rawValue,
                                    icon: category.icon,
                                    color: category.color,
                                    isSelected: selectedCategory == category
                                ) {
                                    withAnimation { selectedCategory = category }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    
                    // Tips List
                    ScrollView {
                        LazyVStack(spacing: 18) {
                            ForEach(filteredTips) { tip in
                                GlassCard(cornerRadius: 22, opacity: 0.32) {
                                    TipCard(tip: tip)
                                }
                                .padding(.horizontal, 6)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("Tips")
            .searchable(text: $searchText, prompt: "Search tips")
        }
    }
}

struct CategoryFilterButton: View {
    let title: String
    var icon: String? = nil
    var color: String = "blue"
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(
                isSelected
                    ? AnyShapeStyle(LinearGradient(colors: [Color(color), .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    : AnyShapeStyle(Color(.systemGray6).opacity(0.7))
            )
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
            .shadow(color: isSelected ? Color(color).opacity(0.18) : .clear, radius: 6, x: 0, y: 3)
            .scaleEffect(isSelected ? 1.08 : 1.0)
            .animation(.spring(), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TipCard: View {
    let tip: Tip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [Color(tip.category.color), .purple.opacity(0.7)], startPoint: .top, endPoint: .bottom))
                        .frame(width: 38, height: 38)
                    Image(systemName: tip.icon)
                        .font(.title2)
                        .foregroundColor(.white)
                }
                Text(tip.title)
                    .font(.headline)
                Spacer()
                Text(tip.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(tip.category.color).opacity(0.18))
                    .foregroundColor(Color(tip.category.color))
                    .cornerRadius(8)
            }
            Text(tip.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    TipsView()
} 