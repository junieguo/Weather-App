//
//  WeatherViewModel.swift
//  Weather App
//

import Foundation

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var favorites: [Location] = []

    private let saveFilename = "favorites.json"

    init() {
        loadFavorites()
    }

    func addFavorite(_ location: Location) {
        guard !favorites.contains(location) else { return }
        favorites.append(location)
        saveFavorites()
    }

    func removeFavorite(_ location: Location) {
        favorites.removeAll { $0.lat == location.lat && $0.lon == location.lon }
        saveFavorites()
    }

    func isFavorited(_ location: Location) -> Bool {
        return favorites.contains(where: { $0.lat == location.lat && $0.lon == location.lon })
    }

    private func saveFavorites() {
        let url = getFileURL()
        do {
            let data = try JSONEncoder().encode(favorites)
            try data.write(to: url, options: [.atomic, .completeFileProtection])
        } catch {
            print("Failed to save favorites: \(error)")
        }
    }

    private func loadFavorites() {
        let url = getFileURL()
        do {
            let data = try Data(contentsOf: url)
            favorites = try JSONDecoder().decode([Location].self, from: data)
        } catch {
            favorites = []
            print("No saved favorites found or failed to load: \(error.localizedDescription)")
        }
    }

    private func getFileURL() -> URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent(saveFilename)
    }
}
