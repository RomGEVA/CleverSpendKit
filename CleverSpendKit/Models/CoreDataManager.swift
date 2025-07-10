import CoreData
import SwiftUI

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "CleverSpend")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Category Operations
    
    func addCategory(name: String, icon: String, color: String, isCustom: Bool = true) {
        let category = Category(context: container.viewContext)
        category.id = UUID()
        category.name = name
        category.icon = icon
        category.color = color
        category.isCustom = isCustom
        
        save()
    }
    
    func deleteCategory(_ category: Category) {
        container.viewContext.delete(category)
        save()
    }
    
    func fetchCategories() -> [Category] {
        let request = NSFetchRequest<Category>(entityName: "Category")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Error fetching categories: \(error)")
            return []
        }
    }
    
    // MARK: - Expense Operations
    
    func addExpense(amount: Double, date: Date, note: String?, category: Category) {
        let expense = Expense(context: container.viewContext)
        expense.id = UUID()
        expense.amount = amount
        expense.date = date
        expense.note = note
        expense.category = category
        
        save()
    }
    
    func deleteExpense(_ expense: Expense) {
        container.viewContext.delete(expense)
        save()
    }
    
    func fetchExpenses(for category: Category? = nil, period: DatePeriod = .all) -> [Expense] {
        let request = NSFetchRequest<Expense>(entityName: "Expense")
        
        var predicates: [NSPredicate] = []
        
        if let category = category {
            predicates.append(NSPredicate(format: "category == %@", category))
        }
        
        if period != .all {
            let calendar = Calendar.current
            let startDate: Date
            
            switch period {
            case .day:
                startDate = calendar.startOfDay(for: Date())
            case .month:
                startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
            case .year:
                startDate = calendar.date(from: calendar.dateComponents([.year], from: Date()))!
            case .all:
                startDate = Date.distantPast
            }
            
            predicates.append(NSPredicate(format: "date >= %@", startDate as NSDate))
        }
        
        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Expense.date, ascending: false)]
        
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Error fetching expenses: \(error)")
            return []
        }
    }
    
    // MARK: - Helper Methods
    
    func save() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    // MARK: - Bulk Delete Methods
    
    func deleteAllExpenses() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Expense")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try container.persistentStoreCoordinator.execute(deleteRequest, with: container.viewContext)
            save()
        } catch {
            print("Error deleting all expenses: \(error)")
        }
    }
    
    func deleteAllCategories() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Category")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try container.persistentStoreCoordinator.execute(deleteRequest, with: container.viewContext)
            save()
        } catch {
            print("Error deleting all categories: \(error)")
        }
    }
}

enum DatePeriod {
    case day
    case month
    case year
    case all
} 