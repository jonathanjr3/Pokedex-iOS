//
//  PokemonAbility.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 15/05/2025.
//


import SwiftUI

struct PokemonAbility: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let isHidden: Bool
    var effectDescription: String? = "No effect description available"
}
