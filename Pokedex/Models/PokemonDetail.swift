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
    var description: String = "No description available"
    var types: [PokemonTypeInfo] = []
    let height: Double
    let weight: Double
    var genderProbabilities: GenderProbabilities?
    var abilities: [PokemonAbility] = []
    var stats: [PokemonStat] = []
    var typeDefenses: PokemonTypeDefenses?

    init(id: Int, name: String, height: Double?, weight: Double?) {
        self.id = id
        self.name = name.capitalized
        self.spriteURL = Utilities.getPokemonSpriteURL(forPokemonID: id)
        self.height = (height ?? 0) / 10.0 // Convert to meters
        self.weight = (weight ?? 0) / 10.0 // Convert to kg
    }
}

struct GenderProbabilities: Hashable {
    let femalePercentage: Double? // nil if genderless
    let malePercentage: Double?   // nil if genderless
}
