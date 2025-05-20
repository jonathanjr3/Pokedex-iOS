//
//  PokemonListViewModel.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 15/05/2025.
//

import AsyncAlgorithms
import Foundation
import SwiftUI

@Observable
final class PokemonListViewModel {
    // MARK: - Published State
    private(set) var isLoading: Bool = false
    private(set) var isLoadingTypes: Bool = false
    private(set) var isLoadingFilteredPokemon: Bool = false
    private(set) var errorMessage: String? = nil

    // Data sources
    private(set) var allPokemonSummaries: [Components.Schemas.PokemonSummary] =
        []
    private(set) var allTypes: [PokemonTypeInfo] = []

    // Filtering and Search State
    var searchQuery: String = ""
    private(set) var selectedFilterType: PokemonTypeInfo? = nil
    private(set) var displayedPokemonItems: [PokemonListItem] = []

    // Internal state for search status, distinct from searchQuery being non-empty
    private(set) var isSearchActive: Bool = false

    // MARK: - Computed Properties for UI State
    var showNoResultsIndicator: Bool {
        return !isLoading && !isLoadingFilteredPokemon && !isLoadingTypes
            && displayedPokemonItems.isEmpty
            && (isSearchActive || selectedFilterType != nil)
    }

    // MARK: - Dependencies & Private State
    private let apiService: PokemonAPIService
    private(set) var allSummariesLoaded = false
    @ObservationIgnored let queryChannel = AsyncChannel<String>()  // For view's .debounce
    private var pokemonOfType: [Components.Schemas.PokemonSummary] = [] // To store the result of a type filter

    // MARK: - Initialization
    init(apiService: PokemonAPIService = .shared) {
        self.apiService = apiService
        updateDisplayedPokemon()
    }

    // MARK: - Data Fetching
    func fetchAllPokemonSummaries() async {
        guard !allSummariesLoaded, !isLoading else { return }
        isLoading = true
        errorMessage = nil
        var allResults: [Components.Schemas.PokemonSummary] = []
        do {
            let page = try await apiService.getPokemonList(
                limit: 2000,
                offset: 0
            )
            if let results = page.results {
                allResults.append(contentsOf: results)
            }
            allPokemonSummaries = allResults
            allSummariesLoaded = true
        } catch {
            errorMessage =
                "Failed to load Pokémon list: \(error.localizedDescription)"
            print("Error fetching all summaries: \(error)")
        }
        isLoading = false
        updateDisplayedPokemon()
    }

    func fetchAllTypes() async {
        guard !isLoadingTypes && allTypes.isEmpty else { return }
        isLoadingTypes = true
        do {
            let typeListResponse = try await apiService.getAllTypes(
                limit: 100,
                offset: 0
            )
            if let results = typeListResponse.results {
                allTypes = results.compactMap { typeSummary in
                    guard
                        let typeId = Utilities.extractID(from: typeSummary.url)
                    else { return nil }
                    return PokemonTypeInfo(
                        name: typeSummary.name,
                        typeId: typeId
                    )
                }
            }
        } catch {
            errorMessage =
                "Failed to load Pokémon types: \(error.localizedDescription)"
            print("Error fetching all types: \(error)")
        }
        isLoadingTypes = false
    }

    func fetchPokemon(for type: PokemonTypeInfo) async {
        selectedFilterType = type
        isLoadingFilteredPokemon = true
        errorMessage = nil

        var fetchedPokemonForType: [Components.Schemas.PokemonSummary] = []
        do {
            let typeDetailResponse = try await apiService.getTypeDetails(
                id: type.name.lowercased()
            )
            fetchedPokemonForType = typeDetailResponse.pokemon.compactMap {
                guard let name = $0.pokemon?.name, let url = $0.pokemon?.url
                else { return nil }
                return Components.Schemas.PokemonSummary(name: name, url: url)
            }
        } catch {
            errorMessage =
                "Failed to load Pokémon for type \(type.name): \(error.localizedDescription)"
            print("Error fetching pokemon for type \(type.name): \(error)")
        }
        isLoadingFilteredPokemon = false
        updateDisplayedPokemon(pokemonFetchedForType: fetchedPokemonForType)
    }

    // MARK: - Filtering and Searching Logic

    /// Central method to update `displayedPokemonItems` based on current search query and filter.
    /// Call this after any state change that affects the list (data load, search, filter change).
    private func updateDisplayedPokemon(
        pokemonFetchedForType: [Components.Schemas.PokemonSummary]? = nil
    ) {
        var currentSource: [Components.Schemas.PokemonSummary]

        if selectedFilterType != nil {
            if let justFetchedForType = pokemonFetchedForType {
                self.pokemonOfType = justFetchedForType
                currentSource = self.pokemonOfType
            } else {
                // Filter already active, use existing pokemonOfType list
                currentSource = self.pokemonOfType
            }
        } else {
            // No type filter, use all Pokemon summaries.
            currentSource = allPokemonSummaries
        }

        // Apply search if search query is active
        if isSearchActive, !searchQuery.isEmpty {
            let lowercasedQuery = searchQuery.lowercased()
            currentSource = currentSource.filter { summary in
                summary.name.lowercased().contains(lowercasedQuery)
                    || (Utilities.extractID(from: summary.url)?.description
                        .contains(lowercasedQuery) ?? false)
            }
        }

        // Map to UI model
        displayedPokemonItems = currentSource.map {
            PokemonListItem(pokemonSummary: $0)
        }
    }

    // Called by the view's .debounce mechanism or directly
    func performSearch(query: String) {
        isSearchActive = !query.isEmpty
        updateDisplayedPokemon()
    }

    func cancelSearch() {
        searchQuery = ""
        isSearchActive = false
        updateDisplayedPokemon()
    }

    func clearTypeFilter() {
        selectedFilterType = nil
        pokemonOfType.removeAll()
        updateDisplayedPokemon()
    }
}
