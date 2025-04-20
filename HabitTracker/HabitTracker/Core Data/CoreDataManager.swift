//
//  CoreDataManager.swift
//  HabitTracker
//
//  Created by Shreya Pallan on 29/03/25.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    let container: NSPersistentContainer
    var context: NSManagedObjectContext { container.viewContext }
    
    private init() {
        self.container = NSPersistentContainer(name: "HabitModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error)")
            }
        }
            
    }
    
    func save() {
        if context.hasChanges {
            print("Saving to context..")
            do {
                try context.save()
                print("Saved Successfully!")
                DispatchQueue.main.async {
                    self.context.refreshAllObjects()  // Forces Core Data to re-fetch
                }
            } catch {
                print("Failed to save context: \(error.localizedDescription)")
            }
        }
    }
    
    // - CRUD operations
    func addHabit(name: String) {
        let newHabit = Habit(context: context)
        newHabit.id = UUID()
        newHabit.name = name
        newHabit.streak = 0
        save()
    }
    
    func fetchHabits() -> [Habit] {
        let request: NSFetchRequest<Habit> = Habit.fetchRequest()
        let habits = try? context.fetch(request)
        return habits ?? []
    }
    
    func updateStreak(for habit: Habit) {
        habit.streak += 1
        save()
    }
    
    func deleteHabit(_ habit: Habit) {
        context.delete(habit)
        save()
    }
    
    
    // ✅ Add a Category
    func addCategory(name: String) {
        let category = Category(context: context)
        category.id = UUID()
    }
    
    func fetchCategories()-> [Category] {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        let categories = try? context.fetch(request)
        return categories ?? []
    }
    
    // ✅ Assign Habit to Category
       func addHabit(name: String, category: Category?) {
           let newHabit = Habit(context: context)
           newHabit.id = UUID()
           newHabit.name = name
           newHabit.streak = 0
           newHabit.dateCreated = Date()
           newHabit.category = category  // ✅ Assign Category
           save()
       }
    
    func fetchHabits(by category: Category) -> [Habit] {
        let request: NSFetchRequest<Habit> = Habit.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", category)
        do {
            let habits = try context.fetch(request)
            return habits
        } catch {
            print("Failed to fetch habits: \(error)")
            return []
        }
    }

}


extension CoreDataManager {
    
    func increaseStreakForCategory(in category: Category) {
//        guard let selectedCategory = selectedCategory else { return }
        
        let request = NSBatchUpdateRequest(entityName: "Habit")
        
        // Predicate to match habits with the selected category
        request.predicate = NSPredicate(format: "category == %@", category.objectID)
        
        // Create expression to increment streak by 1
        let streakKeyPath = NSExpression(forKeyPath: "streak")
        let one = NSExpression(forConstantValue: 1)
        let incrementExpression = NSExpression(forFunction: "add:to:", arguments: [streakKeyPath, one])
        
        request.propertiesToUpdate = ["streak": incrementExpression]
        request.resultType = .updatedObjectIDsResultType
        
        do {
            let result = try context.execute(request) as? NSBatchUpdateResult
            if let objectIDs = result?.result as? [NSManagedObjectID] {
                for objectID in objectIDs {
                    // ✅ Merge changes to inform SwiftUI/UIContext
                    let changes: [AnyHashable: Any] = [NSUpdatedObjectsKey: objectIDs]
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
                }
                    }
            try context.save()
            print("Streaks incremented for habits in category: \(category.name ?? "")")
        } catch {
            print("Failed to batch update streaks: \(error.localizedDescription)")
        }
        
    }
    
    func deleteOldHabits() {
        
//        guard let selectedCategory = selectedCategory else { return }
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Habit.fetchRequest()
        
        // Example: delete habits older than 6 months
        let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: Date())!
        fetchRequest.predicate = NSPredicate(format: "dateCreated < %@", sixMonthsAgo as NSDate)
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs
        
        do {
            let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
            if let objectIDs = result?.result as? [NSManagedObjectID] {
                NSManagedObjectContext.mergeChanges(
                    fromRemoteContextSave: [NSDeletedObjectsKey: objectIDs],
                    into: [context]
                )
            }
            print("Old habits deleted successfully.")
        } catch {
            print("Failed to delete old habits: \(error)")
        }
        
    }
    
    func fetchCategoriesWithHabitsPrefetched() -> [Category] {
        
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        // same as @FetchRequests in View
        request.relationshipKeyPathsForPrefetching = ["habits"] // 👈 prefetch habits

        do {
                return try context.fetch(request)
            } catch {
                print("Failed to fetch with prefetching: \(error)")
                return []
            }
        
    }
    
}
