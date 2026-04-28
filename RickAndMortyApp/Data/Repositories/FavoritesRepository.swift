//
//  FavoritesRepository.swift
//  RickAndMortyApp
//
//  Created by Adrian Flores Herrera on 4/28/26.
//

import Foundation
import CoreData

final class FavoritesRepository : FavoritesRepositoryProtocol{

    private let context = CoreDataManager.shared.context

    // MARK: - ADD FAVORITE
    func add(character: Character) {

        let entity = FavoriteCharacterEntity(context: context)

        entity.id = Int64(character.id)
        entity.name = character.name
        entity.species = character.species
        entity.image = character.image

        save()
    }

    // MARK: - REMOVE FAVORITE
    func remove(id: Int) {

        let request: NSFetchRequest<FavoriteCharacterEntity> =
            FavoriteCharacterEntity.fetchRequest()

        request.predicate = NSPredicate(format: "id == %d", id)

        do {
            let result = try context.fetch(request)

            if let object = result.first {
                context.delete(object)
                save()
            }

        } catch {
            print("❌ Remove fetch error:", error)
        }
    }

    // MARK: - GET FAVORITES
    func getFavorites() -> [Character] {

        let request: NSFetchRequest<FavoriteCharacterEntity> =
            FavoriteCharacterEntity.fetchRequest()

        do {
            let result = try context.fetch(request)

            print("⭐ CORE DATA FAVORITES COUNT:", result.count)

            return result.map {
                Character(
                    id: Int($0.id),
                    name: $0.name ?? "",
                    status: .unknown,
                    species: $0.species ?? "",
                    gender: "",
                    image: $0.image ?? "",
                    location: Location(name: "", latitude: 0, longitude: 0),
                    episodeURLs: [],
                    isFavorite: true
                )
            }

        } catch {
            print("❌ Fetch favorites error:", error)
            return []
        }
    }

    // MARK: - CHECK FAVORITE
    func isFavorite(id: Int) -> Bool {

        let request: NSFetchRequest<FavoriteCharacterEntity> =
            FavoriteCharacterEntity.fetchRequest()

        request.predicate = NSPredicate(format: "id == %d", id)

        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            print("❌ Count error:", error)
            return false
        }
    }

    // MARK: - SAVE
    private func save() {

        do {
            try context.save()
            print("💾 Core Data saved successfully")
        } catch {
            print("❌ Save error:", error)
        }
    }
}
