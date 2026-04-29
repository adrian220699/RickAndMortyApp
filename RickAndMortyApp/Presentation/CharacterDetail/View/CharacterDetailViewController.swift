//
//  CharacterDetailViewController.swift
//  RickAndMortyApp
//
//  Created by Adrian Flores Herrera on 4/27/26.
//

import UIKit

final class CharacterDetailViewController: UIViewController,
                                           UITableViewDelegate,
                                           UITableViewDataSource {

    // MARK: - Dependencies

    private let viewModel: CharacterDetailViewModel

    // MARK: - UI

    private let imageView = UIImageView()
    private let infoLabel = UILabel()
    private let tableView = UITableView()
    private let favoriteButton = UIButton(type: .system)

    // MARK: - Init

    init(viewModel: CharacterDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = viewModel.name

        setupTable()
        setupHeader()
        setupFavoriteButton()
        setupNavigationItems()

        loadEpisodes()
        updateFavoriteUI()
    }

    // MARK: - Navigation

    private func setupNavigationItems() {

        let mapButton = UIBarButtonItem(
            image: UIImage(systemName: "map"),
            style: .plain,
            target: self,
            action: #selector(openMap)
        )

        let favoriteBarButton = UIBarButtonItem(customView: favoriteButton)

        navigationItem.rightBarButtonItems = [mapButton, favoriteBarButton]
    }

    // MARK: - Favorite

    private func setupFavoriteButton() {

        favoriteButton.tintColor = .systemRed
        favoriteButton.addTarget(self,
                                 action: #selector(didTapFavorite),
                                 for: .touchUpInside)
    }

    @objc private func didTapFavorite() {
        viewModel.toggleFavorite()
        updateFavoriteUI()
    }

    private func updateFavoriteUI() {
        let imageName = viewModel.isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    // MARK: - Header

    private func setupHeader() {

        let header = UIView(
            frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 400)
        )

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.frame = CGRect(
            x: 0,
            y: 0,
            width: header.frame.width,
            height: 300
        )

        infoLabel.numberOfLines = 0
        infoLabel.textColor = .label
        infoLabel.frame = CGRect(
            x: 20,
            y: 310,
            width: header.frame.width - 40,
            height: 80
        )

        infoLabel.text = """
        Name: \(viewModel.name)
        Species: \(viewModel.species)
        Status: \(viewModel.status)
        Gender: \(viewModel.gender)
        Location: \(viewModel.location)
        """

        header.addSubview(imageView)
        header.addSubview(infoLabel)

        tableView.tableHeaderView = header

        loadImage()
    }

    // MARK: - Table

    private func setupTable() {

        view.addSubview(tableView)
        tableView.frame = view.bounds

        tableView.delegate = self
        tableView.dataSource = self

        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44

        // 🔥 FIX IMPORTANTE: evitar celdas duplicadas raras
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "episodeCell")
    }

    // MARK: - Image

    private func loadImage() {

        guard let url = URL(string: viewModel.imageURL) else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data else { return }

            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: data)
            }
        }.resume()
    }

    // MARK: - Episodes

    private func loadEpisodes() {

        Task {
            await viewModel.fetchEpisodes()

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Map

    @objc private func openMap() {

        let vc = CharacterMapViewController(
            characters: [viewModel.characterData]
        )

        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Table Data Source

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        viewModel.episodes.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let episode = viewModel.episodes[indexPath.row]

        // 🔥 FIX: usar dequeueReusableCell correctamente
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "episodeCell",
            for: indexPath
        )

        cell.textLabel?.text = episode.name
        cell.detailTextLabel?.text = episode.episodeCode

        // 🔥 UI PRO
        if episode.isWatched {
            cell.accessoryType = .checkmark
            cell.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
            cell.textLabel?.textColor = .systemGray
        } else {
            cell.accessoryType = .none
            cell.backgroundColor = .clear
            cell.textLabel?.textColor = .label
        }

        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        viewModel.toggleWatched(at: indexPath.row)

        // 🔥 FIX: refrescar solo esa celda (mejor performance + animación)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
