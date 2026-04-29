//
//  EpisodeServiceProtocol.swift
//  RickAndMortyApp
//
//  Created by Adrian Flores Herrera on 4/28/26.
//

import Foundation

protocol EpisodeServiceProtocol {
    func fetchEpisode(url: URL) async throws -> EpisodeDTO
}
