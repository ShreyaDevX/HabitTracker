//
//  HabitListView.swift
//  HabitTracker
//
//  Created by Shreya Pallan on 29/03/25.
//

import SwiftUI

struct HabitListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: []) var habits: FetchedResults<Habit>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(habits) { habit in
                    HabitRowView(habit: habit)
                }
                .onDelete(perform: deleteHabit)
            }
            //.background(Color.blue)
            .navigationTitle("Habits")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Add", destination: AddHabitView())
                }
            }

        }
    }
    
    
    
    func deleteHabit(at offsets: IndexSet) {
        for index in offsets {
            viewContext.delete(habits[index])
        }
        try? viewContext.save()
    }
}

#Preview {
    HabitListView()
        .environment(\.managedObjectContext, PreviewData.shared.container.viewContext)
}
