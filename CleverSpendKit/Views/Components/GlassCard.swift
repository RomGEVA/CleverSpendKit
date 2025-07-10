import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat = 22
    var blur: CGFloat = 18
    var opacity: Double = 0.35
    
    init(cornerRadius: CGFloat = 22, blur: CGFloat = 18, opacity: Double = 0.35, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.blur = blur
        self.opacity = opacity
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.white.opacity(opacity))
                .background(
                    BlurView(style: .systemUltraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                )
                .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
            content
                .padding()
        }
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

#Preview {
    GlassCard {
        VStack {
            Text("Glass Card Example")
            Image(systemName: "star.fill")
        }
    }
} 