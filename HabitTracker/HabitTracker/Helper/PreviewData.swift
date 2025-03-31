//
//  PreviewData.swift
//  HabitTracker
//
//  Created by Shreya Pallan on 29/03/25.
//

import Foundation
import CoreData

struct PreviewData {
    static let shared = PreviewData()
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "HabitModel")
        container.loadPersistentStores { _, _ in }
        
        _ = container.viewContext
//        PreviewData.addSampleHabits(context: context)
    }
    
//    static func addSampleHabits(context: NSManagedObjectContext) {
//        
//        print("addSampleHabits called")
//        let habit1 = Habit(context: context)
//        habit1.id = UUID()
//        habit1.name = "Morning Run"
//        habit1.streak = 5
//        
//        let habit2 = Habit(context: context)
//        habit2.id = UUID()
//        habit2.name = "Read 10 Pages"
//        habit2.streak = 10
//        
//        try? context.save()
//    }
    
}
