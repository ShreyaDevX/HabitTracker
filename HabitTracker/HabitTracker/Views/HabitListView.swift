//
//  HabitListView.swift
//  HabitTracker
//
//  Created by Shreya Pallan on 29/03/25.
//

import SwiftUI

struct HabitListView: View {
    @Environment(\.managedObjectContext) var viewContext
    
    @FetchRequest(entity: Habit.entity(), sortDescriptors: []) var habits: FetchedResults<Habit>
    
    @State private var forceUpdate = false

    
    var body: some View {
        NavigationView {
            List {
                ForEach(habits, id: \.id) { habit in
//                    HabitRowView(habit: habit) // ⛔️ Won't track updates when passed as plain refernece
                    HabitRowView(habit: habit)
                }
                .onDelete(perform: deleteHabit)
            }
            //.background(Color.blue)
            .id(forceUpdate)
            .navigationTitle("Habits")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Add", destination: AddHabitView())
                }
            }

        }
        .onAppear {
            forceUpdate.toggle()
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
