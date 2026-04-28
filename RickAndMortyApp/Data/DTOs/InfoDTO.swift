//
//  InfoDTO.swift
//  RickAndMortyApp
//
//  Created by Adrian Flores Herrera on 4/27/26.
//

import Foundation

struct InfoDTO: Decodable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}
