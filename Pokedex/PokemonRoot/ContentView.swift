//
//  ContentView.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 10/05/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var searchQuery: String = ""
    var body: some View {
        NavigationStack {
            TabView {
                Tab("Browse", systemImage: "list.bullet") {
                    PokemonListView()
                        .searchable(text: $searchQuery, prompt: "Search for pokemons using name or id")
                }
                Tab("Favourites", systemImage: "heart.fill") {
                    Text("🚧 Favourites coming soon 🚧")
                }
            }
            .navigationTitle("Pokedex")
        }
    }
}

#Preview {
    ContentView()
}
