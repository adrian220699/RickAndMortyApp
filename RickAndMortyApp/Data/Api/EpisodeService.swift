//
//  EpisodeService.swift
//  RickAndMortyApp
//
//  Created by Adrian Flores Herrera on 4/27/26.
//

import Foundation

final class EpisodeService : EpisodeServiceProtocol {

    func fetchEpisode(from url: String) async throws -> EpisodeDTO {

        guard let url = URL(string: url) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        return try JSONDecoder().decode(EpisodeDTO.self, from: data)
    }
}
