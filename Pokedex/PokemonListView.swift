//
//  PokemonListView.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 10/05/2025.
//

import SwiftUI
import OpenAPIURLSession

struct PokemonListView: View {
    @State private var pokemonList: [Components.Schemas.PokemonSummary] = []
    
    var body: some View {
        NavigationStack {
            if pokemonList.isEmpty {
                Text("No pokemons found")
            } else {
                List(pokemonList) { pokemon in
                    NavigationLink(value: pokemon.name) {
                        Text(pokemon.name)
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .padding([.leading, .vertical])
                    }
                }
                .navigationDestination(for: String.self) { pokemon in
                    Text("Pokemon selected: \(pokemon)")
                }
                .navigationTitle("Pokedex")
                .navigationBarTitleDisplayMode(.automatic)
            }
        }
        .task {
            do {
                pokemonList = try await getPokemonList()
            } catch {
                print("Error while calling api: \(error.localizedDescription)")
            }
        }
    }
    
    private func getPokemonList() async throws -> [Components.Schemas.PokemonSummary] {
        let client = Client(serverURL: try Servers.Server1.url(), transport: URLSessionTransport())
        let response = try await client.pokemonList(.init(query: .init(limit: 60, offset: nil)))
        switch response {
        case .ok(let okResponse):
            print(okResponse)
            switch okResponse.body {
            case .json(let pokemonList):
                return pokemonList.results ?? []
            }
        case .undocumented(statusCode: let statusCode, _):
            print("Unknown response, status code: \(statusCode)")
            return []
        }
    }
}

extension Components.Schemas.PokemonSummary: Identifiable {
    var id: UUID {
        UUID()
    }
}

#Preview {
    PokemonListView()
}
