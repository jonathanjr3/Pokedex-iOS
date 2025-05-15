//
//  PokemonListViewModel.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 15/05/2025.
//

import SwiftUI
import Combine

@Observable class PokemonListViewModel {
    var pokemonListItems: [PokemonListItem] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var canLoadMore: Bool = true

    private var currentPageOffset: Int = 0
    private let itemsPerPage: Int = 40

    private let apiService: PokemonAPIServiceProtocol

    init(apiService: PokemonAPIServiceProtocol = PokemonAPIService.shared) {
        self.apiService = apiService
    }

    func fetchInitialPokemonList() async {
        guard !isLoading else { return } // Prevent multiple simultaneous loads
        isLoading = true
        errorMessage = nil
        currentPageOffset = 0 // Reset for initial fetch
        pokemonListItems.removeAll() // Clear existing list for a fresh fetch
        canLoadMore = true

        do {
            let paginatedResponse = try await apiService.getPokemonList(limit: itemsPerPage, offset: currentPageOffset)
            if let results = paginatedResponse.results {
                let newItems = results.compactMap { PokemonListItem(pokemonSummary: $0) }
                self.pokemonListItems.append(contentsOf: newItems)
                self.currentPageOffset += newItems.count // newItems.count might be less than itemsPerPage if it's the last page
                self.canLoadMore = paginatedResponse.next != nil && !newItems.isEmpty // Check if there's a next page URL
            } else {
                self.canLoadMore = false // No results, assume no more can be loaded
            }
        } catch {
            self.errorMessage = "Failed to load Pokémon: \(error.localizedDescription)"
            self.canLoadMore = false // Stop pagination on error
            print("Error fetching initial Pokemon list: \(error)")
        }
        isLoading = false
    }

    func fetchMorePokemonIfNeeded(currentItem: PokemonListItem?) async {
        guard let currentItem = currentItem, canLoadMore, !isLoading else {
            // If no current item, or can't load more, or already loading, do nothing
            if !canLoadMore && !isLoading { print("Cannot load more or already loaded all.") }
            return
        }

        // Determine if the currentItem is near the end of the list
        let thresholdIndex = pokemonListItems.index(pokemonListItems.endIndex, offsetBy: -10)
        if let itemIndex = pokemonListItems.firstIndex(where: { $0.id == currentItem.id }), itemIndex >= thresholdIndex {
            await fetchMorePokemon()
        }
    }

    private func fetchMorePokemon() async {
        guard !isLoading, canLoadMore else { return }
        isLoading = true
        errorMessage = nil

        print("Fetching more Pokemon, offset: \(currentPageOffset)")

        do {
            let paginatedResponse = try await apiService.getPokemonList(limit: itemsPerPage, offset: currentPageOffset)
            if let results = paginatedResponse.results {
                let newItems = results.compactMap { PokemonListItem(pokemonSummary: $0) }
                self.pokemonListItems.append(contentsOf: newItems)
                self.currentPageOffset += newItems.count
                self.canLoadMore = paginatedResponse.next != nil && !newItems.isEmpty
                print("Fetched \(newItems.count) more. Total: \(pokemonListItems.count). Can load more: \(canLoadMore)")
            } else {
                self.canLoadMore = false
                print("No more results from API.")
            }
        } catch {
            print("Error fetching more Pokémon: \(error.localizedDescription)")
            self.canLoadMore = false
        }
        isLoading = false
    }
}
