//
//  Location.swift
//  Weather App
//

import Foundation

struct Location: Identifiable, Codable, Hashable {
    let lat: Double
    let lon: Double
    let display_name: String
    let address: Address

    var id: String { "\(lat)_\(lon)" }

    enum CodingKeys: String, CodingKey {
        case lat
        case lon
        case display_name
        case address
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latString = try container.decode(String.self, forKey: .lat)
        let lonString = try container.decode(String.self, forKey: .lon)
        lat = Double(latString) ?? 0.0
        lon = Double(lonString) ?? 0.0
        display_name = try container.decode(String.self, forKey: .display_name)
        address = try container.decode(Address.self, forKey: .address)
    }
}

struct Address: Codable, Hashable {
    let city: String?
    let county: String?
    let state: String?
    let country: String?
    let country_code: String?
}

