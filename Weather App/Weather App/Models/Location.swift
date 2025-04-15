//
//  Location.swift
//  Weather App
//

import Foundation

struct Location: Identifiable, Codable, Hashable {
    let placeId: Int
    let lat: String
    let lon: String
    let displayName: String
    let address: Address?
    
    var id: Int { placeId }
    var latitude: Double { Double(lat) ?? 0.0 }
    var longitude: Double { Double(lon) ?? 0.0 }
    
    enum CodingKeys: String, CodingKey {
        case placeId = "place_id"
        case lat
        case lon
        case displayName = "display_name"
        case address
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        placeId = try container.decode(Int.self, forKey: .placeId)
        lat = try container.decode(String.self, forKey: .lat)
        lon = try container.decode(String.self, forKey: .lon)
        displayName = try container.decode(String.self, forKey: .displayName)
        address = try? container.decode(Address.self, forKey: .address)
        
        print("Decoded location: \(displayName) (\(lat), \(lon))")
    }
}

struct Address: Codable, Hashable {
    let city: String?
    let county: String?
    let state: String?
    let country: String?
    let countryCode: String?
    
    enum CodingKeys: String, CodingKey {
        case city, county, state, country
        case countryCode = "country_code"
    }
}
