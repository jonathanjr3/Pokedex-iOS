//
//  TypeDefensesView.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 18/05/2025.
//
import SwiftUI

struct TypeDefensesView: View {
    let defenses: PokemonTypeDefenses

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            DefenseCategoryView(
                title: "Weak Against (Takes 2x or more damage from):",
                types: defenses.weakAgainst
            )
            DefenseCategoryView(
                title: "Resistant To (Takes 0.5x or less damage from):",
                types: defenses.resistantTo
            )
            DefenseCategoryView(
                title: "Immune To (Takes 0x damage from):",
                types: defenses.immuneTo
            )
        }
    }
}
