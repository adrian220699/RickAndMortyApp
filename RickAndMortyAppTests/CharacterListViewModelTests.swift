//
//  CharacterListViewModelTests.swift
//  RickAndMortyAppTests
//
//  Created by Adrian Flores Herrera on 4/29/26.
//

import XCTest
@testable import RickAndMortyApp

final class CharacterListViewModelTests: XCTestCase {

    func test_fetchCharacters_success() async {

        let mock = MockGetCharactersUseCase()
        mock.result = .success([
            Character(
                id: 1,
                name: "Rick",
                status: .alive,
                species: "Human",
                gender: "Male",
                image: "",
                location: Location(name: "Earth", latitude: 0, longitude: 0),
                episodeURLs: [],
                isFavorite: false
            )
        ])

        let viewModel = CharacterListViewModel(getCharactersUseCase: mock)

        await withCheckedContinuation { continuation in

            var didResume = false

            viewModel.onStateChange = { state in
                guard !didResume else { return }

                if case .success(let characters) = state {
                    didResume = true
                    XCTAssertEqual(characters.count, 1)
                    continuation.resume()
                }
            }

            Task { @MainActor in
                await viewModel.fetchCharacters()
            }
        }
    }
}
