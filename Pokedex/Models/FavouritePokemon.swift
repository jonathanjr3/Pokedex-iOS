//
//  FavouritePokemon.swift
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
    var types: String
    var dominantColorHex: String?
    var dateAdded: Date

    init(
        id: Int,
        name: String,
        spriteURLString: String? = nil,
        types: String = "",
        dominantColorHex: String? = nil,
        dateAdded: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.spriteURLString = spriteURLString
        self.types = types
        self.dominantColorHex = dominantColorHex
        self.dateAdded = dateAdded
    }

    // Convenience for sprite URL
    var spriteURL: URL? {
        guard let urlString = spriteURLString else { return nil }
        return URL(string: urlString)
    }

    // Convenience for dominant color
    var dominantColor: Color {
        guard let hex = dominantColorHex else { return .gray.opacity(0.1) }
        return Color(hex: hex)?.opacity(0.1) ?? .gray.opacity(0.1)
    }
    
    var pokemonTypes: [PokemonTypeInfo] {
        types.split(separator: ",").compactMap({ PokemonTypeInfo(name: String($0)) })
    }
}
