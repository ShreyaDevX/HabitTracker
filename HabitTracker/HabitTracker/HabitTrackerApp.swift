//
//  HabitTrackerApp.swift
//  HabitTracker
//
//  Created by Shreya Pallan on 29/03/25.
//

import SwiftUI

@main
struct HabitTrackerApp: App {
    let persistenceContainer = CoreDataManager.shared
    
    var body: some Scene {
        WindowGroup {
            HabitListView()
                .environment(\.managedObjectContext, persistenceContainer.context)
        }
    }
}
