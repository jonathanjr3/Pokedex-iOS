//
//  MockPokemonAPIService.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 15/05/2025.
//
import OpenAPIRuntime

// Ideally APIProtocol from OpenAPIRuntime should be mocked
// But since it contains a lot of methods (most of which are not used in this app) and due to time constraints, it's impractical to do so
// Henceforth mocking only the methods used in this app.

struct MockPokemonAPIService: PokemonAPIServiceProtocol {
    func getPokemonList(limit: Int?, offset: Int?) async throws(NetworkError) -> Components.Schemas.PaginatedPokemonSummaryList {
        let bulbasaur = Components.Schemas.PokemonSummary(name: "Bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/")
        let charmander = Components.Schemas.PokemonSummary(name: "Charmander", url: "https://pokeapi.co/api/v2/pokemon/4/")
        let squirtle = Components.Schemas.PokemonSummary(name: "Squirtle", url: "https://pokeapi.co/api/v2/pokemon/7/")
        return .init(count: 3, next: nil, previous: nil, results: [bulbasaur, charmander, squirtle])
    }

    func getPokemonDetails(id: String) async throws(NetworkError) -> Components.Schemas.PokemonDetail {
        throw .unknownError
    }
    func getPokemonColor(id: String) async throws(NetworkError) -> Components.Schemas.PokemonColorDetail {
        throw .unknownError
    }
    func getTypeDetails(id: String) async throws(NetworkError) -> Components.Schemas.TypeDetail {
        throw .unknownError
    }
    func getPokemonSpecies(id: String) async throws(NetworkError) -> Components.Schemas.PokemonSpeciesDetail {
        throw .unknownError
    }
}
