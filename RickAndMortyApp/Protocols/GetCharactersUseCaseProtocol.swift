//
//  GetCharactersUseCaseProtocol.swift
//  RickAndMortyApp
//
//  Created by Adrian Flores Herrera on 4/29/26.
//

protocol GetCharactersUseCaseProtocol {
    func execute(
        page: Int,
        name: String?,
        status: String?,
        species: String?
    ) async throws -> [Character]
}
