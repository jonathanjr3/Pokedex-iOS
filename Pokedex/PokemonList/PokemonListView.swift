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
    @FocusState private var focusSearchField: Bool

    private let gridColumns: [GridItem] = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]

    init(apiService: PokemonAPIService = .shared) {
        viewModel = PokemonListViewModel(apiService: apiService)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !networkMonitor.isConnected {
                    NoInternetView()
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                ScrollView {
                    if viewModel.displayedPokemonItems.isEmpty
                        && (viewModel.isLoading
                            || viewModel.isLoadingFilteredPokemon)
                    {
                        ProgressView("Catching 'em all...")
                            .frame(maxWidth: .infinity)
                            .padding(.top, 50)
                    } else if let errorMessage = viewModel.errorMessage,
                        viewModel.displayedPokemonItems.isEmpty
                            && !viewModel.isLoading
                    {
                        contentUnavailableRetryView(errorMessage: errorMessage)
                            .padding(.top, 50)
                    } else if viewModel.showNoResultsIndicator {
                        VStack {
                            ContentUnavailableView.search(
                                text: viewModel.searchQuery
                            )
                            HStack {
                                if !viewModel.searchQuery.isEmpty {
                                    Button(
                                        "Clear search",
                                        systemImage: "xmark.circle"
                                    ) {
                                        viewModel.cancelSearch()
                                    }
                                }
                                if viewModel.selectedFilterType != nil {
                                    Button(
                                        "Clear filter",
                                        systemImage:
                                            "line.3.horizontal.decrease.circle.fill"
                                    ) {
                                        viewModel.clearTypeFilter()
                                    }
                                }
                            }
                            .buttonStyle(.bordered)
                            .padding(.top)
                        }
                        .padding(.top, 50)
                    } else {
                        // The Grid
                        LazyVGrid(columns: gridColumns, spacing: 16) {
                            ForEach(viewModel.displayedPokemonItems) {
                                pokemonItem in
                                NavigationLink {
                                    PokemonDetailView(
                                        pokemonID: pokemonItem.id,
                                        pokemonName: pokemonItem.name,
                                        animation: animation
                                    )
                                    .toolbar(.hidden, for: .tabBar)
                                } label: {
                                    PokemonGridCell(
                                        pokemonItem: pokemonItem,
                                        animation: animation
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)

                        if (viewModel.isLoading
                            || viewModel.isLoadingFilteredPokemon)
                            && !viewModel.displayedPokemonItems.isEmpty
                        {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                }
            }
            .navigationTitle("Pokédex")
            .searchable(
                text: $viewModel.searchQuery,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search Pokémon by name or ID"
            )
            .searchFocused($focusSearchField)
            // This is required to hide navigation bar in details view when search is active
            .searchPresentationToolbarBehavior(.avoidHidingContent)
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
                if let action = Utilities.quickActionManager.selectedAction {
                    handleQuickAction(action: action)
                }
            }
            .onChange(
                of: Utilities.quickActionManager.selectedAction,
                { oldValue, newValue in
                    if let action = newValue {
                        handleQuickAction(action: action)
                    }
                }
            )
            .toolbar {
                ToolbarItem {
                    Button {
                        showFilterSheet.toggle()
                    } label: {
                        Label(
                            "Filter",
                            systemImage: "line.3.horizontal.decrease.circle"
                        )
                    }
                }
            }
            .sheet(isPresented: $showFilterSheet) {
                filterView
            }
            .background(Color.gridListBackground)
        }
    }
    
    private func handleQuickAction(action: QuickActionType) {
        guard action == .search else { return }
        focusSearchField = true
        Utilities.quickActionManager.selectedAction = nil
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
                .buttonStyle(.borderedProminent)
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

    private func contentUnavailableRetryView(errorMessage: String) -> some View
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
