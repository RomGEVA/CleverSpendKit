import SwiftUI

struct GradientButton: View {
    let title: String
    let action: () -> Void
    var gradient: LinearGradient = LinearGradient(
        colors: [Color.blue, Color.purple],
        startPoint: .leading,
        endPoint: .trailing
    )
    var cornerRadius: CGFloat = 16
    var height: CGFloat = 56
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .background(
                    gradient
                        .opacity(isPressed ? 0.7 : 1.0)
                )
                .cornerRadius(cornerRadius)
                .shadow(color: Color.purple.opacity(0.25), radius: 10, x: 0, y: 6)
                .scaleEffect(isPressed ? 0.97 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

#Preview {
    GradientButton(title: "Сохранить", action: {})
} 