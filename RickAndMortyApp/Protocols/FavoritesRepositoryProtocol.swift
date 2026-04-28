//
//  FavoritesRepositoryProtocol.swift
//  RickAndMortyApp
//
//  Created by Adrian Flores Herrera on 4/28/26.
//

protocol FavoritesRepositoryProtocol {
    func add(character: Character)
    func remove(id: Int)
    func getFavorites() -> [Character]
    func isFavorite(id: Int) -> Bool
}
