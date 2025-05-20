//
//  MockPokemonAPIClient.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 15/05/2025.
//
import OpenAPIRuntime

@MainActor
final class MockPokemonAPIClient: APIProtocol {
    var shouldThrowErrorOnPokemonList: Bool = false
    var pokemonListCallCount: Int = 0
    var shouldThrowErrorOnTypeList: Bool = false
    var pokemonForElectricType: [Components.Schemas.PokemonSummary]? = nil
    var shouldThrowErrorOnTypeRetrieve: Bool = false
    var shouldThrowErrorOnPokemonRetrieve: Bool = false
    var shouldThrowErrorOnSpeciesRetrieve: Bool = false

    func typeList(_ input: Operations.TypeList.Input) async throws
        -> Operations.TypeList.Output
    {
        if shouldThrowErrorOnTypeList {
            throw NetworkError.mockError(message: "Simulated typeList error")
        }
        let mockTypes: [Components.Schemas.TypeSummary] = [
            .init(name: "normal", url: "/api/v2/type/1/"),
            .init(name: "fire", url: "/api/v2/type/10/"),
            .init(name: "water", url: "/api/v2/type/11/"),
            .init(name: "grass", url: "/api/v2/type/12/"),
            .init(name: "electric", url: "/api/v2/type/13/"),
        ]
        return .ok(
            .init(
                body: .json(.init(count: mockTypes.count, results: mockTypes))
            )
        )
    }

    func abilityRetrieve(_ input: Operations.AbilityRetrieve.Input) async throws
        -> Operations.AbilityRetrieve.Output
    {
        throw NetworkError.unknownError(
            message: "Mock not implemented for ability retrieve"
        )
    }

    func typeRetrieve(_ input: Operations.TypeRetrieve.Input) async throws
        -> Operations.TypeRetrieve.Output
    {
        if shouldThrowErrorOnTypeRetrieve {
            throw NetworkError.mockError(
                message: "Simulated typeRetrieve error"
            )
        }
        var mockTypeDetail: Components.Schemas.TypeDetail
        let damageRelations = Components.Schemas.TypeDetail
            .DamageRelationsPayload(
                noDamageTo: [],
                halfDamageTo: [
                    .init(name: "grass", url: ""),
                    .init(name: "electric", url: ""),
                    .init(name: "dragon", url: ""),
                ],
                doubleDamageTo: [],
                noDamageFrom: [],
                halfDamageFrom: [
                    .init(name: "flying", url: ""),
                    .init(name: "steel", url: ""),
                    .init(name: "electric", url: ""),
                ],
                doubleDamageFrom: [.init(name: "ground", url: "")]
            )
        // Mock sprites (ensure paths match actual API structure for name_icon)
        let typeSprites = Components.Schemas.TypeDetail.SpritesPayload()
        //https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/types/generation-ix/scarlet-violet/13.png, generation-ix
        mockTypeDetail = .init(
            id: 13,
            name: "electric",
            damageRelations: damageRelations,
            pastDamageRelations: .init(),
            gameIndices: [],
            generation: .init(name: "", url: ""),
            moveDamageClass: .init(name: "", url: ""),
            names: [],
            pokemon: .init(),
            moves: [],
            sprites: typeSprites
        )
        return .ok(.init(body: .json(mockTypeDetail)))
    }

    func pokemonSpeciesRetrieve(
        _ input: Operations.PokemonSpeciesRetrieve.Input
    ) async throws -> Operations.PokemonSpeciesRetrieve.Output {
        if shouldThrowErrorOnSpeciesRetrieve {
            throw NetworkError.mockError(
                message: "Simulated pokemonSpeciesRetrieve error"
            )
        }
        let id = Int(input.path.id) ?? 1
        let flavorText = Components.Schemas.PokemonSpeciesFlavorText(
            flavorText:
                "A strange seed was planted on its back at birth. The plant sprouts and grows with this Pokémon.",
            language: .init(name: "en", url: ""),
            version: .init(name: "red", url: "")
        )
        let speciesColor = Components.Schemas.PokemonColorSummary(
            name: id == 25 ? "yellow" : "green",
            url: ""
        )
        let speciesDetail = Components.Schemas.PokemonSpeciesDetail(
            id: id,
            name: id == 25 ? "pikachu" : "bulbasaur",
            order: nil,
            genderRate: id == 25 ? 4 : 1,
            captureRate: 45,
            baseHappiness: nil,
            isBaby: nil,
            isLegendary: nil,
            isMythical: nil,
            hatchCounter: nil,
            hasGenderDifferences: nil,
            formsSwitchable: nil,
            growthRate: .init(name: "", url: ""),
            pokedexNumbers: [],
            eggGroups: .init(),
            color: speciesColor,
            shape: .init(name: "", url: ""),
            evolvesFromSpecies: .none,
            evolutionChain: .init(url: ""),
            habitat: .init(name: "", url: ""),
            generation: .init(name: "", url: ""),
            names: .init(),
            palParkEncounters: .init(),
            formDescriptions: [],
            flavorTextEntries: [flavorText],
            genera: [],
            varieties: []
        )
        return .ok(.init(body: .json(speciesDetail)))
    }

    func pokemonRetrieve(_ input: Operations.PokemonRetrieve.Input) async throws
        -> Operations.PokemonRetrieve.Output
    {
        if shouldThrowErrorOnPokemonRetrieve {
            throw NetworkError.mockError(
                message: "Simulated pokemonRetrieve error"
            )
        }
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
                        abilities: [.init(ability: .init(name: "", url: ""), isHidden: false, slot: 1)],
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
                        stats: [.init(baseStat: 2, effort: 2, stat: .init(name: "", url: ""))],
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
        pokemonListCallCount += 1
        if shouldThrowErrorOnPokemonList {
            throw NetworkError.mockError(message: "Simulated pokemonList error")
        }
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
