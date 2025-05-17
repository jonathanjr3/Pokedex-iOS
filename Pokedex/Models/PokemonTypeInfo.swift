//
//  PokemonTypeInfo.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 15/05/2025.
//

import SwiftUI

struct PokemonTypeInfo: Identifiable, Hashable {
    let id = UUID()
    let typeBadgeURL: URL?
    let name: String

    // Placeholder colors
    var color: Color {
        switch name.lowercased() {
        case "normal": return Color.gray
        case "fire": return Color.orange
        case "water": return Color.blue
        case "electric": return Color.yellow
        case "grass": return Color.green
        case "ice": return Color.cyan
        case "fighting": return Color.red
        case "poison": return Color.purple
        case "ground": return Color.brown
        case "flying": return Color.indigo
        case "psychic": return Color.pink
        case "bug": return Color.mint
        case "rock": return Color(red: 0.6, green: 0.4, blue: 0.2)  // Brownish
        case "ghost": return Color(red: 0.4, green: 0.3, blue: 0.5)  // Dark Purple
        case "dragon": return Color(red: 0.2, green: 0.1, blue: 0.7)  // Dark Blue/Purple
        case "dark": return Color(red: 0.3, green: 0.3, blue: 0.3)  // Dark Gray
        case "steel": return Color(red: 0.7, green: 0.7, blue: 0.8)  // Light Gray/Silver
        case "fairy": return Color(red: 0.9, green: 0.6, blue: 0.9)  // Light Pink/Magenta
        default: return Color.gray
        }
    }
}
