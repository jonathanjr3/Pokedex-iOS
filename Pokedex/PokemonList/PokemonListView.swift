//
//  PokemonListView.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 15/05/2025.
//

import Flow
import Foundation
import SwiftUI

struct PokemonListView: View {
    @State private var viewModel: PokemonListViewModel
    @State private var showFilterSheet: Bool = false
    @Namespace var animation

    // For grid layout
    private let gridItems: [GridItem] = Array(
        repeating: .init(.flexible(), spacing: 16),
        count: 2
    )

    init(apiService: PokemonAPIService = .shared) {
        viewModel = PokemonListViewModel(apiService: apiService)
    }

    var body: some View {
        List {
            ForEach(viewModel.displayedPokemonItems) { pokemonItem in
                NavigationLink {
                    PokemonDetailView(
                        pokemonID: pokemonItem.id,
                        pokemonName: pokemonItem.name,
                        animation: animation
                    )
                    .toolbarVisibility(.hidden, for: .navigationBar)
                } label: {
                    PokemonListRow(
                        pokemonItem: pokemonItem,
                        animation: animation
                    )
                }
            }

            if viewModel.isLoading || viewModel.isLoadingFilteredPokemon {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding()
                    Spacer()
                }
            }

            if let errorMessage = viewModel.errorMessage,
                viewModel.displayedPokemonItems.isEmpty
            {
                ContentUnavailableView {
                    Label(
                        "Something went wrong",
                        systemImage: "wifi.exclamationmark"
                    )
                } description: {
                    Text(errorMessage)
                } actions: {
                    Button("Retry", systemImage: "arrow.clockwise") {
                        Task {
                            if let filterType = viewModel.selectedFilterType {
                                await viewModel.fetchPokemon(
                                    for: filterType
                                )
                            } else {
                                await viewModel.fetchAllPokemonSummaries()
                                await viewModel.fetchAllTypes()
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                }
            } else if !viewModel.isLoading
                && !viewModel.isLoadingFilteredPokemon
                && viewModel.displayedPokemonItems.isEmpty
                && (viewModel.isSearching
                    || viewModel.selectedFilterType != nil)
            {
                ContentUnavailableView.search(text: viewModel.searchQuery)
                Button("Clear search term and filters", systemImage: "xmark.circle.fill") {
                    viewModel.clearTypeFilter()
                    viewModel.cancelSearch()
                }
            }
        }
        .searchable(
            text: $viewModel.searchQuery,
            prompt: "Search Pokémon by name or id"
        )
        .debounce(
            $viewModel.searchQuery,
            using: viewModel.queryChannel,
            for: .seconds(0.3),
            action: viewModel.performSearch
        )
        .onAppear {
            if viewModel.allPokemonSummaries.isEmpty {
                Task {
                    await viewModel.fetchAllPokemonSummaries()
                }
            }
            if viewModel.allTypes.isEmpty {
                Task {
                    await viewModel.fetchAllTypes()
                }
            }
        }
        .toolbar(content: {
            ToolbarItem(placement: .automatic) {
                Label(
                    "Filter",
                    systemImage: "line.3.horizontal.decrease.circle"
                )
                .onTapGesture {
                    showFilterSheet.toggle()
                }
            }
        })
        .sheet(isPresented: $showFilterSheet) {
            VStack(alignment: .leading) {
                HStack {
                    Text("Filters")
                        .font(.system(.largeTitle, weight: .bold))
                        .padding(.bottom, 10)
                    Spacer()
                    Button("Clear All", systemImage: "xmark.circle.fill") {
                        viewModel.clearTypeFilter()
                        showFilterSheet.toggle()
                    }
                }
                Section {
                    HFlow {
                        ForEach(viewModel.allTypes) { typeInfo in
                            TypePill(
                                typeInfo: typeInfo,
                                shouldShowBackgroundColour: viewModel
                                    .selectedFilterType?.name == typeInfo.name
                            )
                            .onTapGesture {
                                showFilterSheet.toggle()
                                Task {
                                    await viewModel.fetchPokemon(for: typeInfo)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Pokemon Types")
                        .font(
                            .system(
                                .headline,
                                design: .rounded,
                                weight: .semibold
                            )
                        )
                } footer: {
                    Text("Tap on a type to filter the list")
                        .font(.footnote)
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal)
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
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
