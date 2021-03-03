//
//  TaskStoreManager.swift
//  ToDoList
//
//  Created by Евгений Клюенков on 03.03.2021.
//

import Foundation
import CoreData

class TaskStoreManager {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDoListModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var viewContext = persistentContainer.viewContext
    
    func obtainTasks() -> [Tasks]{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
        if let tasks = try? viewContext.fetch(fetchRequest) as? [Tasks] {
            return tasks
        } else {
            let task = [Tasks(context: viewContext)]
            task[0].title = "Нет задач"
            task[0].date = Date()
            do {
                try viewContext.save()
            } catch let error{
                print(error)
            }
            return task
        }
    }
    
    func addNewTask(with title: String) -> Tasks{
        let task = Tasks(context: viewContext)
        if title != "" {
            task.title = title
            task.date = Date()
        }
        try? viewContext.save()
        return task
    }
    
    func deleteTask(with name: Tasks) {
        viewContext.delete(name)
        try? viewContext.save()
    }
    
    func editTask(name: Tasks, text: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
        if let tasks = try? viewContext.fetch(fetchRequest) as? [Tasks] {
            for obj in tasks{
                if obj == name {
                    if obj.title != text {
                        obj.title = text
                        obj.date = Date()
                    }
                }
            }
        }
        try? viewContext.save()
    }
}
