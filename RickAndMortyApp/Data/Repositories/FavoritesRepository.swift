//
//  FavoritesRepository.swift
//  RickAndMortyApp
//
//  Created by Adrian Flores Herrera on 4/28/26.
//

import Foundation
internal import CoreData

final class FavoritesRepository: FavoritesRepositoryProtocol {

    private let storage = StorageManager.shared

    // MARK: - GET

    func getFavorites() -> [Character] {

        let request = NSFetchRequest<FavoriteCharacterEntity>(
            entityName: "FavoriteCharacterEntity"
        )

        guard let result = try? storage.context.fetch(request) else {
            return []
        }

        return result.map { entity in

            let location: Location? = {
                if entity.locationName != nil {
                    return Location(
                        name: entity.locationName ?? "",
                        latitude: entity.latitude,
                        longitude: entity.longitude
                    )
                }
                return nil
            }()

            return Character(
                id: Int(entity.id),
                name: entity.name ?? "",
                status: .unknown,
                species: "",
                gender: "",
                image: entity.image ?? "",
                location: location,
                episodeURLs: [],
                isFavorite: true
            )
        }
    }

    // MARK: - SAVE

    func saveFavorite(_ character: Character) {

        let entity = FavoriteCharacterEntity(context: storage.context)

        entity.id = Int64(character.id)
        entity.name = character.name
        entity.image = character.image

        if let location = character.location {
            entity.latitude = location.latitude
            entity.longitude = location.longitude
            entity.locationName = location.name
        }

        storage.saveContext()
    }

    // MARK: - DELETE

    func deleteFavorite(id: Int) {

        let request = NSFetchRequest<FavoriteCharacterEntity>(
            entityName: "FavoriteCharacterEntity"
        )

        request.predicate = NSPredicate(format: "id == %d", Int64(id))

        if let result = try? storage.context.fetch(request),
           let object = result.first {

            storage.context.delete(object)
            storage.saveContext()
        }
    }

    // MARK: - CHECK

    func isFavorite(id: Int) -> Bool {

        let request = NSFetchRequest<FavoriteCharacterEntity>(
            entityName: "FavoriteCharacterEntity"
        )

        request.predicate = NSPredicate(format: "id == %d", Int64(id))

        let result = (try? storage.context.fetch(request)) ?? []

        return !result.isEmpty
    }
}
