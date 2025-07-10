import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var page = 0
    
    let pages: [(title: String, desc: String, image: String)] = [
        ("Welcome to CleverSpend", "Your modern way to track expenses and save smarter.", "sparkles"),
        ("Track Every Dollar", "Add expenses, organize by category, and see where your money goes.", "list.bullet.rectangle.portrait"),
        ("Get Insights", "Visualize your spending and get tips to improve your finances.", "chart.pie.fill")
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(.systemPurple).opacity(0.13), Color(.systemBlue).opacity(0.10)], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            GlassCard(cornerRadius: 28, opacity: 0.38) {
                VStack(spacing: 32) {
                    Spacer()
                    Image(systemName: pages[page].image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                        .foregroundStyle(LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom))
                        .shadow(radius: 8)
                    Text(pages[page].title)
                        .font(.title.bold())
                        .multilineTextAlignment(.center)
                    Text(pages[page].desc)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Spacer()
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { i in
                            Circle()
                                .fill(i == page ? Color.blue : Color.gray.opacity(0.3))
                                .frame(width: 10, height: 10)
                        }
                    }
                    if page < pages.count - 1 {
                        GradientButton(title: "Next") {
                            withAnimation { page += 1 }
                        }
                    } else {
                        GradientButton(title: "Get Started") {
                            isPresented = false
                        }
                    }
                }
                .padding(28)
                .frame(maxWidth: 400)
            }
            .padding(24)
        }
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
} 