//
//  PokemonAPIService.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 11/05/2025.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

actor PokemonAPIService: PokemonAPIServiceProtocol {
    private let client: APIProtocol
    static let shared: PokemonAPIService = PokemonAPIService()
    
    private init() {
        self.client = Client(
            serverURL: try! Servers.Server1.url(),
            transport: URLSessionTransport()
        )
    }

    func getPokemonList(limit: Int?, offset: Int?) async throws(NetworkError) -> Components.Schemas.PaginatedPokemonSummaryList {
        var response: Operations.PokemonList.Output = .undocumented(statusCode: 500, .init())
        do {
            response = try await client.pokemonList(query: .init(limit: limit, offset: offset))
        } catch {
            throw .unknownError
        }
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let pokemonList):
                return pokemonList
            }
        case .undocumented(statusCode: let statusCode, _):
            throw NetworkError.undocumentedResponse(statusCode: statusCode, message: "Undocumented response: \(statusCode) for pokemonList")
        }
    }

    func getPokemonDetails(id: String) async throws(NetworkError) -> Components.Schemas.PokemonDetail {
        var response: Operations.PokemonRetrieve.Output = .undocumented(statusCode: 500, .init())
        do {
            response = try await client.pokemonRetrieve(.init(path: .init(id: id)))
        } catch {
            throw .unknownError
        }
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let pokemonDetail):
                return pokemonDetail
            }
        case .undocumented(statusCode: let statusCode, _):
            throw NetworkError.undocumentedResponse(statusCode: statusCode, message: "Undocumented response: \(statusCode) for pokemonRetrieve")
        }
    }

    func getPokemonColor(id: String) async throws(NetworkError) -> Components.Schemas.PokemonColorDetail {
        var response: Operations.PokemonColorRetrieve.Output = .undocumented(statusCode: 500, .init())
        do {
            response = try await client.pokemonColorRetrieve(path: .init(id: id))
        } catch {
            throw .unknownError
        }
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let pokemonColorDetail):
                return pokemonColorDetail
            }
        case .undocumented(statusCode: let statusCode, _):
            throw NetworkError.undocumentedResponse(statusCode: statusCode, message: "Undocumented response: \(statusCode) pokemonColorRetrieve")
        }
    }

    func getTypeDetails(id: String) async throws(NetworkError) -> Components.Schemas.TypeDetail {
        var response: Operations.TypeRetrieve.Output = .undocumented(statusCode: 500, .init())
        do {
            response = try await client.typeRetrieve(path: .init(id: id))
        } catch {
            throw .unknownError
        }
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let typeDetail):
                return typeDetail
            }
        case .undocumented(statusCode: let statusCode, _):
            throw NetworkError.undocumentedResponse(statusCode: statusCode, message: "Undocumented response: \(statusCode) typeRetrieve")
        }
    }
}

// Helper to extract ID from Pokemon URL
// e.g., "https://pokeapi.co/api/v2/pokemon/1/" -> 1
func extractID(from urlString: String) -> Int? {
    guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return nil
        }
        
        let relevantComponents = url.pathComponents.filter { !$0.isEmpty && $0 != "/" }
        
        guard let lastComponent = relevantComponents.last else {
            print("No ID found in URL")
            return nil
        }
        
        return Int(lastComponent)
}

/// Custom type to include information about api errors
enum NetworkError: Error {
    case undocumentedResponse(statusCode: Int, message: String)
    case unknownError
}
