import SwiftUI

struct CategoriesView: View {
    @State private var categories: [Category] = []
    @State private var showingAddCategory = false
    @State private var selectedPeriod: DatePeriod = .month
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color(.systemPurple).opacity(0.13), Color(.systemBlue).opacity(0.10)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ).ignoresSafeArea()
                
                VStack(spacing: 18) {
                    CustomSegmentedControl(selection: $selectedPeriod)
                        .padding(.horizontal)
                    
                    // Categories List
                    ScrollView {
                        LazyVStack(spacing: 18) {
                            ForEach(filteredCategories) { category in
                                NavigationLink(destination: CategoryExpensesView(category: category, period: selectedPeriod)) {
                                    GlassCard(cornerRadius: 20, opacity: 0.32) {
                                        CategoryRow(category: category, period: selectedPeriod)
                                    }
                                    .padding(.horizontal, 6)
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.top, 6)
                    }
                    
                    GradientButton(title: "Add Category") {
                        showingAddCategory = true
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                .padding(.top)
                .navigationTitle("Categories")
                .searchable(text: $searchText, prompt: "Search categories")
                .sheet(isPresented: $showingAddCategory) {
                    AddCategoryView { _ in
                        loadCategories()
                        selectedPeriod = .all
                    }
                }
                .onAppear {
                    loadCategories()
                }
            }
        }
    }
    
    private var filteredCategories: [Category] {
        if searchText.isEmpty {
            return categories
        }
        return categories.filter { category in
            category.name?.localizedCaseInsensitiveContains(searchText) ?? false
        }
    }
    
    private func loadCategories() {
        categories = CoreDataManager.shared.fetchCategories()
    }
    
    private func deleteCategories(at offsets: IndexSet) {
        for index in offsets {
            let category = categories[index]
            if category.isCustom {
                CoreDataManager.shared.deleteCategory(category)
            }
        }
        loadCategories()
    }
}

struct CategoryRow: View {
    let category: Category
    let period: DatePeriod
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color(category.color ?? "blue").opacity(0.7), Color(category.color ?? "blue").opacity(0.4)], startPoint: .top, endPoint: .bottom))
                    .frame(width: 48, height: 48)
                Image(systemName: category.icon ?? "folder")
                    .symbolRenderingMode(.palette)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name ?? "")
                    .font(.system(size: 18, weight: .semibold))
                let expenses = CoreDataManager.shared.fetchExpenses(for: category, period: period)
                let total = expenses.reduce(0) { $0 + $1.amount }
                Text(String(format: "$%.2f", total))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            // No lock icon
        }
        .padding(.vertical, 8)
    }
}

struct AddCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var selectedIcon = "folder"
    @State private var selectedColor = "blue"
    let onSave: (Category) -> Void
    
    private let icons = ["cart", "car", "house", "fork.knife", "gift", "heart", "airplane", "gamecontroller", "book", "cross", "pills", "graduationcap", "bag", "creditcard", "gym.bag"]
    private let colors = ["blue", "red", "green", "orange", "purple", "pink", "yellow"]
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [Color(.systemBlue).opacity(0.13), Color(.systemPurple).opacity(0.10)], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
                GlassCard(cornerRadius: 26, opacity: 0.38) {
                    VStack(spacing: 22) {
                        CustomTextField(title: "Category name", text: $name, icon: "tag")
                        IconPicker(icons: icons, selectedIcon: $selectedIcon, selectedColor: selectedColor)
                        ColorPickerRow(colors: colors, selectedColor: $selectedColor)
                        GradientButton(title: "Save") {
                            saveCategory()
                        }
                        .disabled(name.isEmpty)
                        .opacity(name.isEmpty ? 0.5 : 1)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 4)
                }
                .padding(.horizontal, 18)
            }
            .navigationTitle("New Category")
            .navigationBarItems(leading: Button("Cancel") { dismiss() })
        }
    }
    
    private func saveCategory() {
        let category = Category(context: CoreDataManager.shared.container.viewContext)
        category.id = UUID()
        category.name = name
        category.icon = selectedIcon
        category.color = selectedColor
        category.isCustom = true
        
        CoreDataManager.shared.save()
        onSave(category)
        dismiss()
    }
}

private struct IconPicker: View {
    let icons: [String]
    @Binding var selectedIcon: String
    var selectedColor: String
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 18) {
                ForEach(icons, id: \.self) { icon in
                    CategoryIconButton(
                        icon: icon,
                        isSelected: selectedIcon == icon,
                        selectedColor: selectedColor,
                        onTap: { selectedIcon = icon }
                    )
                }
            }
        }
    }
}

private struct CategoryIconButton: View {
    let icon: String
    let isSelected: Bool
    let selectedColor: String
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    isSelected
                        ? AnyShapeStyle(LinearGradient(colors: [Color(selectedColor), .purple], startPoint: .top, endPoint: .bottom))
                        : AnyShapeStyle(Color(.systemGray5))
                )
                .frame(width: 44, height: 44)
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isSelected ? .white : .primary)
        }
        .onTapGesture { onTap() }
        .scaleEffect(isSelected ? 1.15 : 1.0)
        .animation(.spring(), value: isSelected)
    }
}

private struct ColorPickerRow: View {
    let colors: [String]
    @Binding var selectedColor: String
    
    var body: some View {
        HStack(spacing: 18) {
            ForEach(colors, id: \.self) { color in
                Circle()
                    .fill(Color(color))
                    .frame(width: 30, height: 30)
                    .overlay(
                        Circle()
                            .stroke(Color.primary, lineWidth: selectedColor == color ? 2.5 : 0)
                    )
                    .onTapGesture { selectedColor = color }
                    .scaleEffect(selectedColor == color ? 1.18 : 1.0)
                    .animation(.spring(), value: selectedColor == color)
            }
        }
    }
}

struct CategoryExpensesView: View {
    let category: Category
    let period: DatePeriod
    @State private var expenses: [Expense] = []
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(.systemPurple).opacity(0.13), Color(.systemBlue).opacity(0.10)], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            ScrollView {
                LazyVStack(spacing: 14) {
                    ForEach(expenses) { expense in
                        GlassCard(cornerRadius: 18, opacity: 0.32) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(expense.date ?? Date(), style: .date)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(expense.amount, specifier: "%.2f") $")
                                        .font(.headline)
                                }
                                if let note = expense.note, !note.isEmpty {
                                    Text(note)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .padding(.horizontal, 8)
                    }
                }
                .padding(.top, 10)
            }
        }
        .navigationTitle(category.name ?? "")
        .onAppear {
            expenses = CoreDataManager.shared.fetchExpenses(for: category, period: period)
        }
    }
}

#Preview {
    CategoriesView()
} 
