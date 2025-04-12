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

    /// Add a location to favorites (no duplicates)
    func addFavorite(_ location: Location) {
        guard !favorites.contains(location) else { return }
        favorites.append(location)
        saveFavorites()
    }

    /// Remove a location from favorites
    func removeFavorite(_ location: Location) {
        favorites.removeAll { $0.lat == location.lat && $0.lon == location.lon }
        saveFavorites()
    }

    /// Check if location is already in favorites
    func isFavorited(_ location: Location) -> Bool {
        return favorites.contains(where: { $0.lat == location.lat && $0.lon == location.lon })
    }

    // MARK: - Persistence

    /// Save the favorites list to a local JSON file
    private func saveFavorites() {
        let url = getFileURL()
        do {
            let data = try JSONEncoder().encode(favorites)
            try data.write(to: url, options: [.atomic, .completeFileProtection])
        } catch {
            print("❌ Failed to save favorites: \(error)")
        }
    }

    /// Load favorites from JSON file if it exists
    private func loadFavorites() {
        let url = getFileURL()
        do {
            let data = try Data(contentsOf: url)
            favorites = try JSONDecoder().decode([Location].self, from: data)
        } catch {
            favorites = []
            print("ℹ️ No saved favorites found or failed to load: \(error.localizedDescription)")
        }
    }

    /// File URL for saving favorites.json
    private func getFileURL() -> URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent(saveFilename)
    }
}

