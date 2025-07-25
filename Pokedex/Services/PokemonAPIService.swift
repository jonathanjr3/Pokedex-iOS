//
//  PokemonAPIService.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 11/05/2025.
//

import Foundation
import OpenAPIURLSession

final actor PokemonAPIService {
    private let client: APIProtocol
    /// Shared service instance which uses real client object
    static let shared: PokemonAPIService = PokemonAPIService()

    init(apiClient: APIProtocol) {
        client = apiClient
    }

    private init() {
        let config: URLSessionConfiguration = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        let transport = URLSessionTransport(
            configuration: .init(session: .init(configuration: config))
        )
        self.client = Client(
            serverURL: try! Servers.Server1.url(),
            transport: transport
        )
    }

    func getPokemonList(limit: Int?, offset: Int?) async throws(NetworkError)
        -> Components.Schemas.PaginatedPokemonSummaryList
    {
        var response: Operations.PokemonList.Output = .undocumented(
            statusCode: 500,
            .init()
        )
        do {
            response = try await client.pokemonList(
                query: .init(limit: limit, offset: offset)
            )
        } catch {
            print("Error in pokemon list: \(error)")
            throw .unknownError(message: error.localizedDescription)
        }
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let pokemonList):
                return pokemonList
            }
        case .undocumented(let statusCode, _):
            throw NetworkError.undocumentedResponse(
                statusCode: statusCode,
                message: "Undocumented response: \(statusCode) for pokemonList"
            )
        }
    }

    func getPokemonDetails(id: String) async throws(NetworkError)
        -> Components.Schemas.PokemonDetail
    {
        var response: Operations.PokemonRetrieve.Output = .undocumented(
            statusCode: 500,
            .init()
        )
        do {
            response = try await client.pokemonRetrieve(path: .init(id: id))
        } catch {
            print("Error in pokemon detail: \(error)")
            throw .unknownError(message: error.localizedDescription)
        }
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let pokemonDetail):
                return pokemonDetail
            }
        case .undocumented(let statusCode, _):
            throw NetworkError.undocumentedResponse(
                statusCode: statusCode,
                message:
                    "Undocumented response: \(statusCode) for pokemonRetrieve"
            )
        }
    }

    func getTypeDetails(id: String) async throws(NetworkError)
        -> Components.Schemas.TypeDetail
    {
        var response: Operations.TypeRetrieve.Output = .undocumented(
            statusCode: 500,
            .init()
        )
        do {
            response = try await client.typeRetrieve(path: .init(id: id))
        } catch {
            print("Error in type detail: \(error)")
            throw .unknownError(message: error.localizedDescription)
        }
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let typeDetail):
                return typeDetail
            }
        case .undocumented(let statusCode, _):
            throw NetworkError.undocumentedResponse(
                statusCode: statusCode,
                message: "Undocumented response: \(statusCode) typeRetrieve"
            )
        }
    }

    func getSpeciesDetails(id: String) async throws(NetworkError)
        -> Components.Schemas.PokemonSpeciesDetail
    {
        var response: Operations.PokemonSpeciesRetrieve.Output = .undocumented(
            statusCode: 500,
            .init()
        )
        do {
            response = try await client.pokemonSpeciesRetrieve(
                path: .init(id: id)
            )
        } catch {
            print("Error in species detail: \(error)")
            throw .unknownError(message: error.localizedDescription)
        }
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let speciesDetail):
                return speciesDetail
            }
        case .undocumented(let statusCode, _):
            throw NetworkError.undocumentedResponse(
                statusCode: statusCode,
                message:
                    "Undocumented response: \(statusCode) pokemonSpeciesRetrieve"
            )
        }
    }

    func getAllTypes(limit: Int? = nil, offset: Int? = nil)
        async throws(NetworkError)
        -> Components.Schemas.PaginatedTypeSummaryList
    {
        let response: Operations.TypeList.Output
        do {
            response = try await client.typeList(
                query: .init(limit: limit, offset: offset)
            )
        } catch {
            print("Error in getAllTypes: \(error)")
            throw NetworkError.unknownError(message: error.localizedDescription)
        }

        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let typeList):
                return typeList
            }
        case .undocumented(let statusCode, _):
            throw NetworkError.undocumentedResponse(
                statusCode: statusCode,
                message: "Undocumented response: \(statusCode) for typeList"
            )
        }
    }
}

/// Custom type to include information about api errors
enum NetworkError: Error {
    case undocumentedResponse(statusCode: Int, message: String)
    case unknownError(message: String)
    case mockError(message: String)
}
