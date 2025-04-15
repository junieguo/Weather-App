//
//  MapView.swift
//  Weather App
//

import SwiftUI
import MapKit

struct MapView: View {
    var coordinate: CLLocationCoordinate2D

    @State private var region: MKCoordinateRegion

    init(latitude: Double, longitude: Double) {
        let coord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.coordinate = coord
        _region = State(initialValue: MKCoordinateRegion(
            center: coord,
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        ))
    }

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: [IdentifiableCoordinate(coordinate: coordinate)]) { location in
            MapMarker(coordinate: location.coordinate, tint: .blue)
        }
        .frame(height: 250)
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding(.top)
    }
}

private struct IdentifiableCoordinate: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

