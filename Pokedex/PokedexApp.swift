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
    @State var tabSelection: TabTypes = .pokemonList
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            TabView(selection: $tabSelection) {
                Tab("Browse", systemImage: "list.bullet", value: .pokemonList) {
                    PokemonListView()
                }
                
                Tab("Favourites", systemImage: "heart.fill", value: .pokemonFavorites) {
                    ContentView()
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}

enum TabTypes {
    case pokemonList, pokemonFavorites
}
