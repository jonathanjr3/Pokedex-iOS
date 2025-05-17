//
//  PokemonDetailViewModel.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 16/05/2025.
//

import Combine
import SwiftUI

@Observable
final class PokemonDetailViewModel {
    var pokemonDetail: PokemonDetail?
    var isLoading: Bool = false
    var errorMessage: String? = nil

    private let pokemonId: Int
    private let apiService: PokemonAPIService

    init(
        pokemonId: Int,
        apiService: PokemonAPIService = PokemonAPIService()
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
                pokemonDetail?.dominantColor =
                    mapPokemonColorNameToSwiftUIColor(
                        pokemonSpeciesDetail.color.name
                    )
            } catch {
                print(
                    "Error occurred while retrieving pokemon species details in detail view model: \(error)"
                )
            }

            pokemonDetail?.types = apiPokemonDetail.types.compactMap {
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

        } catch {
            errorMessage =
                "Failed to load Pokémon details, try again later."
            print(
                "Error fetching Pokemon details for ID \(pokemonId): \(error)"
            )
        }
        isLoading = false
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
}
