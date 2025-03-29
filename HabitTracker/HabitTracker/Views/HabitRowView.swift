//
//  HabitRowView.swift
//  HabitTracker
//
//  Created by Shreya Pallan on 29/03/25.
//

import SwiftUI

struct HabitRowView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var habit: Habit // USe as ObservedObject else it wont work if it is just a var property. Since Habit is an NSManagedObject, it already conforms to ObservableObject internally. This means SwiftUI can track its changes only if we use @ObservedObject in the subview. Reason below
    
    var body: some View {
        HStack {
            Text(habit.name ?? "Unknown")
            Spacer()
            Text("Streak: \(habit.streak)")
            
            Button {
                DispatchQueue.main.async {
                    updateStreak(for: habit)
                }
                
            } label: {
                Text("Increase Streak")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

        }
    }
    
//    @MainActor
    func updateStreak(for habit: Habit) {
        habit.streak += 1
        CoreDataManager.shared.save()
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


/* Reason : This happens because of how SwiftUI handles state updates with Core Data objects in separate subviews. Here’s what’s going wrong and how to fix it.
 
 🔹 Why Is the UI Updating Only in HabitListView?
 1️⃣ SwiftUI Only Tracks Direct State Changes in a View
 In HabitListView, @FetchRequest is directly observing the habit objects.

 When you modify habit.streak, SwiftUI recognizes the change because it's happening inside the same view that owns the @FetchRequest.

 2️⃣ When Using HabitRowView, SwiftUI Doesn't Know the Object Changed
 Core Data's NSManagedObject doesn't trigger SwiftUI updates automatically when modified inside a subview.

 HabitRowView only receives a reference to habit, but SwiftUI doesn’t track changes inside that reference.*/




/* Why Binding won't work
 
 There's a problem with .constant(habit) when used with @Binding<Habit>.

 🚨 What's Wrong?
 swift
 Copy
 Edit
 HabitRowView(habit: .constant(habit))
 .constant(habit) creates a static, immutable binding to habit.

 But habit is a reference type (NSManagedObject), and @Binding expects a struct or value type.

 Core Data objects (NSManagedObject) don't work well with @Binding!
 
 
 */

/*
 
 ✅ Fix: Use @ObservedObject Instead of @Binding
 Since Habit is an NSManagedObject, it already conforms to ObservableObject internally.
 This means SwiftUI can track its changes only if we use @ObservedObject in the subview.
 
 */
