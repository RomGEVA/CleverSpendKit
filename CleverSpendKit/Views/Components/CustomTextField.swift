import SwiftUI

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var icon: String? = nil
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(.blue)
            }
            TextField(title, text: $text)
                .keyboardType(keyboardType)
                .focused($isFocused)
                .padding(.vertical, 12)
        }
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground).opacity(0.7))
                .shadow(color: isFocused ? Color.blue.opacity(0.18) : Color.black.opacity(0.07), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isFocused
                        ? AnyShapeStyle(LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing))
                        : AnyShapeStyle(Color(.systemGray4)),
                    lineWidth: 2
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

#Preview {
    CustomTextField(title: "Сумма", text: .constant(""), keyboardType: .decimalPad, icon: "rublesign.circle")
} 