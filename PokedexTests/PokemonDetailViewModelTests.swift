//
//  PokemonDetailViewModelTests.swift
//  PokedexTests
//
//  Created by Jonathan Rajya on 20/05/2025.
//

import Testing
@testable import Pokedex
import SwiftData
import SwiftUI

@MainActor
struct PokemonDetailViewModelTests {

    var mockApiClient: MockPokemonAPIClient!
    var pokemonApiService: PokemonAPIService!
    var modelContainer: ModelContainer!
    var viewModel: PokemonDetailViewModel!

    let testPokemonId = 1
    let testPokemonName = "Bulbasaur"

    init() async throws {
        mockApiClient = MockPokemonAPIClient()
        pokemonApiService = PokemonAPIService(apiClient: mockApiClient)

        let schema = Schema([FavouritePokemon.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: config)

        viewModel = PokemonDetailViewModel(
            pokemonId: testPokemonId,
            modelContext: modelContainer.mainContext,
            apiService: pokemonApiService
        )
    }

    @Test("Initial State: ViewModel initializes with placeholder details and default flags")
    func testInitialState() {
        #expect(viewModel.pokemonId == testPokemonId)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.errorOccurred == false)
        #expect(viewModel.isFavourite == false)
    }

    @Test("Fetch Pokemon Details: Successfully fetches and populates all details")
    func testFetchPokemonDetails_Success() async throws {
        await viewModel.fetchPokemonDetails()

        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.errorOccurred == false)

        #expect(viewModel.pokemonDetail.id == testPokemonId)
        #expect(viewModel.pokemonDetail.name == testPokemonName)
        #expect(viewModel.pokemonDetail.height > 0)
        #expect(viewModel.pokemonDetail.weight > 0)
        #expect(!viewModel.pokemonDetail.types.isEmpty)
        #expect(viewModel.pokemonDetail.types.first?.name == "grass")
        #expect(!viewModel.pokemonDetail.description.isEmpty)
        #expect(!viewModel.pokemonDetail.abilities.isEmpty)
        #expect(!viewModel.pokemonDetail.stats.isEmpty)

        #expect(!viewModel.meshGradientColours.contains(.black) || viewModel.meshGradientColours.count > 3)
    }

    @Test("Fetch Pokemon Details: Handles API error for core details")
    func testFetchPokemonDetails_CoreDetailsFailure() async throws {
        mockApiClient.shouldThrowErrorOnPokemonRetrieve = true

        await viewModel.fetchPokemonDetails()

        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.errorOccurred == true)
        #expect(viewModel.pokemonId == testPokemonId)
        #expect(viewModel.pokemonDetail.name == testPokemonName)
        
        mockApiClient.shouldThrowErrorOnPokemonRetrieve = false
    }
    
    @Test("Fetch Pokemon Details: Handles API error for species details")
    func testFetchPokemonDetails_SpeciesDetailsFailure() async throws {
        mockApiClient.shouldThrowErrorOnSpeciesRetrieve = true

        await viewModel.fetchPokemonDetails()

        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.errorOccurred == true)
        #expect(viewModel.pokemonDetail.name == testPokemonName)
        #expect(viewModel.pokemonDetail.description.contains("No description") || viewModel.pokemonDetail.description.isEmpty)
        
        mockApiClient.shouldThrowErrorOnSpeciesRetrieve = false
    }

    @Test("Favorite Logic: Initially not favorite")
    func testFavorite_InitialState() {
        #expect(viewModel.isFavourite == false)
    }

    @Test("Favorite Logic: Add to Favorites")
    func testFavorite_AddToFavorites() async throws {
        await viewModel.fetchPokemonDetails()
        #expect(viewModel.isFavourite == false)

        viewModel.toggleFavourite()

        #expect(viewModel.isFavourite == true)

        let fetchDescriptor = FetchDescriptor<FavouritePokemon>(
            predicate: #Predicate { $0.id == testPokemonId }
        )
        let count = try modelContainer.mainContext.fetchCount(fetchDescriptor)
        #expect(count == 1)
        
        if let favorite = try modelContainer.mainContext.fetch(fetchDescriptor).first {
            #expect(favorite.name == viewModel.pokemonDetail.name)
        } else {
            Issue.record("Favorite was not found in context after adding.")
        }
    }

    @Test("Favorite Logic: Remove from Favorites")
    func testFavorite_RemoveFromFavorites() async throws {
        await viewModel.fetchPokemonDetails()
        viewModel.toggleFavourite()
        #expect(viewModel.isFavourite == true)

        viewModel.toggleFavourite()

        #expect(viewModel.isFavourite == false)

        let fetchDescriptor = FetchDescriptor<FavouritePokemon>(
            predicate: #Predicate { $0.id == testPokemonId }
        )
        let count = try modelContainer.mainContext.fetchCount(fetchDescriptor)
        #expect(count == 0)
    }

    @Test("Gradient Colors: Updated after successful fetch")
    func testGradientColors_UpdatedOnFetch() async throws {
        let initialMeshColors = viewModel.meshGradientColours

        await viewModel.fetchPokemonDetails()
        
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorOccurred == false)
        #expect(viewModel.meshGradientColours != initialMeshColors || viewModel.pokemonDetail.id != -1)
        #expect(viewModel.meshGradientColours.count == 9)
    }
}
