//
//  CoreDataManager.swift
//  RickAndMortyApp
//
//  Created by Adrian Flores Herrera on 4/28/26.
//

internal import CoreData

final class CoreDataManager {

    static let shared = CoreDataManager()

    let container: NSPersistentContainer

    private init() {

        container = NSPersistentContainer(name: "RickAndMortyModel")
        container.loadPersistentStores { _, error in

            if let error = error {
                fatalError("CoreData error: \(error)")
            }
        }
    }

    var context: NSManagedObjectContext {
        container.viewContext
    }

    func save() {
        do {
            try context.save()
        } catch {
            print("Save error:", error)
        }
    }
}
