//
//  HabitListView.swift
//  HabitTracker
//
//  Created by Shreya Pallan on 29/03/25.
//

import SwiftUI
import CoreData

struct HabitListView: View {
    @Environment(\.managedObjectContext) var viewContext
    
//    @FetchRequest(entity: Habit.entity(), sortDescriptors: []) var habits: FetchedResults<Habit>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)]) var categories: FetchedResults<Category>
    
    @State private var selectedCategory: Category? = nil
    @State private var sortOption: SortOption = .name
    
    var body: some View {
        
        NavigationView {
            VStack {
                HStack {
                    Picker("Filter", selection: $selectedCategory) {
                        Text("All").tag(nil as Category?)
                        ForEach(categories) { category in
                            Text(category.name ?? "Unknown").tag(category as Category?)
                        }
                    }
                    
                    Picker("Sort by", selection: $sortOption) {
                        Text("Name").tag(SortOption.name)
                        Text("Streak").tag(SortOption.streak)
                    }
                }
                
                List {
                    ForEach(filteredCategories) { category in
                        Section(header: Text(category.name ?? "Uncategorized").bold()) {
                            // For each category, filter and sort habits
                           
                                let habits = filteredHabits(for: category)
                            ForEach(habits, id: \.objectID) { habit in
                                    HabitRowView(habit: habit)
                                }
                                .onDelete { indices in
                                    deleteHabit(for: category, at: indices)
                                }
                            
                            
                        }
                    }
                }.listStyle(GroupedListStyle())
                
                HStack {
                    Button("Increase Streak for All in Category") {
                        
                        if let selectedCategory = selectedCategory {
                            DispatchQueue.main.async {
                                CoreDataManager.shared.increaseStreakForCategory(in: selectedCategory)
                            }
                        }
                    }
                    
                    Button("Delete Habits Older Than 6 Months") {
                        if selectedCategory != nil {
                            DispatchQueue.main.async {
                                CoreDataManager.shared.deleteOldHabits()
                            }
                        }
                    }
                }
            }
            
            .navigationTitle("Habits")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Add", destination: AddHabitView())
                }
            }
            .onAppear {
                //deleteAllData()
                addSampleData()
               // removeDuplicateCategories()
            }
        }
     
    }
       
    func deleteHabit(for category: Category, at offsets: IndexSet) {
        for index in offsets {
            let habit = filteredHabits(for: category)[index]
            viewContext.delete(habit)
        }
        try? viewContext.save()
    }
    
    private var filteredCategories: [Category] {
           if let selectedCategory = selectedCategory {
               return [selectedCategory]  // Only the selected category
           } else {
               return categories.filter { !$0.habitsArray.isEmpty }  // All categories with habits
           }
       }
    
    private func filteredHabits(for category: Category) -> [Habit] {
        let allHabits = category.habitsArray
            
        let filtered = allHabits.filter { habit in
            // Return filtered habits if category is selected or all habits if not
            return selectedCategory == nil || habit.category == selectedCategory
        }
            
            return sortOption == .name
                ? filtered.sorted { ($0.name ?? "") < ($1.name ?? "") }
                : filtered.sorted { $0.streak > $1.streak }
        }
    
    enum SortOption {
        case name, streak
    }
    
    func addSampleData() {
        print("addSampleData called")
        
        let context = viewContext
        
        // Fetch existing categories to prevent duplicates
        let categoryFetch: NSFetchRequest<Category> = Category.fetchRequest()
        let existingCategories = (try? context.fetch(categoryFetch)) ?? []
        
        // Health Category
        if existingCategories.first(where: { $0.name == "Health" }) == nil {
            let category1 = Category(context: context)
            category1.id = UUID()
            category1.name = "Health"
            
            // Fetch existing habits in the Health category
            let existingHabitsInHealth = category1.habitsArray
            if existingHabitsInHealth.first(where: { $0.name == "Go to Gym" }) == nil {
                let habit2 = Habit(context: context)
                habit2.id = UUID()
                habit2.name = "Go to Gym"
                habit2.streak = 3
                habit2.category = category1
            }
        }
        
        // Productivity Category
        if existingCategories.first(where: { $0.name == "Productivity" }) == nil {
            let category2 = Category(context: context)
            category2.id = UUID()
            category2.name = "Productivity"
            
            // Fetch existing habits in the Productivity category
            let existingHabitsInProductivity = category2.habitsArray
            if existingHabitsInProductivity.first(where: { $0.name == "Read 10 Pages" }) == nil {
                let habit3 = Habit(context: context)
                habit3.id = UUID()
                habit3.name = "Read 10 Pages"
                habit3.streak = 5
                habit3.category = category2
            }
        }

        // Learning Category
        if existingCategories.first(where: { $0.name == "Learning" }) == nil {
            let category3 = Category(context: context)
            category3.id = UUID()
            category3.name = "Learning"
            
            // Fetch existing habits in the Learning category
            let existingHabitsInLearning = category3.habitsArray
            if existingHabitsInLearning.first(where: { $0.name == "Practice SwiftUI" }) == nil {
                let habit1 = Habit(context: context)
                habit1.id = UUID()
                habit1.name = "Practice SwiftUI"
                habit1.streak = 7
                habit1.category = category3
            }
        }
        
        // Save changes to Core Data
        try? context.save()
    }

    
    func removeDuplicateCategories() {
        print("removeDuplicateCategories called")
            let context = viewContext
            
            // Fetch all categories
            let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
            
            do {
                let allCategories = try context.fetch(fetchRequest)
                
                // Create a set to track already seen categories
                var seenCategories = Set<String>()
                
                // Loop through all fetched categories
                for category in allCategories {
                    
                    print("category \(category.name) Habits \(category.habitsArray[0].name)")
                    if let categoryName = category.name {
                        if seenCategories.contains(categoryName) {
                            // If category already exists in the set, delete this duplicate
                            context.delete(category)
                        } else {
                            // Otherwise, add it to the set
                            seenCategories.insert(categoryName)
                        }
                    }
                }
                print("seenCategories: \(seenCategories)")
                // Save context after removing duplicates
                try context.save()
                
                print("Duplicate categories removed successfully!")
                
            } catch {
                print("Error fetching categories: \(error)")
            }
        }
}




// ✅ Extension to Convert Habit Set to Array
extension Category {
    var habitsArray: [Habit] {
        let set = habits as? Set<Habit> ?? []
        return set.sorted { $0.name ?? "" < $1.name ?? "" }
    }
}

#Preview {
    HabitListView()
        .environment(\.managedObjectContext, PreviewData.shared.container.viewContext)
}


extension HabitListView {
    func deleteAllData() {
        let context = viewContext
        
        // Create a fetch request for each entity in your Core Data model
        let entities = ["Category", "Habit"] // List all your entity names here
        
        for entity in entities {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity)
            
            do {
                // Fetch all objects of this entity
                let objects = try context.fetch(fetchRequest)
                
                // Delete each object
                for object in objects {
                    if let objectToDelete = object as? NSManagedObject {
                        context.delete(objectToDelete)
                    }
                }
                
                // Save the context after deleting the objects
                try context.save()
                print("Deleted all data for entity \(entity)")
            } catch {
                print("Error deleting data for entity \(entity): \(error)")
            }
        }
    }
}

