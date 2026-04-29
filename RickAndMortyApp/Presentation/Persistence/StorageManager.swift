//
//  StorageManager.swift
//  RickAndMortyApp
//
//  Created by Adrian Flores Herrera on 4/27/26.
//

import Foundation
internal import CoreData

final class StorageManager {

    static let shared = StorageManager()
    private init() {}

    let container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "RickAndMortyModel")

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("CoreData error: \(error)")
            }
        }

        return container
    }()

    var context: NSManagedObjectContext {
        container.viewContext
    }

    // MARK: - SAVE

    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("❌ CoreData save error:", error)
            }
        }
    }

    // MARK: - WATCHED EPISODES

    func getWatchedEpisodes(characterId: Int) -> [Int] {

        let request = NSFetchRequest<WatchedEpisodeEntity>(
            entityName: "WatchedEpisodeEntity"
        )

        request.predicate = NSPredicate(format: "characterId == %d", characterId)

        let result = (try? context.fetch(request)) ?? []

        return result.map { Int($0.id) }
    }

    func isEpisodeWatched(characterId: Int, episodeId: Int) -> Bool {

        let request = NSFetchRequest<WatchedEpisodeEntity>(
            entityName: "WatchedEpisodeEntity"
        )

        request.predicate = NSPredicate(
            format: "characterId == %d AND id == %d",
            characterId,
            episodeId
        )

        let result = (try? context.fetch(request)) ?? []

        return !result.isEmpty
    }

    func toggleEpisodeWatched(characterId: Int, episodeId: Int) {

        let request = NSFetchRequest<WatchedEpisodeEntity>(
            entityName: "WatchedEpisodeEntity"
        )

        request.predicate = NSPredicate(
            format: "characterId == %d AND id == %d",
            characterId,
            episodeId
        )

        let result = (try? context.fetch(request)) ?? []

        if let existing = result.first {
            context.delete(existing)
        } else {
            let entity = WatchedEpisodeEntity(context: context)
            entity.id = Int64(episodeId)
            entity.characterId = Int64(characterId)
        }

        saveContext()
    }
}
