//
//  NetworkManager.swift
//  RickAndMortyApp
//
//  Created by Adrian Flores Herrera on 4/27/26.
//
import Foundation

final class NetworkManager {

    // MARK: - INIT (injectable)
    init() {}

    // MARK: - GENERIC REQUEST

    func request<T: Decodable>(
        url: URL
    ) async throws -> T {

        let (data, response) = try await URLSession.shared.data(from: url)

        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard 200...299 ~= httpResponse.statusCode else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }

        // Decode
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
}
