//
//  PokemonDetail.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 15/05/2025.
//


import SwiftUI

/// Data model for pokemon details
struct PokemonDetail: Identifiable {
    let id: Int
    let name: String
    var spriteURL: URL?
    var description: String = ""
    var types: [PokemonTypeInfo] = []
    let height: Double // in decimetres, convert to meters (height / 10.0)
    let weight: Double // in hectograms, convert to kilograms (weight / 10.0)
    var genderRate: Int? // femaleChance = genderRate / 8. -1 for genderless.
    var abilities: [PokemonAbility] = []
    var stats: [PokemonStat] = []
    var typeDefenses: PokemonTypeDefenses?

    init(id: Int, name: String, spriteURL: URL? = nil, height: Int?, weight: Int?) {
        self.id = id
        self.name = name.capitalized
        self.spriteURL = spriteURL ?? Utilities.getPokemonSpriteURL(forPokemonID: id)
        self.height = Double(height ?? 0) / 10.0 // Convert to meters
        self.weight = Double(weight ?? 0) / 10.0 // Convert to kg
    }
}
