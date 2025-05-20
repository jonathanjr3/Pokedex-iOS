//
//  ContentView.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 10/05/2025.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Browse", systemImage: "list.bullet", value: 0, role: .search) {
                PokemonListView()
            }
            Tab("Favourites", systemImage: "heart.fill", value: 1) {
                FavouritesListView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .sensoryFeedback(.selection, trigger: selectedTab)
    }
}

#Preview {
    ContentView()
}
