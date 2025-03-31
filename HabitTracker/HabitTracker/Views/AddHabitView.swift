//
//  AddHabitView.swift
//  HabitTracker
//
//  Created by Shreya Pallan on 29/03/25.
//

import SwiftUI

struct AddHabitView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @State private var habitName = ""
    @State private var selectedCategory: Category?
    
    @FetchRequest(sortDescriptors: []) var categories: FetchedResults<Category>

    var body: some View {
        VStack {
            TextField("Enter Habit Name", text: $habitName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Picker("Category", selection: $selectedCategory) {
                Text("None").tag(nil as Category?)
                ForEach(categories) { category in
                    Text(category.name ?? "Unknown").tag(category as Category?)
                }
            }

            Button("Save Habit") {
//                let newHabit = Habit(context: viewContext)
//                newHabit.id = UUID()
//                newHabit.name = habitName
//                newHabit.streak = 0
//                try? viewContext.save()
                
                
                CoreDataManager.shared.addHabit(name: habitName, category: selectedCategory)
                dismiss()
            }
            .padding()
        }
        .navigationTitle("New Habit")
    }
}

#Preview {
    AddHabitView()
}
