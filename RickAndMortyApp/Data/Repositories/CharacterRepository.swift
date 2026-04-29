//
//  CharacterRepository.swift
//  RickAndMortyApp
//
//  Created by Adrian Flores Herrera on 4/28/26.
//

import Foundation

final class CharacterRepository: CharacterRepositoryProtocol {
    
    private let service: CharacterServiceProtocol
    
    init(service: CharacterServiceProtocol) {
        self.service = service
    }
    
    func getCharacters(
        page: Int,
        name: String?,
        status: String?,
        species: String?
    ) async throws -> [Character] {
        
        let response = try await service.fetchCharacters(
            page: page,
            name: name,
            status: status,
            species: species
        )
        
        return response.results.map(CharacterMapper.map)
    }
}
