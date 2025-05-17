//
//  PokemonListView.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 15/05/2025.
//

import SwiftUI
import Foundation

public struct PokemonListView: View {
    @State private var viewModel: PokemonListViewModel
    @Namespace var animation

    // For grid layout
    private let gridItems: [GridItem] = Array(
        repeating: .init(.flexible(), spacing: 16),
        count: 2
    )

    init(apiService: PokemonAPIService = PokemonAPIService()) {
        viewModel = PokemonListViewModel(apiService: apiService)
    }

    public var body: some View {
        List {
            let items: [PokemonListItem] = viewModel.isSearching
                ? viewModel.searchResults
                : viewModel.allPokemonSummaries.map { PokemonListItem(pokemonSummary: $0) }
            ForEach(items) { pokemonItem in
                NavigationLink {
                    PokemonDetailView(
                        pokemonID: pokemonItem.id,
                        animation: animation
                    )
                } label: {
                    PokemonListRow(
                        pokemonItem: pokemonItem,
                        animation: animation
                    )
                }
            }

            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding()
                    Spacer()
                }
            }

            if let errorMessage = viewModel.errorMessage,
                items.isEmpty
            {
                ContentUnavailableView(
                    "Oops! Something went wrong.",
                    systemImage: "wifi.exclamationmark",
                    description: Text(errorMessage)
                )
            }
        }
        .searchable(text: $viewModel.searchQuery, prompt: "Search Pokémon by name or id")
        .onAppear {
            if viewModel.allPokemonSummaries.isEmpty {
                Task {
                    await viewModel.fetchAllPokemonSummariesIfNeeded()
                }
            }
        }
    }
}

struct PokemonListRow: View {
    let pokemonItem: PokemonListItem
    let animation: Namespace.ID

    var body: some View {
        HStack {
            AsyncImage(url: pokemonItem.spriteURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 70, height: 70)
                case .success(let image):
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 70, height: 70)
                case .failure:
                    Image(systemName: "questionmark.diamond")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .padding(10)
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            .matchedTransitionSource(id: pokemonItem.id, in: animation)

            VStack(alignment: .leading) {
                Text(pokemonItem.name)
                    .font(.headline)
                Text(String(format: "#%03d", pokemonItem.id))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// Preview
#Preview {
    NavigationStack {
        PokemonListView(
            apiService: PokemonAPIService(apiClient: MockPokemonAPIClient())
        )
        .navigationTitle("Pokedex")
    }
}
