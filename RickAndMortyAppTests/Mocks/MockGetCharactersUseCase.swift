//
//  MockGetCharactersUseCase.swift
//  RickAndMortyApp
//
//  Created by Adrian Flores Herrera on 4/29/26.
//

final class MockGetCharactersUseCase: GetCharactersUseCaseProtocol {

    var result: Result<[Character], Error> = .success([])

    func execute(
        page: Int,
        name: String?,
        status: String?,
        species: String?
    ) async throws -> [Character] {

        switch result {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }
}
