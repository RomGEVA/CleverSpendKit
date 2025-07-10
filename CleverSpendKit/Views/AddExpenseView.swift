import SwiftUI

struct AddExpenseView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var amount: String = ""
    @State private var selectedCategory: Category?
    @State private var date = Date()
    @State private var note: String = ""
    @State private var showingCategoryPicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private let categories = CoreDataManager.shared.fetchCategories()
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color(.systemBlue).opacity(0.18), Color(.systemPurple).opacity(0.12)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 28) {
                        GlassCard {
                            VStack(spacing: 18) {
                                CustomTextField(title: "Amount", text: $amount, keyboardType: .decimalPad, icon: "dollarsign.circle")
                                
                                Button(action: { showingCategoryPicker = true }) {
                                    HStack {
                                        ZStack {
                                            Circle()
                                                .fill(Color(.systemBackground).opacity(0.18))
                                                .frame(width: 28, height: 28)
                                            Image(systemName: selectedCategory?.icon ?? "folder")
                                                .symbolRenderingMode(.palette)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 18, height: 18)
                                                .foregroundStyle(
                                                    LinearGradient(
                                                        colors: [Color.blue, Color.purple],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                        }
                                        Text(selectedCategory?.name ?? "Select category")
                                            .foregroundColor(selectedCategory == nil ? .secondary : .primary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color(.systemBackground).opacity(0.7))
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                DatePicker("Date", selection: $date, displayedComponents: [.date])
                                    .datePickerStyle(.compact)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color(.systemBackground).opacity(0.7))
                                    )
                                
                                CustomTextField(title: "Note", text: $note, icon: "text.bubble")
                            }
                        }
                        .padding(.horizontal)
                        
                        GradientButton(title: "Save", action: saveExpense)
                            .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("New Expense")
            .sheet(isPresented: $showingCategoryPicker) {
                CategoryPickerView(selectedCategory: $selectedCategory)
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func saveExpense() {
        guard let amountDouble = Double(amount.replacingOccurrences(of: ",", with: ".")) else {
            alertMessage = "Please enter a valid amount"
            showingAlert = true
            return
        }
        
        guard let category = selectedCategory else {
            alertMessage = "Please select a category"
            showingAlert = true
            return
        }
        
        CoreDataManager.shared.addExpense(
            amount: amountDouble,
            date: date,
            note: note.isEmpty ? nil : note,
            category: category
        )
        
        // Reset form
        amount = ""
        selectedCategory = nil
        date = Date()
        note = ""
    }
}

struct CategoryPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCategory: Category?
    private let categories = CoreDataManager.shared.fetchCategories()
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [Color(.systemPurple).opacity(0.13), Color(.systemBlue).opacity(0.10)], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
                if categories.count > 6 {
                    GeometryReader { geometry in
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(categories) { category in
                                    Button(action: {
                                        withAnimation(.spring()) {
                                            selectedCategory = category
                                        }
                                    }) {
                                        HStack(spacing: 16) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color(.systemBackground).opacity(0.18))
                                                    .frame(width: 44, height: 44)
                                                Image(systemName: category.icon ?? "folder")
                                                    .symbolRenderingMode(.palette)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 26, height: 26)
                                                    .foregroundStyle(
                                                        LinearGradient(
                                                            colors: [Color.blue, Color.purple],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    )
                                            }
                                            Text(category.name ?? "")
                                                .font(.system(size: 17, weight: .medium))
                                                .foregroundColor(.primary)
                                            Spacer()
                                            if selectedCategory?.id == category.id {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(Color(category.color ?? "blue"))
                                                    .font(.system(size: 22, weight: .bold))
                                                    .transition(.scale)
                                            }
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 18)
                                                .fill(Color(.systemBackground).opacity(selectedCategory?.id == category.id ? 0.38 : 0.22))
                                                .shadow(color: Color(category.color ?? "blue").opacity(selectedCategory?.id == category.id ? 0.18 : 0.08), radius: 8, x: 0, y: 4)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .onTapGesture(count: 2) {
                                        withAnimation(.spring()) {
                                            selectedCategory = category
                                            dismiss()
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 18)
                            .padding(.horizontal, 12)
                            .frame(minHeight: geometry.size.height)
                        }
                    }
                } else {
                    VStack(spacing: 16) {
                        ForEach(categories) { category in
                            Button(action: {
                                withAnimation(.spring()) {
                                    selectedCategory = category
                                }
                            }) {
                                HStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(.systemBackground).opacity(0.18))
                                            .frame(width: 44, height: 44)
                                        Image(systemName: category.icon ?? "folder")
                                            .symbolRenderingMode(.palette)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 26, height: 26)
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [Color.blue, Color.purple],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                    }
                                    Text(category.name ?? "")
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if selectedCategory?.id == category.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Color(category.color ?? "blue"))
                                            .font(.system(size: 22, weight: .bold))
                                            .transition(.scale)
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color(.systemBackground).opacity(selectedCategory?.id == category.id ? 0.38 : 0.22))
                                        .shadow(color: Color(category.color ?? "blue").opacity(selectedCategory?.id == category.id ? 0.18 : 0.08), radius: 8, x: 0, y: 4)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .onTapGesture(count: 2) {
                                withAnimation(.spring()) {
                                    selectedCategory = category
                                    dismiss()
                                }
                            }
                        }
                    }
                    .padding(.vertical, 18)
                    .padding(.horizontal, 12)
                }
            }
            .navigationTitle("Select category")
            .navigationBarItems(trailing: Button("Close") {
                dismiss()
            })
        }
        .interactiveDismissDisabled(true)
    }
}

#Preview {
    AddExpenseView()
} 