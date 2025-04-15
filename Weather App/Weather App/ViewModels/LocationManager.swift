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
    private var completion: ((String?) -> Void)?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestLocation(completion: @escaping (String?) -> Void) {
        self.completion = completion
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            completion?("Location access denied.")
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            completion?("Unknown location status.")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error.localizedDescription)")
        completion?("Failed to get location.")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            completion?("No location found.")
            return
        }

        reverseGeocode(location: location)
    }

    private func reverseGeocode(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("❌ Reverse geocode error: \(error)")
                self.completion?("Reverse geocoding failed.")
                return
            }

            guard let placemark = placemarks?.first else {
                self.completion?("No location name found.")
                return
            }

            let city = placemark.locality ?? ""
            let state = placemark.administrativeArea ?? ""
            let query = [city, state].filter { !$0.isEmpty }.joined(separator: ", ")
            print("📍 Resolved location: \(query)")
            self.completion?(query)
        }
    }
}

