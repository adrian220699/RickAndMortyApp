//
//  FavoritesRepositoryProtocol.swift
//  RickAndMortyApp
//
//  Created by Adrian Flores Herrera on 4/28/26.
//

protocol FavoritesRepositoryProtocol {
    func getFavorites() -> [Character]
    func saveFavorite(_ character: Character)
    func deleteFavorite(id: Int)
    func isFavorite(id: Int) -> Bool
}
