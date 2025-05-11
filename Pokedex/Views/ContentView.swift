//
//  ContentView.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 10/05/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Namespace var animation
    @State private var searchQuery: String = ""
    @State private var selectedList: PokemonListType = .browse
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Pokemon List", selection: $selectedList) {
                    ForEach(PokemonListType.allCases) { listType in
                        Text(listType.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                Spacer()
                Text("Pokedex coming soon")
                NavigationLink {
                    PokemonDetailView(pokemonId: 25, animation: animation)
                } label: {
                    Label("Go to pokemon details", systemImage: "chevron.forward")
                        .matchedTransitionSource(id: 25, in: animation)
                }
                Spacer()
            }
            .padding(.horizontal)
            .navigationTitle("Pokédex")
            .searchable(text: $searchQuery, prompt: "Search for pokemons by name or id")
        }
    }
}

#Preview {
    ContentView()
}

enum PokemonListType: String, CaseIterable, Identifiable {
    var id: Self { self }
    case browse = "Browse", favourites = "Favourites"
}
