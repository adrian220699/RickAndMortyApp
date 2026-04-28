//
//  CharacterListViewController.swift
//  RickAndMortyApp
//
//  Created by Adrian Flores Herrera on 4/27/26.
//
import UIKit

final class CharacterListViewController: UIViewController,
                                         UITableViewDelegate,
                                         UISearchBarDelegate,
                                         UITableViewDataSource {

    private let viewModel: CharacterListViewModel
    private var characters: [Character] = []

    private let searchController = UISearchController(searchResultsController: nil)
    private let tableView = UITableView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)

    // MARK: - FILTER
    private let statusSegmented: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["All", "Alive", "Dead", "Unknown"])
        sc.selectedSegmentIndex = 0
        return sc
    }()

    // MARK: - PULL TO REFRESH 🔥
    private let refreshControl = UIRefreshControl()

    // MARK: - INIT
    init(viewModel: CharacterListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        print("🟢 INIT CharacterListViewController")
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

        viewModel.fetchCharacters()
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
        let vc = FavoritesViewController()
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

        // 🔥 PULL TO REFRESH CONFIG
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)

        view.addSubview(statusSegmented)
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([

            statusSegmented.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            statusSegmented.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statusSegmented.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statusSegmented.heightAnchor.constraint(equalToConstant: 32),

            tableView.topAnchor.constraint(equalTo: statusSegmented.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        statusSegmented.addTarget(self,
                                  action: #selector(statusChanged),
                                  for: .valueChanged)

        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
    }

    // MARK: - 🔥 REFRESH ACTION
    @objc private func refreshData() {
        viewModel.refresh()
    }

    // MARK: - SEARCH
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.updateFilters(name: searchText)
    }

    // MARK: - STATUS
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
    }

    // MARK: - VIEWMODEL
    private func bindViewModel() {

        viewModel.onStateChange = { [weak self] state in
            DispatchQueue.main.async {

                switch state {

                case .loading:
                    self?.loadingIndicator.startAnimating()

                case .success(let characters):
                    self?.loadingIndicator.stopAnimating()
                    self?.refreshControl.endRefreshing() // 🔥
                    self?.characters = characters
                    self?.tableView.reloadData()

                case .error(let message):
                    self?.loadingIndicator.stopAnimating()
                    self?.refreshControl.endRefreshing() // 🔥
                    print("ERROR:", message)

                default:
                    break
                }
            }
        }
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
            repository: FavoritesRepository(),
            episodeService: EpisodeService()
        )

        let vc = CharacterDetailViewController(viewModel: vm)

        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - SCROLL
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let position = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let screenHeight = scrollView.frame.size.height

        guard !viewModel.isLoading else { return }

        if position > contentHeight - screenHeight - 100 {
            viewModel.fetchCharacters()
        }
    }
}
