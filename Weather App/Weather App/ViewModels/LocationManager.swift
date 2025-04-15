//
//  LocationManager.swift
//  Weather App
//

import Foundation
import CoreLocation
import SwiftUI

@MainActor
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var currentLocation: CLLocation?
    @Published var currentQuery: String = ""
    @Published var errorMessage: String?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            errorMessage = "Location access denied."
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            errorMessage = "Unknown location authorization status."
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error.localizedDescription)")
        errorMessage = "Failed to get location."
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            errorMessage = "No location data found."
            return
        }

        currentLocation = location
        reverseGeocode(location: location)
    }

    private func reverseGeocode(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                self.errorMessage = "Failed to reverse geocode: \(error.localizedDescription)"
                return
            }

            guard let placemark = placemarks?.first else {
                self.errorMessage = "No placemark found."
                return
            }

            let city = placemark.locality ?? ""
            let state = placemark.administrativeArea ?? ""
            let fullQuery = [city, state].filter { !$0.isEmpty }.joined(separator: ", ")

            print("📍 Reverse geocoded query: \(fullQuery)")
            self.currentQuery = fullQuery
        }
    }
}

