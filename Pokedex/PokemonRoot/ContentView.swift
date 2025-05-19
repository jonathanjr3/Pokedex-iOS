//
//  ContentView.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 10/05/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        NavigationStack {
            TabView {
                Tab("Browse", systemImage: "list.bullet", role: .search) {
                    PokemonListView()
                }
                Tab("Favourites", systemImage: "heart.fill") {
                    Text("🚧 Favourites coming soon 🚧")
                }
            }
            .tabViewStyle(.sidebarAdaptable)
            .navigationTitle("Pokedex")
        }
    }
}

#Preview {
    ContentView()
}
