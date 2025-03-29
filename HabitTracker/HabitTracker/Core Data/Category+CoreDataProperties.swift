//
//  Category+CoreDataProperties.swift
//  HabitTracker
//
//  Created by Shreya Pallan on 30/03/25.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var name: String?
    @NSManaged public var habits: NSSet?

}

// MARK: Generated accessors for habits
extension Category {

    @objc(addHabitsObject:)
    @NSManaged public func addToHabits(_ value: Habit)

    @objc(removeHabitsObject:)
    @NSManaged public func removeFromHabits(_ value: Habit)

    @objc(addHabits:)
    @NSManaged public func addToHabits(_ values: NSSet)

    @objc(removeHabits:)
    @NSManaged public func removeFromHabits(_ values: NSSet)

}

extension Category : Identifiable {

}
