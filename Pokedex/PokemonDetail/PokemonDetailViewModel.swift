//
//  PokemonDetailViewModel.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 16/05/2025.
//
import SwiftUI

@Observable
final class PokemonDetailViewModel {
    private(set) var pokemonDetail: PokemonDetail = .init(
        id: -1,
        name: "Bulbasaur",
        height: 20,
        weight: 20
    )
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String? = nil
    private(set) var errorOccurred: Bool = false
    private(set) var meshGradientColours: [Color] = [
        .black, .black, .black,
        .blue, .blue, .blue,
        .green, .green, .green,
    ]
    private(set) var meshGradientPoints: [SIMD2<Float>] = [
        .init(0, 0), .init(0.5, 0), .init(1, 0),
        .init(0, 0.5), .init(0.9, 0.3), .init(1, 0.5),
        .init(0, 1), .init(0.5, 1), .init(1, 1),
    ]
    var meshGradientRows: Int {
        gradientColours.count
    }

    private let pokemonId: Int
    private let apiService: PokemonAPIService
    private var gradientColours: [Color] = []

    init(
        pokemonId: Int,
        apiService: PokemonAPIService = .shared
    ) {
        self.pokemonId = pokemonId
        self.apiService = apiService
    }

    func fetchPokemonDetails() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            let apiPokemonDetail = try await apiService.getPokemonDetails(
                id: String(pokemonId)
            )

            pokemonDetail = PokemonDetail(
                id: apiPokemonDetail.id,
                name: apiPokemonDetail.name.capitalized,
                spriteURL: Utilities.getPokemonSpriteURL(
                    forPokemonID: pokemonId
                ),
                height: apiPokemonDetail.height,
                weight: apiPokemonDetail.weight
            )

            // Fetch Pokemon color
            do {
                let pokemonSpeciesDetail =
                    try await apiService.getSpeciesDetails(
                        id: String(pokemonId)
                    )

                gradientColours.append(
                    mapPokemonColorNameToSwiftUIColor(
                        pokemonSpeciesDetail.color.name
                    )
                )
            } catch {
                print(
                    "Error occurred while retrieving pokemon species details in detail view model: \(error)"
                )
            }

            pokemonDetail.types = apiPokemonDetail.types.compactMap {
                apiTypeSlot in
                let typeID = Utilities.extractID(from: apiTypeSlot._type.url)
                return PokemonTypeInfo(
                    typeBadgeURL: typeID == nil
                        ? nil
                        : Utilities.getPokemonTypeSpriteURL(
                            forSpriteID: typeID!
                        ),
                    name: apiTypeSlot._type.name
                )
            }
            pokemonDetail.types.forEach { typeInfo in
                gradientColours.append(typeInfo.color)
            }
            await MainActor.run {
                meshGradientPoints = Utilities.generateRandomCoordinates(
                    rows: gradientColours.count,
                    columns: 3
                )
                meshGradientColours = generateColourArray(
                    from: gradientColours
                )
            }
        } catch {
            errorMessage =
                "Failed to load Pokémon details, try again later."
            errorOccurred = true
            print(
                "Error fetching Pokemon details for ID \(pokemonId): \(error)"
            )
        }
        await MainActor.run {
            isLoading = false
        }
    }

    // Helper to map color names from API to SwiftUI Color
    private func mapPokemonColorNameToSwiftUIColor(_ colorName: String) -> Color
    {
        switch colorName.lowercased() {
        case "black": return Color(.sRGB, red: 0.2, green: 0.2, blue: 0.2)
        case "blue": return .blue
        case "brown": return .brown
        case "gray": return .gray
        case "green": return .green
        case "pink": return .pink
        case "purple": return .purple
        case "red": return .red
        case "white": return Color(.sRGB, red: 0.95, green: 0.95, blue: 0.95)
        case "yellow": return .yellow
        default: return .gray
        }
    }

    private func generateColourArray(from inputColors: [Color]) -> [Color] {
        // Using flatMap to repeat each color 3 times efficiently
        return inputColors.flatMap { Array(repeating: $0, count: 3) }
    }
}
