//
//  CharacterCell.swift
//  RickAndMortyApp
//
//  Created by Adrian Flores Herrera on 4/27/26.
//

import UIKit

final class CharacterCell: UITableViewCell {

    static let identifier = "CharacterCell"

    func configure(with character: Character) {
        textLabel?.text = character.name
        detailTextLabel?.text = "\(character.status)"
    }
}
