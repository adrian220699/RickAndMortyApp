//
//  Character.swift
//  RickAndMortyApp
//
//  Created by Adrian Flores Herrera on 4/27/26.
//

import Foundation

struct Character {
    let id: Int
    let name: String
    let status: CharacterStatus
    let species: String
    let gender: String
    let image: String
    let location: Location
    let episodeURLs: [String]
    var isFavorite: Bool
}
