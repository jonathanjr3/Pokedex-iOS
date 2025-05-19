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
        if pokemonDetail.id == -1 || errorOccurred {
            errorMessage = nil
            errorOccurred = false
        }
        isLoading = true

        do {
            // Fetch Pokemon Details
            let apiPokemonDetail = try await apiService.getPokemonDetails(
                id: String(pokemonId)
            )

            // Assign to temporary local property to prevent updating UI
            var tempPokemonDetail = PokemonDetail(
                id: apiPokemonDetail.id,
                name: apiPokemonDetail.name.capitalized,
                height: apiPokemonDetail.height,
                weight: apiPokemonDetail.weight
            )

            // Fetch Pokemon Species Data (for description, gender, base color)
            let pokemonSpeciesDetail =
                try await apiService.getSpeciesDetails(
                    id: String(Utilities.extractID(from: apiPokemonDetail.species.url) ?? pokemonId)
                )

            // Dominant colour from species for gradient
            gradientColours.append(
                mapPokemonColorNameToSwiftUIColor(
                    pokemonSpeciesDetail.color.name
                )
            )
            // Description (Flavour Text)
            if let flavourTextEntry = pokemonSpeciesDetail.flavorTextEntries
                .first(where: { $0.language.name == "en" })
            {
                tempPokemonDetail.description =
                    flavourTextEntry.flavorText.replacingOccurrences(
                        of: "\n",
                        with: " "
                    ).replacingOccurrences(of: "\u{000C}", with: " ")
            }

            // Gender Probability
            if let genderRate = pokemonSpeciesDetail.genderRate {
                if genderRate == -1 {  // Genderless
                    tempPokemonDetail.genderProbabilities = GenderProbabilities(
                        femalePercentage: nil,
                        malePercentage: nil
                    )
                } else {
                    let femaleChance = Double(genderRate) / 8.0 * 100.0
                    tempPokemonDetail.genderProbabilities = GenderProbabilities(
                        femalePercentage: femaleChance,
                        malePercentage: 100.0 - femaleChance
                    )
                }
            }

            // Abilities
            var uiAbilities: [PokemonAbility] = []
            for apiAbilityContainer in apiPokemonDetail.abilities {
                let abilityName = apiAbilityContainer.ability.name.capitalized
                var effectDesc: String? = "Tap to load description."

                // TODO: Implement ability description
                // if let abilityUrl = apiAbility.url, let abilityId = Utilities.extractID(from: abilityUrl) {
                //    do {
                //        let detailedAbility = try await apiService.getAbilityDetail(id: String(abilityId)) // Requires getAbilityDetail in service
                //        effectDesc = detailedAbility.effect_entries?.first(where: { $0.language?.name == "en" })?.short_effect
                //    } catch {
                //        print("Failed to fetch detail for ability \(abilityName): \(error)")
                //    }
                // }

                uiAbilities.append(
                    PokemonAbility(
                        name: abilityName,
                        isHidden: apiAbilityContainer.isHidden,
                        effectDescription: effectDesc
                    )
                )
            }
            tempPokemonDetail.abilities = uiAbilities

            // Base Stats
            tempPokemonDetail.stats = apiPokemonDetail.stats.compactMap {
                apiStat in
                return PokemonStat(
                    name: apiStat.stat.name.capitalized,
                    baseStat: apiStat.baseStat,
                    effort: apiStat.effort
                )
            }

            // Types & Type Defenses
            var allTypeDetails: [Components.Schemas.TypeDetail] = []

            for apiTypeSlot in apiPokemonDetail.types {
                let typeId =
                    if Utilities.extractID(from: apiTypeSlot._type.url) == nil {
                        apiTypeSlot._type.name
                    } else {
                        String(
                            Utilities.extractID(from: apiTypeSlot._type.url)!
                        )
                    }

                let detailedType = try await apiService.getTypeDetails(
                    id: String(typeId)
                )
                allTypeDetails.append(detailedType)
            }
            tempPokemonDetail.typeDefenses = calculateTypeDefenses(
                from: allTypeDetails
            )

            tempPokemonDetail.types = apiPokemonDetail.types.compactMap {
                apiTypeSlot in
                let typeID = Utilities.extractID(from: apiTypeSlot._type.url)
                return PokemonTypeInfo(
                    typeId: typeID ?? -1,
                    name: apiTypeSlot._type.name
                )
            }
            tempPokemonDetail.types.forEach { typeInfo in
                gradientColours.append(typeInfo.color)
            }
            // Add app's accent color to gradient colours array to make it three rows
            // Animation on MeshGradient is jarring when number of rows (or) columns changes
            // This is done to make the animation on meshgradient less jarring
            if gradientColours.count < 3 {
                gradientColours.append(Color.accent)
            }
            await MainActor.run { [tempPokemonDetail] in
                withAnimation(.smooth) {
                    meshGradientPoints = Utilities.generateRandomCoordinates(
                        rows: gradientColours.count,
                        columns: 3
                    )
                    meshGradientColours = generateColourArray(
                        from: gradientColours
                    )
                    pokemonDetail = tempPokemonDetail
                }
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

    private func calculateTypeDefenses(
        from detailedTypes: [Components.Schemas.TypeDetail]
    ) -> PokemonTypeDefenses {
        var defenses = PokemonTypeDefenses()
        var damageMultipliers: [String: Double] = [:]

        for typeDetail in detailedTypes {  // For each of the Pokemon's types
            // No damage to
            typeDetail.damageRelations.noDamageTo.forEach { relatedType in
                damageMultipliers[relatedType.name, default: 1.0] *= 0
            }
            // Half damage to
            typeDetail.damageRelations.halfDamageTo.forEach {
                relatedType in
                damageMultipliers[relatedType.name, default: 1.0] *= 0.5
            }
            // Double damage to
            typeDetail.damageRelations.doubleDamageTo.forEach {
                relatedType in
                damageMultipliers[relatedType.name, default: 1.0] *= 2.0
            }
        }

        var finalMultipliers: [String: Double] = [:]

        var allInvolvedTypeNames = [String: Int]()
        detailedTypes.forEach { typeDetail in
            typeDetail.damageRelations.noDamageFrom.forEach {
                if let typeId = Utilities.extractID(from: $0.url) {
                    allInvolvedTypeNames[$0.name] = typeId
                }
            }
            typeDetail.damageRelations.halfDamageFrom.forEach {
                if let typeId = Utilities.extractID(from: $0.url) {
                    allInvolvedTypeNames[$0.name] = typeId
                }
            }
            typeDetail.damageRelations.doubleDamageFrom.forEach {
                if let typeId = Utilities.extractID(from: $0.url) {
                    allInvolvedTypeNames[$0.name] = typeId
                }
            }
        }
        // Add the pokemon's own types as well
        pokemonDetail.types.forEach {
            allInvolvedTypeNames[$0.name] = $0.typeId
        }

        for attackingTypeName in allInvolvedTypeNames
        where !attackingTypeName.key.isEmpty {
            var effectiveMultiplier = 1.0
            for pokemonTypeDetail in detailedTypes {  // Iterate over the Pokémon's actual types
                if pokemonTypeDetail.damageRelations.doubleDamageFrom
                    .contains(where: { $0.name == attackingTypeName.key })
                    == true
                {
                    effectiveMultiplier *= 2.0
                }
                if pokemonTypeDetail.damageRelations.halfDamageFrom
                    .contains(where: { $0.name == attackingTypeName.key })
                    == true
                {
                    effectiveMultiplier *= 0.5
                }
                if pokemonTypeDetail.damageRelations.noDamageFrom.contains(
                    where: { $0.name == attackingTypeName.key }) == true
                {
                    effectiveMultiplier *= 0.0
                }
            }
            finalMultipliers[attackingTypeName.key] = effectiveMultiplier
        }

        finalMultipliers.forEach { (typeName, multiplier) in
            if let typeId = allInvolvedTypeNames[typeName] {
                let typeInfo = PokemonTypeInfo(
                    typeId: typeId,
                    name: typeName
                )
                if multiplier >= 2.0 {
                    defenses.weakAgainst.append(typeInfo)
                } else if multiplier == 0.0 {
                    defenses.immuneTo.append(typeInfo)
                } else if multiplier <= 0.5 && multiplier > 0 {
                    defenses.resistantTo.append(typeInfo)
                }
            }
        }
        return defenses
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
