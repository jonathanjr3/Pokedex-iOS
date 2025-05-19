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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .fontDesign(.rounded)
        }
        .modelContainer(for: FavouritePokemon.self)
    }
}
