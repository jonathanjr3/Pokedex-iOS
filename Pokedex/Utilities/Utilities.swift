//
//  Utilities.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 16/05/2025.
//
import Foundation

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
}
