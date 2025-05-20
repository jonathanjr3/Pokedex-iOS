import SwiftData
//
//  PokemonDetailViewModel.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 16/05/2025.
//
import SwiftUI

@Observable
final class PokemonDetailViewModel {
    // MARK: - Published State
    private(set) var pokemonDetail: PokemonDetail = .init(
        id: -1,
        name: "Bulbasaur",
        height: 20,
        weight: 20
    )
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String? = nil
    private(set) var errorOccurred: Bool = false
    private(set) var isFavourite: Bool = false

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

    // MARK: - Private State
    private let pokemonId: Int
    private let apiService: PokemonAPIService
    private var sourceGradientColours: [Color] = []
    private var modelContext: ModelContext?

    init(
        pokemonId: Int,
        modelContext: ModelContext? = nil,
        pokemonTypes: [PokemonTypeInfo] = [],
        apiService: PokemonAPIService = .shared
    ) {
        self.pokemonId = pokemonId
        self.modelContext = modelContext
        self.apiService = apiService
        pokemonDetail.types = pokemonTypes

        if modelContext != nil {
            Task { @MainActor in
                checkIfFavourite()
            }
        }
    }

    // MARK: - SwiftData Operations
    @MainActor
    func setModelContext(_ context: ModelContext) {
        if self.modelContext == nil {
            self.modelContext = context
            checkIfFavourite()
        }
    }

    @MainActor
    private func checkIfFavourite() {
        guard let context = modelContext else { return }
        let currentPokemonID = pokemonId
        let fetchDescriptor = FetchDescriptor<FavouritePokemon>(
            predicate: #Predicate { $0.id == currentPokemonID }
        )
        do {
            let favourites = try context.fetch(fetchDescriptor)
            isFavourite = !favourites.isEmpty
        } catch {
            print("Failed to fetch favourite status: \(error)")
            isFavourite = false
        }
    }

    @MainActor
    func toggleFavourite() {
        guard let context = modelContext else {
            print("Model context not available.")
            return
        }

        if isFavourite {
            // Remove from favourites
            let currentPokemonID = pokemonId
            let fetchDescriptor = FetchDescriptor<FavouritePokemon>(
                predicate: #Predicate { $0.id == currentPokemonID }
            )
            do {
                if let favouriteToRemove = try context.fetch(fetchDescriptor)
                    .first
                {
                    context.delete(favouriteToRemove)
                    try context.save()
                    isFavourite = false
                    print("Removed \(pokemonDetail.name) from favourites.")
                }
            } catch {
                print("Failed to remove favourite: \(error)")
            }
        } else {
            // Add to favourites
            guard pokemonDetail.id != -1, !pokemonDetail.name.isEmpty else {  // Ensure details are somewhat loaded
                print(
                    "Cannot favourite: Pokémon details not sufficiently loaded."
                )
                return
            }

            let newFavourite = FavouritePokemon(
                id: pokemonDetail.id,
                name: pokemonDetail.name,
                spriteURLString: pokemonDetail.spriteURL?.absoluteString,
                types: pokemonDetail.types.compactMap { $0.name.lowercased() }
                    .joined(separator: ","),
                dominantColorHex: sourceGradientColours.first?.toHex(),
                dateAdded: Date()
            )

            context.insert(newFavourite)
            do {
                try context.save()
                isFavourite = true
                print("Added \(pokemonDetail.name) to favourites.")
            } catch {
                print("Failed to save favourite: \(error)")
            }
        }
    }

    // MARK: - Data Fetching
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

            // Fetch Pokemon Species Data (for description, gender, base color)
            let pokemonSpeciesDetail =
                try await apiService.getSpeciesDetails(
                    id: String(
                        Utilities.extractID(from: apiPokemonDetail.species.url)
                            ?? pokemonId
                    )
                )

            // Fetch All Type Details in Parallel
            let allTypeDetailsApi = try await fetchAllTypeDetails(pokemonDetails: apiPokemonDetail)

            // Process and update state
            processFetchedData(
                apiDetail: apiPokemonDetail,
                speciesDetail: pokemonSpeciesDetail,
                allTypeDetailsApi: allTypeDetailsApi
            )
            await MainActor.run {
                checkIfFavourite()
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

    /// Helper to process all fetched data and update the pokemonDetail model and gradient.
    private func processFetchedData(
        apiDetail: Components.Schemas.PokemonDetail,
        speciesDetail: Components.Schemas.PokemonSpeciesDetail,
        allTypeDetailsApi: [Components.Schemas.TypeDetail]
    ) {
        // Create a new PokemonDetail instance
        var newDetail = PokemonDetail(
            id: apiDetail.id,
            name: apiDetail.name.capitalized,
            height: Double(apiDetail.height ?? 0) / 10.0,  // Convert to meters
            weight: Double(apiDetail.weight ?? 0) / 10.0  // Convert to kg
        )
        newDetail.spriteURL = Utilities.getPokemonSpriteURL(
            forPokemonID: apiDetail.id
        )

        // Process Species Info
        if let flavorTextEntry = speciesDetail.flavorTextEntries.first(where: {
            $0.language.name == "en"
        }) {
            newDetail.description = flavorTextEntry.flavorText
                .replacingOccurrences(of: "\n", with: " ")
                .replacingOccurrences(of: "\u{000C}", with: " ")
        }
        if let genderRate = speciesDetail.genderRate {
            newDetail.genderProbabilities = calculateGenderProbabilities(
                genderRate: genderRate
            )
        }

        // Process Abilities
        newDetail.abilities = apiDetail.abilities.map { apiAbilityContainer in
            PokemonAbility(
                name: apiAbilityContainer.ability.name.capitalized,
                isHidden: apiAbilityContainer.isHidden,
                effectDescription: "Tap to load description."  // TODO: Future enhancement
            )
        }

        // Process Base Stats
        newDetail.stats = apiDetail.stats.compactMap { apiStat in
            PokemonStat(
                name: apiStat.stat.name.capitalized,
                baseStat: apiStat.baseStat,
                effort: apiStat.effort
            )
        }

        // Process Types and Update Source Gradient Colors
        var currentSourceGradientColors: [Color] = []
        currentSourceGradientColors.append(
            mapPokemonColorNameToSwiftUIColor(speciesDetail.color.name)
        )

        newDetail.types = apiDetail.types.compactMap { apiTypeSlot in
            let typeID = Utilities.extractID(from: apiTypeSlot._type.url) ?? -1
            let typeInfo = PokemonTypeInfo(
                name: apiTypeSlot._type.name,
                typeId: typeID
            )
            currentSourceGradientColors.append(typeInfo.color)  // Add type color to gradient
            return typeInfo
        }

        // Ensure at least 3 base colors for the mesh gradient (for 3 rows)
        // Add app's accent color to gradient colours array to make it three rows
        // Animation on MeshGradient is jarring when number of rows (or) columns changes
        // This is done to make the animation on meshgradient less jarring
        while currentSourceGradientColors.count < 3
            && currentSourceGradientColors.count > 0
        {
            // If 1 color, add accent and blue. If 2, add accent.
            if currentSourceGradientColors.count == 1 {
                currentSourceGradientColors.append(Color.accentColor)
            }
            currentSourceGradientColors.append(Color.blue.opacity(0.5))  // Use a less prominent color
        }
        if currentSourceGradientColors.isEmpty {  // Fallback if no colors found
            currentSourceGradientColors = [.blue, .green, .accentColor]
        }

        sourceGradientColours = currentSourceGradientColors

        // Process Type Defenses
        newDetail.typeDefenses = calculateTypeDefenses(from: allTypeDetailsApi)

        // Update the main pokemonDetail and gradient with animation
        Task { @MainActor in
            withAnimation(.smooth(duration: 0.5)) {
                pokemonDetail = newDetail
                meshGradientPoints = Utilities.generateRandomCoordinates(
                    rows: 3,
                    columns: 3
                )
                meshGradientColours = generateColourArray(from: sourceGradientColours)
            }
        }
    }

    private func calculateGenderProbabilities(genderRate: Int)
        -> GenderProbabilities?
    {
        if genderRate == -1 {
            return GenderProbabilities(
                femalePercentage: nil,
                malePercentage: nil
            )
        }
        let femaleChance = Double(genderRate) / 8.0 * 100.0
        return GenderProbabilities(
            femalePercentage: femaleChance,
            malePercentage: 100.0 - femaleChance
        )
    }

    /// Fetch all pokemon type details from api in parallel
    /// - Parameter pokemonDetails: Pokemon details
    /// - Returns: An array of type details
    private func fetchAllTypeDetails(
        pokemonDetails: Components.Schemas.PokemonDetail
    ) async throws -> [Components.Schemas.TypeDetail] {
        var allTypeDetails: [Components.Schemas.TypeDetail] = []
        allTypeDetails.reserveCapacity(pokemonDetails.types.count)

        try await withThrowingTaskGroup(of: Components.Schemas.TypeDetail.self)
        { group in
            for apiTypeSlot in pokemonDetails.types {
                group.addTask {
                    let typeIdString: String
                    if let extractedId = Utilities.extractID(
                        from: apiTypeSlot._type.url
                    ) {
                        typeIdString = String(extractedId)
                    } else {
                        typeIdString = apiTypeSlot._type.name  // Fallback to name if ID extraction fails
                    }

                    let detailedType = try await self.apiService.getTypeDetails(
                        id: typeIdString
                    )
                    return detailedType
                }
            }

            for try await detailedType in group {
                allTypeDetails.append(detailedType)
            }
        }
        return allTypeDetails
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
                    name: typeName,
                    typeId: typeId
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
