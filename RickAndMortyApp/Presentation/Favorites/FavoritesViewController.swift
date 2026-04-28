//
//  FavoritesViewController.swift
//  RickAndMortyApp
//
//  Created by Adrian Flores Herrera on 4/27/26.
//

import UIKit

final class FavoritesViewController: UIViewController {

    private let tableView = UITableView()
    private var characters: [Character] = []

    private let repository = FavoritesRepository()

    private var isAuthenticated = false

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Favorites"
        view.backgroundColor = .systemBackground

        authenticateUser()
    }

    // MARK: - BIOMETRÍA

    private func authenticateUser() {

        BiometricManager.shared.authenticate { [weak self] success in

            guard let self else { return }

            DispatchQueue.main.async {

                if success {
                    self.isAuthenticated = true
                    self.setupTable()
                    self.loadFavorites()
                } else {
                    self.showAccessDenied()
                }
            }
        }
    }

    // MARK: - TABLE SETUP

    private func setupTable() {

        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    // MARK: - LOAD FAVORITES

    private func loadFavorites() {

        characters = repository.getFavorites()

        print("⭐ Favorites loaded:", characters.count)

        tableView.reloadData()
    }

    // MARK: - ACCESS DENIED

    private func showAccessDenied() {

        let label = UILabel()
        label.text = "🔒 Acceso denegado"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.frame = view.bounds

        view.addSubview(label)
    }
}

// MARK: - TABLE

extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        characters.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")

        let character = characters[indexPath.row]

        cell.textLabel?.text = character.name
        cell.detailTextLabel?.text = character.species
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        let character = characters[indexPath.row]

        // ✅ FASE 1 FIX: DI correcto
        let vm = CharacterDetailViewModel(
            character: character,
            repository: FavoritesRepository(),
            episodeService: EpisodeService()
        )

        let vc = CharacterDetailViewController(viewModel: vm)

        navigationController?.pushViewController(vc, animated: true)
    }
}

