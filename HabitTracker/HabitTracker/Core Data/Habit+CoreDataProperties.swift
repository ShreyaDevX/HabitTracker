//
//  Habit+CoreDataProperties.swift
//  HabitTracker
//
//  Created by Shreya Pallan on 18/04/25.
//
//

import Foundation
import CoreData


extension Habit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Habit> {
        return NSFetchRequest<Habit>(entityName: "Habit")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var streak: Int16
    @NSManaged public var dateCreated: Date?
    @NSManaged public var category: Category?

}
