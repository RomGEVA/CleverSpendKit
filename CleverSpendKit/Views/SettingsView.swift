import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var showResetAlert = false
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [Color(.systemPurple).opacity(0.13), Color(.systemBlue).opacity(0.10)], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
                GlassCard(cornerRadius: 22, opacity: 0.32) {
                    VStack(spacing: 24) {
                        GradientButton(title: "Rate App") {
                            rateApp()
                        }
                        GradientButton(title: "Privacy Policy") {
                            openPrivacyPolicy()
                        }
                        GradientButton(title: "Reset All Data") {
                            showResetAlert = true
                        }
                    }
                    .padding(32)
                }
                .padding(.horizontal, 24)
            }
            .navigationTitle("Settings")
            .alert("Are you sure you want to reset all data? This cannot be undone.", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) { resetAllData() }
            }
        }
    }
    
    private func rateApp() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    private func openPrivacyPolicy() {
        guard let url = URL(string: "https://your-privacy-policy-url.com") else { return }
        UIApplication.shared.open(url)
    }
    
    private func resetAllData() {
        CoreDataManager.shared.deleteAllExpenses()
        CoreDataManager.shared.deleteAllCategories()
    }
}

#Preview {
    SettingsView()
} 