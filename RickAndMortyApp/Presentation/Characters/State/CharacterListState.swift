//
//  CharacterListState.swift
//  RickAndMortyApp
//
//  Created by Adrian Flores Herrera on 4/27/26.
//

import Foundation

enum CharacterListState {
    case idle
    case loading
    case success([Character])
    case empty  
    case error(String)
}
