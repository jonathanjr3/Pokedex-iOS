//
//  PokemonListItem.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 15/05/2025.
//

import SwiftUI

/// Data model for individual pokemons in list
struct PokemonListItem: Identifiable, Hashable {
    let id: Int
    let name: String
    var spriteURL: URL?
    var dominantColor: Color = .gray
    var types: [PokemonTypeInfo] = []

    init(pokemonSummary: Components.Schemas.PokemonSummary) {
        self.id = extractID(from: pokemonSummary.url) ?? 0
        self.name = pokemonSummary.name.capitalized
        if let id = extractID(from: pokemonSummary.url) {
            self.spriteURL = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png")
        } else {
            self.spriteURL = nil
        }
    }

    static func example() -> PokemonListItem {
        let summary = Components.Schemas.PokemonSummary(name: "Pikachu", url: "https://pokeapi.co/api/v2/pokemon/25/")
        return PokemonListItem(pokemonSummary: summary)
    }
}

func getPokemonSpriteURL(ID: Int) -> URL? {
    URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(ID).png")
}
