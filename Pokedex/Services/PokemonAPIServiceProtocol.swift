//
//  PokemonAPIServiceProtocol.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 15/05/2025.
//
import OpenAPIRuntime

// Using a separate protocol to make testing easier
protocol PokemonAPIServiceProtocol {
    func getPokemonList(limit: Int?, offset: Int?) async throws(NetworkError) -> Components.Schemas.PaginatedPokemonSummaryList
    func getPokemonDetails(id: String) async throws(NetworkError) -> Components.Schemas.PokemonDetail
    func getPokemonColor(id: String) async throws(NetworkError) -> Components.Schemas.PokemonColorDetail
    func getTypeDetails(id: String) async throws(NetworkError) -> Components.Schemas.TypeDetail
}
