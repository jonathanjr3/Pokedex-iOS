//
//  PokemonTypeDefenses.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 15/05/2025.
//


import SwiftUI

struct PokemonTypeDefenses: Hashable {
    var weakAgainst: [PokemonTypeInfo] = []
    var resistantTo: [PokemonTypeInfo] = []
    var immuneTo: [PokemonTypeInfo] = []
}
