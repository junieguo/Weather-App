//
//  Location.swift
//  Weather App
//

struct Location: Identifiable, Decodable {
    let lat: Double
    let lon: Double
    let name: String
    let display_name: String
    let address: Address

    var id: String { "\(lat)_\(lon)" }
}

struct Address: Decodable {
    let city: String?
    let county: String?
    let state: String
    let country: String
    let country_code: String
}
