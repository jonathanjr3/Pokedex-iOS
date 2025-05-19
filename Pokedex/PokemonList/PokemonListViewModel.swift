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
    private(set) var allPokemonSummaries: [Components.Schemas.PokemonSummary] =
        []
    private(set) var searchResults: [PokemonListItem] = []
    private(set) var isSearching: Bool = false
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String? = nil
    private(set) var allTypes: [PokemonTypeInfo] = []
    private(set) var selectedFilterType: PokemonTypeInfo? = nil
    private(set) var isLoadingTypes: Bool = false

    var searchQuery: String = ""
    var displayedPokemonItems: [PokemonListItem] {
        let sourceSummaries: [Components.Schemas.PokemonSummary]

        if isSearching && !searchQuery.isEmpty {
            if selectedFilterType != nil {
                _ = allPokemonSummaries.filter {
                    summary in
                    let lowercasedQuery = searchQuery.lowercased()
                    return summary.name.lowercased().contains(lowercasedQuery)
                        || (Utilities.extractID(from: summary.url)?.description
                            .contains(lowercasedQuery) ?? false)
                }
                if !pokemonOfType.isEmpty {
                    sourceSummaries = pokemonOfType.filter { summary in  // pokemonOfType holds PokemonSummary
                        let lowercasedQuery = searchQuery.lowercased()
                        return summary.name.lowercased().contains(
                            lowercasedQuery
                        )
                            || (Utilities.extractID(from: summary.url)?
                                .description.contains(lowercasedQuery) ?? false)
                    }
                } else {
                    // If pokemonOfType is empty (e.g., filter selected but fetch failed, or no filter)
                    // fall back to searching all summaries
                    sourceSummaries = allPokemonSummaries.filter { summary in
                        let lowercasedQuery = searchQuery.lowercased()
                        return summary.name.lowercased().contains(
                            lowercasedQuery
                        )
                            || (Utilities.extractID(from: summary.url)?
                                .description.contains(lowercasedQuery) ?? false)
                    }
                }
            } else {  // No type filter, just search
                sourceSummaries = allPokemonSummaries.filter { summary in
                    let lowercasedQuery = searchQuery.lowercased()
                    return summary.name.lowercased().contains(lowercasedQuery)
                        || (Utilities.extractID(from: summary.url)?.description
                            .contains(lowercasedQuery) ?? false)
                }
            }
            return sourceSummaries.map { PokemonListItem(pokemonSummary: $0) }

        } else if selectedFilterType != nil {
            // No search, just type filter. Use `pokemonOfType`.
            return pokemonOfType.map { PokemonListItem(pokemonSummary: $0) }
        } else {
            // No search, no filter. Display all.
            return allPokemonSummaries.map {
                PokemonListItem(pokemonSummary: $0)
            }
        }
    }

    private(set) var pokemonOfType: [Components.Schemas.PokemonSummary] = []
    private(set) var isLoadingFilteredPokemon: Bool = false

    private let apiService: PokemonAPIService
    private var allSummariesLoaded = false
    @ObservationIgnored let queryChannel = AsyncChannel<String>()

    init(apiService: PokemonAPIService = .shared) {
        self.apiService = apiService
    }

    // Fetch all summaries for default list and search
    func fetchAllPokemonSummaries() async {
        guard !allSummariesLoaded else { return }
        isLoading = true
        errorMessage = nil
        var allResults: [Components.Schemas.PokemonSummary] = []
        let offset = 0
        let pageSize = 2000
        do {
            let page = try await apiService.getPokemonList(
                limit: pageSize,
                offset: offset
            )
            if let results = page.results {
                allResults.append(contentsOf: results)
            }
        } catch {
            errorMessage =
                "Failed to load Pokémon: \(error.localizedDescription)"
            print("Error fetching all summaries: \(error)")
            return
        }
        allPokemonSummaries = allResults
        allSummariesLoaded = true
        isLoading = false
    }

    // Fetch all types for the filter
    func fetchAllTypes() async {
        guard !isLoadingTypes && allTypes.isEmpty else { return }
        isLoadingTypes = true
        errorMessage = nil
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
                        typeId: typeId,
                        name: typeSummary.name
                    )
                }
            }
        } catch {
            print("Error fetching all types: \(error.localizedDescription)")
            self.errorMessage =
                "Failed to load pokemon types: \(error.localizedDescription)"
        }
        isLoadingTypes = false
    }

    // Fetch Pokémon for a selected type
    func fetchPokemon(for type: PokemonTypeInfo) async {
        selectedFilterType = type
        isLoadingFilteredPokemon = true
        pokemonOfType.removeAll()
        errorMessage = nil

        do {
            let typeDetailResponse = try await apiService.getTypeDetails(
                id: type.name.lowercased()
            )

            self.pokemonOfType = typeDetailResponse.pokemon.compactMap {
                guard let name = $0.pokemon?.name, let url = $0.pokemon?.url else { return nil }
                return Components.Schemas.PokemonSummary(name: name, url: url)
            }

        } catch {
            self.errorMessage =
                "Failed to load Pokémon for type \(type.name): \(error.localizedDescription)"
            print("Error fetching pokemon for type \(type.name): \(error)")
        }
        isLoadingFilteredPokemon = false
    }
    
    func clearTypeFilter() {
        selectedFilterType = nil
        pokemonOfType.removeAll()
    }

    // Called by debounce
    func performSearch(query: String) {
        guard !query.isEmpty else {
            isSearching = false
            searchResults = []
            return
        }
        isSearching = true
        let lowercased = query.lowercased()
        let filtered = allPokemonSummaries.filter { summary in
            summary.name.lowercased().contains(lowercased)
                || (Utilities.extractID(from: summary.url)?.description
                    .contains(lowercased) ?? false)
        }
        searchResults = filtered.map { PokemonListItem(pokemonSummary: $0) }
    }

    func cancelSearch() {
        isSearching = false
        searchQuery = ""
        searchResults = []
    }
}
