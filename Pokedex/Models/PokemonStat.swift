//
//  PokemonStat.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 15/05/2025.
//

import SwiftUI

struct PokemonStat: Identifiable, Hashable {
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

    // Color for stat bar (example, adjust as you like)
    var statColor: Color {
        switch name.lowercased() {
        case "hp": return .green
        case "attack": return .red
        case "defense": return .blue
        case "special-attack": return .purple
        case "special-defense": return .cyan
        case "speed": return .yellow
        default: return .gray
        }
    }
}
