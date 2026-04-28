//
//  CharacterService.swift
//  RickAndMortyApp
//
//  Created by Adrian Flores Herrera on 4/27/26.
//

import Foundation

final class CharacterService : CharacterServiceProtocol {

    private let baseURL = "https://rickandmortyapi.com/api"

    func fetchCharacters(
        
        page: Int,
        name: String? = nil,
        status: String? = nil,
        species: String? = nil

    ) async throws -> CharacterResponseDTO {

        var components = URLComponents(string: "\(baseURL)/character")!

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)")
        ]

        if let name = name, !name.isEmpty {
            queryItems.append(URLQueryItem(name: "name", value: name))
        }

        if let status = status, !status.isEmpty {
            queryItems.append(URLQueryItem(name: "status", value: status))
        }

        if let species = species, !species.isEmpty {
            queryItems.append(URLQueryItem(name: "species", value: species))
        }

        components.queryItems = queryItems

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        let response: CharacterResponseDTO = try await NetworkManager.shared.request(url: url)
        return response
    }
}
