//
//  EditHabitView.swift
//  HabitTracker
//
//  Created by Shreya Pallan on 31/03/25.
//

import SwiftUI

struct EditHabitView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss  // To dismiss the view after saving
    
    @ObservedObject var habit: Habit  // The habit being edited
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)])
    var categories: FetchedResults<Category>
    
    @State private var habitName: String
    @State private var selectedCategory: Category?
    @State private var streak: Int

    init(habit: Habit) {
        self.habit = habit
        _habitName = State(initialValue: habit.name ?? "")
        _selectedCategory = State(initialValue: habit.category)
        _streak = State(initialValue: Int(habit.streak))
    }

    var body: some View {
        Form {
            Section(header: Text("Habit Details")) {
                TextField("Habit Name", text: $habitName)
                
                Picker("Category", selection: $selectedCategory) {
                    ForEach(categories, id: \.self) { category in
                        Text(category.name ?? "Unknown")
                            .tag(category as Category?)
                    }
                }
                
                Stepper("Streak: \(streak)", value: $streak, in: 0...100)
            }
            
            Button("Save Changes") {
                updateHabit()
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Edit Habit")
    }

    private func updateHabit() {
        habit.name = habitName
        habit.category = selectedCategory
        habit.streak = Int16(streak)
        
        CoreDataManager.shared.save()
        dismiss()  // Close the view after saving
    }
}


#Preview {
    let context = PreviewData.shared.container.viewContext
    let habit = Habit(context: context)
    
    habit.id = UUID()
    habit.name = "Practice SwiftUI"
    habit.streak = 2
    return EditHabitView(habit: habit)
        .environment(\.managedObjectContext, context)
        
}
