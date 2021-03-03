//
//  Tasks+CoreDataProperties.swift
//  ToDoList
//
//  Created by Евгений Клюенков on 03.03.2021.
//
//

import Foundation
import CoreData


extension Tasks {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tasks> {
        return NSFetchRequest<Tasks>(entityName: "Tasks")
    }

    @NSManaged public var isCompleted: Bool
    @NSManaged public var title: String?
    @NSManaged public var date: Date?

}

extension Tasks : Identifiable {

}
