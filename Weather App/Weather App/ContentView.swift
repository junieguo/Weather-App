//
//  ContentView.swift
//  Weather App
//
//  Created by Junie Guo on 4/7/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HomeView()
            .environmentObject(WeatherViewModel())
    }
}

#Preview {
    ContentView()
}

