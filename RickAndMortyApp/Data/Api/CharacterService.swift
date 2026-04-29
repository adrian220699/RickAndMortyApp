//
//  CharacterService.swift
//  RickAndMortyApp
//
//  Created by Adrian Flores Herrera on 4/27/26.
//
import Foundation

final class CharacterService: CharacterServiceProtocol {

    private let networkManager: NetworkManager

    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }

    func fetchCharacters(
        page: Int,
        name: String?,
        status: String?,
        species: String?
    ) async throws -> CharacterResponseDTO {

        var components = URLComponents(string: "https://rickandmortyapi.com/api/character")!

        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "name", value: name),
            URLQueryItem(name: "status", value: status),
            URLQueryItem(name: "species", value: species)
        ].compactMap { item in
            guard let value = item.value else { return nil }
            return URLQueryItem(name: item.name, value: value)
        }

        let url = components.url!

        return try await networkManager.request(url: url)
    }
}
