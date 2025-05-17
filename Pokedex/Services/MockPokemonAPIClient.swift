//
//  MockPokemonAPIClient.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 15/05/2025.
//
import OpenAPIRuntime

struct MockPokemonAPIClient: APIProtocol {
    func typeRetrieve(_ input: Operations.TypeRetrieve.Input) async throws
        -> Operations.TypeRetrieve.Output
    {
        throw NetworkError.unknownError(message: "Mock not implemented")
    }

    func pokemonSpeciesRetrieve(
        _ input: Operations.PokemonSpeciesRetrieve.Input
    ) async throws -> Operations.PokemonSpeciesRetrieve.Output {
        throw NetworkError.unknownError(message: "Mock not implemented")
    }

    func pokemonRetrieve(_ input: Operations.PokemonRetrieve.Input) async throws
        -> Operations.PokemonRetrieve.Output
    {
        let pokemonId = Int(input.path.id) ?? 1
        var typesArray: [Components.Schemas.PokemonDetail.TypesPayloadPayload] =
            [
                .init(
                    slot: 1,
                    _type: .init(
                        name: (pokemonId == 25 ? "electric" : "grass"),
                        url: ""
                    )
                )
            ]
        if pokemonId == 6 {
            typesArray.append(
                .init(slot: 2, _type: .init(name: "flying", url: ""))
            )
        }
        return .ok(
            .init(
                body: .json(
                    .init(
                        id: pokemonId,
                        name: pokemonId == 25
                            ? "Pikachu"
                            : (pokemonId == 1 ? "Bulbasaur" : "Charmander"),
                        baseExperience: pokemonId == 25 ? 112 : 64,
                        height: pokemonId == 25 ? 4 : (pokemonId == 1 ? 7 : 6),  // decimetres
                        isDefault: true,
                        order: pokemonId == 25 ? 35 : pokemonId,
                        weight: pokemonId == 25
                            ? 60 : (pokemonId == 1 ? 69 : 85),  // hectograms
                        abilities: [],
                        pastAbilities: [],
                        forms: [],
                        gameIndices: [],
                        heldItems: [],
                        locationAreaEncounters: "",
                        moves: [],
                        species: .init(name: "pikachu", url: ""),
                        sprites: .init(
                            frontDefault:
                                "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemonId).png"
                        ),
                        cries: .init(latest: "", legacy: ""),
                        stats: [],
                        types: typesArray,
                        pastTypes: .init()
                    )
                )
            )
        )
    }

    func pokemonList(_ input: Operations.PokemonList.Input) async throws
        -> Operations.PokemonList.Output
    {
        let bulbasaur = Components.Schemas.PokemonSummary(
            name: "Bulbasaur",
            url: "https://pokeapi.co/api/v2/pokemon/1/"
        )
        let charmander = Components.Schemas.PokemonSummary(
            name: "Charmander",
            url: "https://pokeapi.co/api/v2/pokemon/4/"
        )
        let squirtle = Components.Schemas.PokemonSummary(
            name: "Squirtle",
            url: "https://pokeapi.co/api/v2/pokemon/7/"
        )
        return .ok(
            Operations.PokemonList.Output.Ok(
                body: .json(
                    .init(
                        count: 3,
                        next: nil,
                        previous: nil,
                        results: [bulbasaur, charmander, squirtle]
                    )
                )
            )
        )
    }
}
