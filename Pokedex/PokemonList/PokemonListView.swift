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
    @Environment(\.networkMonitor) private var networkMonitor
    
    private var currentDevice: UIUserInterfaceIdiom {
        UIDevice.current.userInterfaceIdiom
    }

    init(apiService: PokemonAPIService = .shared) {
        viewModel = PokemonListViewModel(apiService: apiService)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !networkMonitor.isConnected {
                    NoInternetView()
                }
                List {
                    ForEach(viewModel.displayedPokemonItems) { pokemonItem in
                        NavigationLink {
                            PokemonDetailView(
                                pokemonID: pokemonItem.id,
                                pokemonName: pokemonItem.name,
                                animation: animation
                            )
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
                        contentUnavailableRetryView(errorMessage: errorMessage)
                    } else if viewModel.showNoSearchResults {
                        ContentUnavailableView.search(text: viewModel.searchQuery)
                            .listRowSeparator(.hidden)
                        HStack {
                            if !viewModel.searchQuery.isEmpty {
                                Button("Clear search term", systemImage: "clear") {
                                    viewModel.cancelSearch()
                                }
                            }
                            if viewModel.selectedFilterType != nil {
                                Button("Clear filters", systemImage: "clear") {
                                    viewModel.clearTypeFilter()
                                }
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .searchable(
                    text: $viewModel.searchQuery,
                    placement: .navigationBarDrawer(displayMode: .always),
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
                    ToolbarItem {
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
                    filterView
                }
            }.navigationTitle("Pokédex")
        }
    }

    private var filterView: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Filters")
                    .font(.system(.largeTitle, weight: .bold))
                    .padding(.bottom, 10)
                Spacer()
                Button("Clear All", systemImage: "clear") {
                    viewModel.clearTypeFilter()
                    showFilterSheet.toggle()
                }
                .sensoryFeedback(
                    .selection,
                    trigger: viewModel.selectedFilterType
                )
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
                        .sensoryFeedback(
                            .selection,
                            trigger: viewModel.selectedFilterType
                        )
                    }
                }
            } header: {
                Text("Pokemon Types")
                    .font(
                        .system(
                            .headline,
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
    
    private func contentUnavailableRetryView(errorMessage: String) -> some View {
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
                    if let filterType = viewModel.selectedFilterType
                    {
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
    }
}

// Preview
#Preview {
    NavigationStack {
        PokemonListView(
            apiService: PokemonAPIService(apiClient: MockPokemonAPIClient())
        )
        .navigationTitle("Pokedex")
        .environment(NetworkMonitor())
    }
}
