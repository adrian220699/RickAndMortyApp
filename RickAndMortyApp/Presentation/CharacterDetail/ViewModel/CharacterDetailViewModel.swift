//
//  CharacterDetailViewModel.swift
//  RickAndMortyApp
//
//  Created by Adrian Flores Herrera on 4/27/26.
//
import Foundation

final class CharacterDetailViewModel {

    // MARK: - Dependencies

    private let character: Character
    private let repository: FavoritesRepositoryProtocol
    private let episodeService: EpisodeServiceProtocol
    private let storage = StorageManager.shared // 🔥 NUEVO

    // MARK: - State

    private(set) var episodes: [Episode] = []

    // MARK: - Init

    init(
        character: Character,
        repository: FavoritesRepositoryProtocol,
        episodeService: EpisodeServiceProtocol
    ) {
        self.character = character
        self.repository = repository
        self.episodeService = episodeService
    }

    // MARK: - Exposed data

    var characterData: Character {
        character
    }

    var id: Int { character.id }
    var name: String { character.name }
    var species: String { character.species }

    var status: String {
        switch character.status {
        case .alive: return "Alive"
        case .dead: return "Dead"
        case .unknown: return "Unknown"
        }
    }

    var gender: String { character.gender }

    var location: String {
        character.location?.name ?? "Unknown"
    }

    var imageURL: String { character.image }

    var episodeURLs: [String] {
        character.episodeURLs
    }

    // MARK: - Favorites

    var isFavorite: Bool {
        repository.isFavorite(id: character.id)
    }

    func toggleFavorite() {
        if repository.isFavorite(id: character.id) {
            repository.deleteFavorite(id: character.id)
        } else {
            repository.saveFavorite(character)
        }
    }

    // MARK: - Episodes

    func fetchEpisodes() async {

        var temp: [Episode] = []

        // 🔥 OBTENER EPISODIOS VISTOS DESDE CORE DATA
        let watched = storage.getWatchedEpisodes(characterId: character.id)

        await withTaskGroup(of: EpisodeDTO?.self) { group in

            for urlString in episodeURLs {

                group.addTask {
                    guard let url = URL(string: urlString) else {
                        return nil
                    }

                    return try? await self.episodeService.fetchEpisode(url: url)
                }
            }

            for await dto in group {
                if let dto {
                    temp.append(
                        Episode(
                            id: dto.id,
                            name: dto.name,
                            episodeCode: dto.episode,
                            isWatched: watched.contains(dto.id) // 🔥 CLAVE
                        )
                    )
                }
            }
        }

        episodes = temp.sorted { $0.id < $1.id }
    }

    // MARK: - Watched episodes (PERSISTENTE)

    func toggleWatched(at index: Int) {
        guard episodes.indices.contains(index) else { return }

        let episode = episodes[index]

        // 🔥 GUARDAR EN CORE DATA
        storage.toggleEpisodeWatched(
            characterId: character.id,
            episodeId: episode.id
        )

        // 🔥 SINCRONIZAR ESTADO
        episodes[index].isWatched = storage.isEpisodeWatched(
            characterId: character.id,
            episodeId: episode.id
        )
    }
}
