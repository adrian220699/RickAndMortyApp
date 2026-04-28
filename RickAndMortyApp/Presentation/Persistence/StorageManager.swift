//
//  StorageManager.swift
//  RickAndMortyApp
//
//  Created by Adrian Flores Herrera on 4/27/26.
//

import Foundation

final class StorageManager {

    static let shared = StorageManager()
    private init() {}

    private let favoritesKey = "favorite_characters"
    private let watchedPrefix = "watched_episodes_"

    private let defaults = UserDefaults.standard

    // MARK: - FAVORITES

    func getFavorites() -> [Int] {
        defaults.array(forKey: favoritesKey) as? [Int] ?? []
    }

    func isFavorite(id: Int) -> Bool {
        getFavorites().contains(id)
    }

    func toggleFavorite(id: Int) {

        var current = getFavorites()

        if let index = current.firstIndex(of: id) {
            current.remove(at: index)
        } else {
            current.append(id)
        }

        defaults.set(current, forKey: favoritesKey)
    }

    // MARK: - EPISODES

    func getWatchedEpisodes(characterId: Int) -> [Int] {
        let key = watchedPrefix + "\(characterId)"
        return defaults.array(forKey: key) as? [Int] ?? []
    }

    func isEpisodeWatched(characterId: Int, episodeId: Int) -> Bool {
        getWatchedEpisodes(characterId: characterId).contains(episodeId)
    }

    func saveWatchedEpisodes(characterId: Int, ids: [Int]) {
        let key = watchedPrefix + "\(characterId)"
        defaults.set(ids, forKey: key)
    }

    func toggleEpisodeWatched(characterId: Int, episodeId: Int) {

        var current = getWatchedEpisodes(characterId: characterId)

        if let index = current.firstIndex(of: episodeId) {
            current.remove(at: index)
        } else {
            current.append(episodeId)
        }

        saveWatchedEpisodes(characterId: characterId, ids: current)
    }
}
