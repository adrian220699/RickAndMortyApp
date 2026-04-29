
import Foundation
import UIKit

final class CharacterListViewModel {

    private var characters: [Character] = []
    private var currentPage: Int = 1
    private var isLoading = false
    private var canLoadMore = true

    private var searchName: String?
    private var status: String?
    private var species: String?
    private var notifyCount = 0


    private let getCharactersUseCase: GetCharactersUseCaseProtocol

    var onStateChange: ((CharacterListState) -> Void)?

    init(getCharactersUseCase: GetCharactersUseCaseProtocol) {
        self.getCharactersUseCase = getCharactersUseCase
    }

    // MARK: - FETCH
    func fetchCharacters() async {

        guard !isLoading, canLoadMore else { return }

        isLoading = true
        notify(.loading)

        defer { isLoading = false }

        do {
            let result = try await getCharactersUseCase.execute(
                page: currentPage,
                name: searchName,
                status: status,
                species: species
            )

            if result.isEmpty {
                canLoadMore = false
                notify(.empty)
                return
            }

            if currentPage == 1 {
                characters = result
            } else {
                characters.append(contentsOf: result)
            }

            currentPage += 1
            notify(.success(characters))

        } catch {
            notify(.error(error.localizedDescription))
        }
    }

    // MARK: - FILTERS
    func updateFilters(name: String?) {
        searchName = name
        reset()
    }

    func updateStatus(_ status: String?) {
        self.status = status
        reset()
    }

    func updateSpecies(_ species: String?) {
        self.species = species
        reset()
    }

    // MARK: - REFRESH
    func refresh() {
        reset()
    }

    // MARK: - RESET
    private func reset() {
        currentPage = 1
        characters = []
        canLoadMore = true
        isLoading = false
    }

    // MARK: - SAFE NOTIFY (MAIN THREAD)
    
    @MainActor
    private func notify(_ state: CharacterListState) {
        notifyCount += 1
        print("📣 notify #\(notifyCount):", state)

        onStateChange?(state)
    }
    
        deinit {
            print("VIEWMODEL DEALLOCATED")
        }

}
