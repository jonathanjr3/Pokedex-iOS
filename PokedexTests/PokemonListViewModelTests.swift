//
//  PokemonListViewModelTests.swift
//  PokedexTests
//
//  Created by Jonathan Rajya on 20/05/2025.
//

import Testing
@testable import Pokedex

@MainActor
struct PokemonListViewModelTests {

    var mockApiClient: MockPokemonAPIClient!
    var pokemonApiService: PokemonAPIService!
    var viewModel: PokemonListViewModel!

    init() {
        mockApiClient = MockPokemonAPIClient()
        pokemonApiService = PokemonAPIService(apiClient: mockApiClient)
        viewModel = PokemonListViewModel(apiService: pokemonApiService)
    }

    @Test("Initial State: ViewModel initializes with empty lists and default flags")
    func testInitialState() {
        #expect(viewModel.displayedPokemonItems.isEmpty)
        #expect(viewModel.allPokemonSummaries.isEmpty)
        #expect(viewModel.allTypes.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.isLoadingTypes == false)
        #expect(viewModel.isLoadingFilteredPokemon == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.selectedFilterType == nil)
        #expect(viewModel.searchQuery.isEmpty)
        #expect(viewModel.isSearchActive == false)
    }

    @Test("Fetch All Summaries: Successfully fetches and updates displayed items")
    func testFetchAllPokemonSummaries_Success() async throws {
        // Initial state check
        #expect(viewModel.allSummariesLoaded == false)

        await viewModel.fetchAllPokemonSummaries()

        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.allPokemonSummaries.count == 3)
        #expect(viewModel.displayedPokemonItems.count == 3)
        #expect(viewModel.displayedPokemonItems.first?.name == "Bulbasaur")
        #expect(viewModel.allSummariesLoaded == true)
    }

    @Test("Fetch All Summaries: Handles API error gracefully")
    func testFetchAllPokemonSummaries_Failure() async throws {
        mockApiClient.shouldThrowErrorOnPokemonList = true

        await viewModel.fetchAllPokemonSummaries()

        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage != nil, "Error message should be set on failure")
        #expect(viewModel.allPokemonSummaries.isEmpty)
        #expect(viewModel.displayedPokemonItems.isEmpty)
        #expect(viewModel.allSummariesLoaded == false)

        mockApiClient.shouldThrowErrorOnPokemonList = false
    }

    @Test("Fetch All Summaries: Does not re-fetch if already loaded")
    func testFetchAllPokemonSummaries_Idempotency() async throws {
        await viewModel.fetchAllPokemonSummaries()
        #expect(viewModel.allPokemonSummaries.count == 3)

        let initialCallCount = mockApiClient.pokemonListCallCount
        mockApiClient.shouldThrowErrorOnPokemonList = true

        await viewModel.fetchAllPokemonSummaries()

        #expect(mockApiClient.pokemonListCallCount == initialCallCount, "API should not be called again if summaries are already loaded")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.allPokemonSummaries.count == 3)
        
        mockApiClient.shouldThrowErrorOnPokemonList = false
    }

    @Test("Fetch All Types: Successfully fetches and populates allTypes")
    func testFetchAllTypes_Success() async throws {
        await viewModel.fetchAllTypes()

        #expect(viewModel.isLoadingTypes == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.allTypes.count == 5)
        #expect(viewModel.allTypes.first?.name == "normal")
    }

    @Test("Fetch All Types: Handles API error")
    func testFetchAllTypes_Failure() async throws {
        mockApiClient.shouldThrowErrorOnTypeList = true

        await viewModel.fetchAllTypes()

        #expect(viewModel.isLoadingTypes == false)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.allTypes.isEmpty)
        
        mockApiClient.shouldThrowErrorOnTypeList = false
    }
    
    @Test("Search: Filters all summaries when no type filter is active")
    func testSearch_OnAllSummaries() async throws {
        await viewModel.fetchAllPokemonSummaries()

        viewModel.searchQuery = "Bulba"
        viewModel.performSearch(query: "Bulba")

        #expect(viewModel.isSearchActive == true)
        #expect(viewModel.displayedPokemonItems.count == 1)
        #expect(viewModel.displayedPokemonItems.first?.name == "Bulbasaur")
    }

    @Test("Search: No results found")
    func testSearch_NoResults() async throws {
        await viewModel.fetchAllPokemonSummaries()

        viewModel.searchQuery = "NonExistentPokemon123"
        viewModel.performSearch(query: "NonExistentPokemon123")

        #expect(viewModel.isSearchActive == true)
        #expect(viewModel.displayedPokemonItems.isEmpty)
        #expect(viewModel.showNoResultsIndicator == true)
    }
    
    @Test("Cancel Search: Clears search and shows all items (or type filtered)")
    func testCancelSearch() async throws {
        await viewModel.fetchAllPokemonSummaries()
        viewModel.searchQuery = "Bulba"
        viewModel.performSearch(query: "Bulba")
        #expect(viewModel.displayedPokemonItems.count == 1)

        viewModel.cancelSearch()

        #expect(viewModel.searchQuery.isEmpty)
        #expect(viewModel.isSearchActive == false)
        #expect(viewModel.displayedPokemonItems.count == 3)
    }
    
    @Test("Show No Results Indicator: Correctly reflects state")
    func testShowNoResultsIndicator_WhenSearchYieldsNone() async throws {
        await viewModel.fetchAllPokemonSummaries()
        viewModel.searchQuery = "XYZ"
        viewModel.performSearch(query: "XYZ")
        #expect(viewModel.displayedPokemonItems.isEmpty)
        #expect(viewModel.showNoResultsIndicator == true)
    }

    @Test("Show No Results Indicator: Correctly reflects state when filter yields none")
    func testShowNoResultsIndicator_WhenFilterYieldsNone() async throws {
        mockApiClient.pokemonForElectricType = []
        let electricType = PokemonTypeInfo(name: "electric", typeId: 13)
        await viewModel.fetchPokemon(for: electricType)
        #expect(viewModel.displayedPokemonItems.isEmpty)
        #expect(viewModel.showNoResultsIndicator == true)
    }
}
