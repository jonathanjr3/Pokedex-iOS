//
//  AbilityRow.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 18/05/2025.
//
import SwiftUI

struct AbilityRow: View {
    let ability: PokemonAbility

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(ability.name)
                    .fontWeight(.semibold)
                if ability.isHidden {
                    Text("(Hidden)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            /*if let description = ability.effectDescription {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }*/
        }
    }
}
