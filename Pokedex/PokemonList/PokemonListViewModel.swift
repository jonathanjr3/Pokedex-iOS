//
//  PokemonListViewModel.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 15/05/2025.
//

import SwiftUI
import Combine
import Foundation
import AsyncAlgorithms

@Observable
final class PokemonListViewModel {
    private(set) var allPokemonSummaries: [Components.Schemas.PokemonSummary] = []
    var searchResults: [PokemonListItem] = []
    var isSearching: Bool = false
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var searchQuery: String = ""
    private let apiService: PokemonAPIService
    private var allSummariesLoaded = false
    @ObservationIgnored let queryChannel = AsyncChannel<String>()

    init(apiService: PokemonAPIService = .shared) {
        self.apiService = apiService
    }

    // Fetch all summaries for default list and search
    func fetchAllPokemonSummariesIfNeeded() async {
        guard !allSummariesLoaded else { return }
        isLoading = true
        errorMessage = nil
        var allResults: [Components.Schemas.PokemonSummary] = []
        var offset = 0
        let pageSize = 2000
        var keepGoing = true
        while keepGoing {
            do {
                let page = try await apiService.getPokemonList(limit: pageSize, offset: offset)
                if let results = page.results {
                    allResults.append(contentsOf: results)
                    offset += results.count
                    keepGoing = (page.next != nil && !results.isEmpty)
                } else {
                    keepGoing = false
                }
            } catch {
                errorMessage = "Failed to load Pokémon: \(error.localizedDescription)"
                print("Error fetching all summaries: \(error)")
                break
            }
        }
        allPokemonSummaries = allResults
        allSummariesLoaded = true
        isLoading = false
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
            summary.name.lowercased().contains(lowercased) ||
            (Utilities.extractID(from: summary.url)?.description.contains(lowercased) ?? false)
        }
        searchResults = filtered.map { PokemonListItem(pokemonSummary: $0) }
    }

    func cancelSearch() {
        isSearching = false
        searchResults = []
    }
}
