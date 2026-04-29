//
//  CharacterListViewController.swift
//  RickAndMortyApp
//
//  Created by Adrian Flores Herrera on 4/27/26.
//
import Foundation
import UIKit
final class CharacterListViewController: UIViewController,
                                         UITableViewDelegate,
                                         UISearchBarDelegate,
                                         UITableViewDataSource {

    private let viewModel: CharacterListViewModel
    private var characters: [Character] = []

    // MARK: - UI
    private let searchController = UISearchController(searchResultsController: nil)
    private let tableView = UITableView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No characters found"
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private let statusSegmented: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["All", "Alive", "Dead", "Unknown"])
        sc.selectedSegmentIndex = 0
        return sc
    }()

    private let refreshControl = UIRefreshControl()

    private let episodeService: EpisodeServiceProtocol
    private let favoritesRepository: FavoritesRepositoryProtocol

    private var searchTask: Task<Void, Never>?

    // MARK: - INIT
    init(viewModel: CharacterListViewModel,
         episodeService: EpisodeServiceProtocol,
         favoritesRepository: FavoritesRepositoryProtocol) {

        self.viewModel = viewModel
        self.episodeService = episodeService
        self.favoritesRepository = favoritesRepository

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        setupUI()
        setupNavigationBar()
        bindViewModel()

        Task {
            await viewModel.fetchCharacters()
        }
    }

    // MARK: - NAVIGATION
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Favorites",
            style: .plain,
            target: self,
            action: #selector(openFavorites)
        )
    }

    @objc private func openFavorites() {
        let vc = FavoritesViewController(
            repository: favoritesRepository,
            episodeService: episodeService
        )
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - UI
    private func setupUI() {

        title = "Characters"

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CharacterCell.self,
                           forCellReuseIdentifier: CharacterCell.identifier)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        statusSegmented.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false

        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)

        view.addSubview(statusSegmented)
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            statusSegmented.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            statusSegmented.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statusSegmented.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: statusSegmented.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        statusSegmented.addTarget(self,
                                  action: #selector(statusChanged),
                                  for: .valueChanged)

        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
    }

    // MARK: - FETCH SAFE
    private func fetch() {
        Task {
            await viewModel.fetchCharacters()
        }
    }

    // MARK: - REFRESH
    @objc private func refreshData() {
        viewModel.refresh()
        fetch()
    }

    // MARK: - SEARCH (DEBOUNCE FIXED)
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        viewModel.updateFilters(name: searchText)

        searchTask?.cancel()

        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)

            guard !Task.isCancelled else { return }

            await viewModel.fetchCharacters()
        }
    }

    // MARK: - STATUS FILTER
    @objc private func statusChanged() {

        let index = statusSegmented.selectedSegmentIndex

        let value: String?

        switch index {
        case 1: value = "alive"
        case 2: value = "dead"
        case 3: value = "unknown"
        default: value = nil
        }

        viewModel.updateStatus(value)
        fetch()
    }

    // MARK: - BIND
    private func bindViewModel() {

        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }

            DispatchQueue.main.async {

                switch state {

                case .idle:
                    self.loadingIndicator.stopAnimating()
                    self.emptyLabel.isHidden = true

                case .loading:
                    self.loadingIndicator.startAnimating()
                    self.emptyLabel.isHidden = true

                case .success(let characters):
                    self.loadingIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()

                    self.characters = characters
                    self.tableView.reloadData()

                    self.emptyLabel.isHidden = true

                case .empty:
                    self.loadingIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()

                    self.characters = []
                    self.tableView.reloadData()

                    self.emptyLabel.isHidden = false

                case .error(let message):
                    self.loadingIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()

                    self.showError(message)
                }
            }
        }
    }

    // MARK: - ERROR
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - TABLE
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        characters.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CharacterCell.identifier,
            for: indexPath
        ) as? CharacterCell else {
            return UITableViewCell()
        }

        cell.configure(with: characters[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        let character = characters[indexPath.row]

        let vm = CharacterDetailViewModel(
            character: character,
            repository: favoritesRepository,
            episodeService: episodeService
        )

        let vc = CharacterDetailViewController(viewModel: vm)
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - PAGINATION FIX
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let position = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let screenHeight = scrollView.frame.size.height

        guard contentHeight > 0 else { return }

        if position > contentHeight - screenHeight - 150 {
            fetch()
        }
    }
}
