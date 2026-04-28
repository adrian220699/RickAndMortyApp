//
//  CharacterMapper.swift
//  RickAndMortyApp
//
//  Created by Adrian Flores Herrera on 4/27/26.
//

final class CharacterMapper {

    static func map(dto: CharacterDTO) -> Character {

        let status: CharacterStatus

        switch dto.status.lowercased() {
        case "alive":
            status = .alive
        case "dead":
            status = .dead
        default:
            status = .unknown
        }

        return Character(
            id: dto.id,
            name: dto.name,
            status: status,
            species: dto.species,
            gender: dto.gender,
            image: dto.image,
            location: Location(
                name: dto.location.name,
                latitude: Double.random(in: -90...90),
                longitude: Double.random(in: -180...180)
            ),
            episodeURLs: dto.episode,
            isFavorite: false
        )
    }
}
