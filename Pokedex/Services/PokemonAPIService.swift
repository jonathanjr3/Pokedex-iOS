//
//  PokemonAPIService.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 11/05/2025.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

actor PokemonAPIService {
    private let client: Client
    private let transport: URLSessionTransport

    init() {
        self.transport = URLSessionTransport()
        self.client = Client(
            serverURL: try! Servers.Server1.url(),
            transport: self.transport
        )
    }

    func getPokemonList(limit: Int?, offset: Int?) async throws -> Components.Schemas.PaginatedPokemonSummaryList {
        let response = try await client.pokemonList(query: .init(limit: limit, offset: offset))
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let pokemonList):
                return pokemonList
            }
        case .undocumented(statusCode: let statusCode, _):
             throw NetworkError(code: statusCode, message: "Undocumented response: \(statusCode)")
        }
    }

    func getPokemonDetails(id: String) async throws -> Components.Schemas.PokemonDetail {
        let response = try await client.pokemonRetrieve(.init(path: .init(id: id)))
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let pokemonDetail):
                return pokemonDetail
            }
        case .undocumented(statusCode: let statusCode, _):
            throw NetworkError(code: statusCode, message: "Undocumented response: \(statusCode)")
        }
    }

    func getPokemonColor(id: String) async throws -> Components.Schemas.PokemonColorDetail {
        let response = try await client.pokemonColorRetrieve(path: .init(id: id))
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let pokemonColorDetail):
                return pokemonColorDetail
            }
        case .undocumented(statusCode: let statusCode, _):
            throw NetworkError(code: statusCode, message: "Undocumented response: \(statusCode)")
        }
    }

    // Placeholder for fetching Type details
    func getTypeDetails(id: String) async throws -> Components.Schemas.TypeDetail {
        let response = try await client.typeRetrieve(path: .init(id: id))
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let typeDetail):
                return typeDetail
            }
        case .undocumented(statusCode: let statusCode, _):
            throw NetworkError(code: statusCode, message: "Undocumented response: \(statusCode)")
        }
    }
}

// Helper to extract ID from Pokemon URL
// e.g., "https://pokeapi.co/api/v2/pokemon/1/" -> 1
func extractID(from urlString: String?) -> Int? {
    guard let urlString, let url = URL(string: urlString) else { return nil }
    let components = url.pathComponents
    if components.count >= 2, let idString = components.dropLast().last, let id = Int(idString) {
        return id
    }
    return nil
}

/// Custom type to include information about api errors
struct NetworkError: Error {
    let code: Int
    let message: String
}
