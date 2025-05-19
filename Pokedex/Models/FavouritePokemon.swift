//
//  FavoritePokemon.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 19/05/2025.
//

import SwiftData
import SwiftUI

@Model
final class FavouritePokemon {
    @Attribute(.unique) var id: Int
    var name: String
    var spriteURLString: String?
    var types: [String]
    var dominantColorHex: String?
    var height: Double  // meters
    var weight: Double  // kilograms
    var baseExperience: Int?
    var abilities: [String]?
    var stats: [FavoriteStat]?
    var flavorText: String?
    var dateAdded: Date

    init(
        id: Int,
        name: String,
        spriteURLString: String? = nil,
        types: [String] = [],
        dominantColorHex: String? = nil,
        height: Double = 0.0,
        weight: Double = 0.0,
        baseExperience: Int? = nil,
        abilities: [String]? = nil,
        stats: [FavoriteStat]? = nil,
        flavorText: String? = nil,
        dateAdded: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.spriteURLString = spriteURLString
        self.types = types
        self.dominantColorHex = dominantColorHex
        self.height = height
        self.weight = weight
        self.baseExperience = baseExperience
        self.abilities = abilities
        self.stats = stats
        self.flavorText = flavorText
        self.dateAdded = dateAdded
    }

    // Convenience for sprite URL
    var spriteURL: URL? {
        guard let urlString = spriteURLString else { return nil }
        return URL(string: urlString)
    }

    // Convenience for dominant color
    var dominantColor: Color {
        guard let hex = dominantColorHex else { return .gray }
        return Color(hex: hex) ?? .gray
    }
}

struct FavoriteStat: Codable, Hashable {
    let name: String
    let baseStat: Int
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
