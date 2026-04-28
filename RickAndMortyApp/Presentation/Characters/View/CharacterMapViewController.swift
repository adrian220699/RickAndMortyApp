//
//  CharacterMapViewController.swift
//  RickAndMortyApp
//
//  Created by Adrian Flores Herrera on 4/27/26.
//


import UIKit
import MapKit

final class CharacterMapViewController: UIViewController {

    private let characters: [Character]
    private let mapView = MKMapView()

    init(characters: [Character]) {
        self.characters = characters
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Map"
        view.backgroundColor = .systemBackground

        setupMap()
        addPins()
    }

    private func setupMap() {
        view.addSubview(mapView)
        mapView.frame = view.bounds
    }

    private func addPins() {

        guard !characters.isEmpty else { return }

        for character in characters {

            let coordinate = CLLocationCoordinate2D(
                latitude: character.location.latitude,
                longitude: character.location.longitude
            )

            let annotation = MKPointAnnotation()
            annotation.title = character.name
            annotation.subtitle = character.location.name
            annotation.coordinate = coordinate

            mapView.addAnnotation(annotation)
        }

        // centrar en el primero
        if let first = characters.first {

            let region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: first.location.latitude,
                    longitude: first.location.longitude
                ),
                span: MKCoordinateSpan(latitudeDelta: 20, longitudeDelta: 20)
            )

            mapView.setRegion(region, animated: true)
        }
    }
}
