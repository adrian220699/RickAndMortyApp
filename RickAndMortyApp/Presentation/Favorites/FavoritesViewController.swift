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

    private let repository: FavoritesRepositoryProtocol
    private let episodeService: EpisodeServiceProtocol

    private var isAuthenticated = false

    // MARK: - INIT

    init(repository: FavoritesRepositoryProtocol,
         episodeService: EpisodeServiceProtocol) {

        self.repository = repository
        self.episodeService = episodeService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        print("Favorites loaded:", characters.count)
        tableView.reloadData()
    }

    // MARK: - ACCESS DENIED

    private func showAccessDenied() {

        let label = UILabel()
        label.text = "Acceso denegado"
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

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let character = characters[indexPath.row]

        cell.textLabel?.text = character.name
        cell.detailTextLabel?.text = character.species
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        let character = characters[indexPath.row]

        let vm = CharacterDetailViewModel(
            character: character,
            repository: repository,
            episodeService: episodeService
        )

        let vc = CharacterDetailViewController(viewModel: vm)

        navigationController?.pushViewController(vc, animated: true)
    }
}
