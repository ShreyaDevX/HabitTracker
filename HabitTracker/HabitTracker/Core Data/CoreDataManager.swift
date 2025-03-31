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
