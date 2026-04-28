//
//  EpisodeServiceProtocol.swift
//  RickAndMortyApp
//
//  Created by Adrian Flores Herrera on 4/28/26.
//

protocol EpisodeServiceProtocol {
    func fetchEpisode(from url: String) async throws -> EpisodeDTO
}
