//
//  Utilities.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 16/05/2025.
//
import Foundation
import SwiftUICore

struct Utilities {
    /// Returns official artwork URL for given pokemon ID
    /// - Parameter ID: Pokemon ID
    /// - Returns: Official artwork URL for given pokemon ID
    static func getPokemonSpriteURL(forPokemonID ID: Int) -> URL? {
        URL(
            string:
                "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(ID).png"
        )
    }

    /// Returns generation ix pokemon type sprite URL for given pokemon type ID (NOT pokemon ID)
    /// - Parameter ID: Pokemon Type ID
    /// - Returns: Generation IX Scarlet Violet variant of pokemon type sprite
    static func getPokemonTypeSpriteURL(forSpriteID ID: Int) -> URL? {
        URL(
            string:
                "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/types/generation-ix/scarlet-violet/\(ID).png"
        )
    }

    /// Helper to extract ID from Pokemon URL, e.g., "https://pokeapi.co/api/v2/pokemon/1/" -> 1
    /// - Parameter urlString: The url in string type to extract the ID from
    /// - Returns: ID extracted from the URL in Int
    static func extractID(from urlString: String) -> Int? {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return nil
        }

        let relevantComponents = url.pathComponents.filter {
            !$0.isEmpty && $0 != "/"
        }

        guard let lastComponent = relevantComponents.last else {
            print("No ID found in URL")
            return nil
        }

        return Int(lastComponent)
    }

    /// Generates random x,y coordinates across n x m dimensions
    /// - Parameters:
    ///   - n: Number of rows to generate coordinates for (Points in y-axis)
    ///   - m: Number of columns to generate coordinates for (Points in x-axis)
    /// - Returns: An array of coordinates
    static func generateRandomCoordinates(rows n: Int, columns m: Int)
        -> [SIMD2<Float>]
    {
        guard n > 0 && m > 0 else {
            print("Error: Number of rows and columns must be positive")
            return []
        }

        var coordinates = [SIMD2<Float>]()

        // Generate coordinates for each position in the grid
        for i in 0..<n {
            for j in 0..<m {
                // Determine x coordinate: 0.0 for first column, 1.0 for last column, random otherwise
                let x: Float =
                    j == 0
                    ? 0.0 : (j == m - 1 ? 1.0 : Float.random(in: 0.0...1.0))

                // Determine y coordinate: 0.0 for first row, 1.0 for last row, random otherwise
                let y: Float =
                    i == 0
                    ? 0.0 : (i == n - 1 ? 1.0 : Float.random(in: 0.0...1.0))

                coordinates.append(SIMD2<Float>(x, y))
            }
        }

        return coordinates
    }

    static func getTypeColor(forTypeName name: String) -> Color {
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
        case "rock": return Color(red: 0.6, green: 0.4, blue: 0.2)
        case "ghost": return Color(red: 0.4, green: 0.3, blue: 0.5)
        case "dragon": return Color(red: 0.2, green: 0.1, blue: 0.7)
        case "dark": return Color(red: 0.3, green: 0.3, blue: 0.3)
        case "steel": return Color(red: 0.7, green: 0.7, blue: 0.8)
        case "fairy": return Color(red: 0.9, green: 0.6, blue: 0.9)
        case "shadow": return Color.black.opacity(0.6)
        case "stellar":
            return Color.red.mix(with: Color.blue, by: 0.5).mix(
                with: .green,
                by: 0.5
            )
        default: return Color.gray
        }
    }

    static func getTypeSystemImageString(forName name: String) -> String {
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
        case "shadow": return "eye.slash.fill"
        case "stellar": return "fireworks"
        default: return "questionmark.app"
        }
    }
}
