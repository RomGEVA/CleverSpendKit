//
//  ContentView.swift
//  CleverSpendKit
//
//  Created by Роман Главацкий on 10.07.2025.
//

import SwiftUI

struct ContentView: View {
    let persistenceController = CoreDataManager.shared
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    
    init() {
        setupDefaultCategories()
    }
    
    var body: some View {
        RootView()
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
    
    private func setupDefaultCategories() {
        let categories = CoreDataManager.shared.fetchCategories()
        
        // Only add default categories if none exist
        guard categories.isEmpty else { return }
        
        let defaultCategories: [(name: String, icon: String, color: String)] = [
            ("Groceries", "cart.fill", "green"),
            ("Transport", "car.fill", "blue"),
            ("Housing", "house.fill", "orange"),
            ("Entertainment", "gamecontroller.fill", "purple"),
            ("Health", "heart.fill", "red"),
            ("Clothing", "bag.fill", "pink"),
            ("Restaurants", "fork.knife", "yellow"),
            ("Travel", "airplane", "indigo"),
            ("Education", "book.fill", "mint"),
            ("Gifts", "gift.fill", "teal")
        ]
        
        for category in defaultCategories {
            CoreDataManager.shared.addCategory(
                name: category.name,
                icon: category.icon,
                color: category.color,
                isCustom: false
            )
        }
    }
    
    private func clearAllCategories() {
        let categories = CoreDataManager.shared.fetchCategories()
        for category in categories {
            CoreDataManager.shared.deleteCategory(category)
        }
    }
}

#Preview {
    ContentView()
}

struct RootView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var showOnboarding = false
    
    var body: some View {
        ZStack {
            MainTabView()
                .disabled(showOnboarding)
                .blur(radius: showOnboarding ? 8 : 0)
            if showOnboarding {
                OnboardingView(isPresented: $showOnboarding)
                    .transition(.opacity)
            }
        }
        .onAppear {
            showOnboarding = !hasSeenOnboarding
        }
        .onChange(of: showOnboarding) { newValue in
            if !newValue {
                hasSeenOnboarding = true
            }
        }
    }
}
