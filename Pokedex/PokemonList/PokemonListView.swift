//
//  PokemonListView.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 15/05/2025.
//

import SwiftUI
import OpenAPIRuntime

struct PokemonListView: View {
    @State private var viewModel: PokemonListViewModel
    @Namespace var animation

    // For grid layout
    private let gridItems: [GridItem] = Array(repeating: .init(.flexible(), spacing: 16), count: 2)

    init(apiService: PokemonAPIServiceProtocol = PokemonAPIService.shared) {
        viewModel = PokemonListViewModel(apiService: apiService)
    }

    var body: some View {
        List {
            ForEach(viewModel.pokemonListItems) { pokemonItem in
                NavigationLink {
                    PokemonDetailView(pokemonId: pokemonItem.id, animation: animation, imageURL: getPokemonSpriteURL(ID: pokemonItem.id))
                } label: {
                    PokemonListRow(pokemonItem: pokemonItem, animation: animation)
                }
                .onAppear {
                    Task {
                        await viewModel.fetchMorePokemonIfNeeded(currentItem: pokemonItem)
                    }
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

            if viewModel.canLoadMore && !viewModel.isLoading && !viewModel.pokemonListItems.isEmpty {
                HStack {
                    Spacer()
                    Text("Loading more...")
                    Spacer()
                }
                .onAppear {
                    Task {
                         await viewModel.fetchMorePokemonIfNeeded(currentItem: nil)
                    }
                }
            }
            
            if let errorMessage = viewModel.errorMessage, viewModel.pokemonListItems.isEmpty {
                 ContentUnavailableView(
                     "Oops! Something went wrong.",
                     systemImage: "wifi.exclamationmark",
                     description: Text(errorMessage)
                 )
            }
        }
//        .listStyle(.plain)
        .onAppear {
            if viewModel.pokemonListItems.isEmpty {
                Task {
                    await viewModel.fetchInitialPokemonList()
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
            .matchedTransitionSource(id: pokemonItem.id, in: animation) { config in
                config
                    .background(.clear)
            }

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
        PokemonListView(apiService: MockPokemonAPIService())
            .navigationTitle("Pokedex")
    }
}
