//
//  GetCharactersUseCase.swift
//  RickAndMortyApp
//
//  Created by Adrian Flores Herrera on 4/28/26.
//

import Foundation

final class GetCharactersUseCase: GetCharactersUseCaseProtocol {

    private let repository: CharacterRepositoryProtocol

    init(repository: CharacterRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        page: Int,
        name: String?,
        status: String?,
        species: String?
    ) async throws -> [Character] {

        return try await repository.getCharacters(
            page: page,
            name: name,
            status: status,
            species: species
        )
    }
}
