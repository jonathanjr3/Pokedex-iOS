//
//  PokemonTypeInfo.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 15/05/2025.
//

import SwiftUI

struct PokemonTypeInfo: Identifiable, Hashable {
    let id = UUID()
    let typeId: Int
    let name: String
    let iconURL: URL?
    
    var color: Color {
        PokemonTypeInfo.color(for: name)
    }
    
    var typeSystemImage: String {
        switch name.lowercased() {
        case "normal": return "circle"
        case "fire": return "flame.fill"
        case "water": return "drop.fill"
        case "electric": return "bolt.fill"
        case "grass": return "leaf.fill"
        case "ice": return "snowflake"
        case "fighting": return "hand.raised.brakesignal"
        case "poison": return "hazardsign.fill"
        case "ground": return "mountain.2.fill"
        case "flying": return "bird.fill"
        case "psychic": return "tropicalstorm"
        case "bug": return "ladybug.fill"
        case "rock": return "mountain.2.fill"
        case "ghost": return "eyeglasses.slash"
        case "dragon": return "lizard.fill"
        case "dark": return "moon.fill"
        case "steel": return "shield.pattern.checkered"
        case "fairy": return "wand.and.sparkles"
        default: return "questionmark.app"
        }
    }
    
    init(typeId: Int, name: String) {
        self.typeId = typeId
        self.name = name
        self.iconURL = Utilities.getPokemonTypeSpriteURL(forSpriteID: typeId)
    }

    static func color(for typeName: String) -> Color {
        switch typeName.lowercased() {
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
        case "rock": return Color(red: 0.6, green: 0.4, blue: 0.2)
        case "ghost": return Color(red: 0.4, green: 0.3, blue: 0.5)
        case "dragon": return Color(red: 0.2, green: 0.1, blue: 0.7)
        case "dark": return Color(red: 0.3, green: 0.3, blue: 0.3)
        case "steel": return Color(red: 0.7, green: 0.7, blue: 0.8)
        case "fairy": return Color(red: 0.9, green: 0.6, blue: 0.9)
        default: return Color.gray
        }
    }
}
