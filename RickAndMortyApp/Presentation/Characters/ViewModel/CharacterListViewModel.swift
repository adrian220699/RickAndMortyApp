

import Foundation

final class CharacterListViewModel {
    
    private var characters: [Character] = []
    private var currentPage: Int = 1
    var isLoading: Bool = false
    
    private var searchName: String?
    private var status: String?
    private var species: String?
    
    private var requestID = UUID()
    
    private let service: CharacterServiceProtocol
    
    var onStateChange: ((CharacterListState) -> Void)?
    
    init(service: CharacterServiceProtocol) {
        self.service = service
    }
    
    // MARK: - RESET
    private func resetPagination() {
        currentPage = 1
        characters = []
    }
    
    // MARK: - FETCH
    func fetchCharacters() {

        guard !isLoading else { return }
        isLoading = true

        onStateChange?(.loading)

        let requestID = UUID()
        self.requestID = requestID

        let pageToLoad = currentPage

        Task {
            defer { self.isLoading = false }

            do {
                let response = try await service.fetchCharacters(
                    page: pageToLoad,
                    name: searchName,
                    status: status,
                    species: species
                )

                guard requestID == self.requestID else { return }

                let newCharacters = response.results.map(CharacterMapper.map)

                // ✅ EMPTY STATE (BLOQUE 4)
                if newCharacters.isEmpty && self.characters.isEmpty {
                    self.onStateChange?(.empty)
                    return
                }

                self.characters.append(contentsOf: newCharacters)

                self.onStateChange?(.success(self.characters))

                self.currentPage += 1

            } catch {
                self.onStateChange?(.error(error.localizedDescription))
            }
        }
    }
    
    // MARK: - FILTERS
    func updateFilters(name: String?) {
        self.searchName = name
        resetPagination()
        isLoading = false
        onStateChange?(.loading)
        fetchCharacters()
    }

    func updateStatus(_ status: String?) {
        self.status = status
        resetPagination()
        isLoading = false
        onStateChange?(.loading)
        fetchCharacters()
    }

    func updateSpecies(_ species: String?) {
        self.species = species
        resetPagination()
        isLoading = false
        onStateChange?(.loading)
        fetchCharacters()
    }
    
    // MARK: - REFRESH
    func refresh() {
        resetPagination()
        isLoading = false
        onStateChange?(.loading)
        fetchCharacters()
    }
}
