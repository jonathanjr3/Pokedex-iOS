//
//  UIModels.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 11/05/2025.
//

import SwiftUI

/// Data model for individual pokemons in list
struct UIPokemonListItem: Identifiable, Hashable {
    let id: Int
    let name: String
    var spriteURL: URL?
    var dominantColor: Color = .gray
    var types: [UITypeInfo] = []

    init(pokemonSummary: Components.Schemas.PokemonSummary) {
        self.id = extractID(from: pokemonSummary.url) ?? 0
        self.name = pokemonSummary.name.capitalized
        if let id = extractID(from: pokemonSummary.url) {
            self.spriteURL = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png")
        } else {
            self.spriteURL = nil
        }
    }

    static func example() -> UIPokemonListItem {
        let summary = Components.Schemas.PokemonSummary(name: "Pikachu", url: "https://pokeapi.co/api/v2/pokemon/25/")
        return UIPokemonListItem(pokemonSummary: summary)
    }
}

struct UITypeInfo: Identifiable, Hashable {
    let id = UUID()
    var typeBadgeURL: URL?
}

/// Data model for pokemon details
struct UIPokemonDetail: Identifiable {
    let id: Int
    let name: String
    var spriteURL: URL?
    var description: String = ""
    var types: [UITypeInfo] = []
    let height: Double // in decimetres, convert to meters (height / 10.0)
    let weight: Double // in hectograms, convert to kilograms (weight / 10.0)
    var genderRate: Int? // femaleChance = genderRate / 8. -1 for genderless.
    var abilities: [UIAbility] = []
    var stats: [UIStat] = []
    var typeDefenses: UITypeDefenses?
    var dominantColor: Color = .gray // For theming

    init(id: Int, name: String, spriteURL: URL? = nil, height: Int?, weight: Int?) {
        self.id = id
        self.name = name.capitalized
        self.spriteURL = spriteURL ?? URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png")
        self.height = Double(height ?? 0) / 10.0 // Convert to meters
        self.weight = Double(weight ?? 0) / 10.0 // Convert to kg
    }
}

struct UIAbility: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let isHidden: Bool
    var effectDescription: String?
}

struct UIStat: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let baseStat: Int
    let effort: Int

    var shortName: String {
        switch name.lowercased() {
        case "hp": return "HP"
        case "attack": return "ATK"
        case "defense": return "DEF"
        case "special-attack": return "SpA"
        case "special-defense": return "SpD"
        case "speed": return "SPD"
        default: return name.prefix(3).uppercased()
        }
    }
}

struct UITypeDefenses: Hashable {
    var weakAgainst: [UITypeInfo] = []
    var resistantTo: [UITypeInfo] = []
    var immuneTo: [UITypeInfo] = []
}
