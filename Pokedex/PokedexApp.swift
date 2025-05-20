//
//  PokedexApp.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 10/05/2025.
//

import SwiftUI
import SwiftData

@main
struct PokedexApp: App {
    @State var networkMonitor = NetworkMonitor()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(networkMonitor)
        }
        .modelContainer(for: FavouritePokemon.self)
    }
}
