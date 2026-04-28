//
//  NetworkError.swift
//  RickAndMortyApp
//
//  Created by Adrian Flores Herrera on 4/27/26.
//


import Foundation

enum NetworkError: Error {
    
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case decodingError
    
}
