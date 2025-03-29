//
//  HabitRowView.swift
//  HabitTracker
//
//  Created by Shreya Pallan on 29/03/25.
//

import SwiftUI

struct HabitRowView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var habit: Habit
    
    var body: some View {
        HStack {
            Text(habit.name ?? "Unknown")
            Spacer()
            Text("Streak: \(habit.streak)")
//            Button("+1 Streak") {
//                habit.streak += 1
//                try? viewContext.save()
//            }
            
            Button {
                habit.streak += 1
                try? viewContext.save()
            } label: {
                Text("Increase Streak")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

        }
    }
}

#Preview {
    let context = PreviewData.shared.container.viewContext
    let habit = Habit(context: context)
    habit.id = UUID()
    habit.name = "Practice SwiftUI"
    habit.streak = 2
    
    // ✅ Save the object before using it
    try? context.save()
    
    return HabitRowView(habit: habit)
        .environment(\.managedObjectContext, context)
        .previewLayout(.sizeThatFits)
        .padding()
    
}
