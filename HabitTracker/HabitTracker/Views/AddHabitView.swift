//
//  AddHabitView.swift
//  HabitTracker
//
//  Created by Shreya Pallan on 29/03/25.
//

import SwiftUI

struct AddHabitView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var habitName = ""

    var body: some View {
        VStack {
            TextField("Enter Habit Name", text: $habitName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Save Habit") {
                let newHabit = Habit(context: viewContext)
                newHabit.id = UUID()
                newHabit.name = habitName
                newHabit.streak = 0
                try? viewContext.save()
            }
            .padding()
        }
        .navigationTitle("New Habit")
    }
}

#Preview {
    AddHabitView()
}
