//
//  WeatherViewModel.swift
//  Weather App
//

import Foundation
import SwiftUI

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var favorites: [Location] = []

    private let saveFile = "favorites.json"

    init() {
        loadFavorites()
    }

    func addFavorite(_ location: Location) {
        guard !favorites.contains(location) else { return }
        favorites.append(location)
        saveFavorites()
    }

    func removeFavorite(_ location: Location) {
        favorites.removeAll { $0 == location }
        saveFavorites()
    }

    func isFavorited(_ location: Location) -> Bool {
        return favorites.contains(location)
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func saveFavorites() {
        let url = getDocumentsDirectory().appendingPathComponent(saveFile)
        do {
            let data = try JSONEncoder().encode(favorites)
            try data.write(to: url)
        } catch {
            print("Failed to save favorites: \(error)")
        }
    }

    private func loadFavorites() {
        let url = getDocumentsDirectory().appendingPathComponent(saveFile)
        do {
            let data = try Data(contentsOf: url)
            favorites = try JSONDecoder().decode([Location].self, from: data)
        } catch {
            favorites = []
            print("No saved favorites found or failed to load: \(error)")
        }
    }
}
