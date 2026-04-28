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
    var location: String { character.location.name }
    var imageURL: String { character.image }

    var episodeURLs: [String] {
        character.episodeURLs
    }

    // MARK: - Favorites

    var isFavorite: Bool {
        repository.isFavorite(id: character.id)
    }

    func toggleFavorite() {
        if isFavorite {
            repository.remove(id: character.id)
        } else {
            repository.add(character: character)
        }
    }

    // MARK: - Episodes

    func fetchEpisodes() async {

        var temp: [Episode] = []

        await withTaskGroup(of: EpisodeDTO?.self) { group in

            for url in episodeURLs {

                group.addTask {
                    try? await self.episodeService.fetchEpisode(from: url)
                }
            }

            for await dto in group {
                if let dto {
                    temp.append(
                        Episode(
                            id: dto.id,
                            name: dto.name,
                            episodeCode: dto.episode,
                            isWatched: false
                        )
                    )
                }
            }
        }

        episodes = temp.sorted { $0.id < $1.id }
    }

    // MARK: - Watched episodes (local state only for now)

    func toggleWatched(at index: Int) {
        guard episodes.indices.contains(index) else { return }
        episodes[index].isWatched.toggle()
    }
}
