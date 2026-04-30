//
//  SceneDelegate.swift
//  RickAndMortyApp
//
//  Created by Adrian Flores Herrera on 4/27/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)

        // MARK: - CORE
        let networkManager = NetworkManager()

        // MARK: - SERVICES
        let characterService = CharacterService(networkManager: networkManager)
        let episodeService = EpisodeService(networkManager: networkManager)

        // MARK: - REPOSITORIES
        let characterRepository = CharacterRepository(service: characterService)
        let favoritesRepository = FavoritesRepository()

        // MARK: - USE CASES
        let getCharactersUseCase = GetCharactersUseCase(repository: characterRepository)

        // MARK: - VIEWMODEL
        let listViewModel = CharacterListViewModel(
            getCharactersUseCase: getCharactersUseCase
        )

        // MARK: - ROOT VC
        let rootVC = CharacterListViewController(
            viewModel: listViewModel,
            episodeService: episodeService,
            favoritesRepository: favoritesRepository
        )

        let navigation = UINavigationController(rootViewController: rootVC)

        window.rootViewController = navigation
        self.window = window
        window.makeKeyAndVisible()
    }
    
    
}

