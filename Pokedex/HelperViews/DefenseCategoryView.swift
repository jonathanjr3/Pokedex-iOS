//
//  DefenseCategoryView.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 18/05/2025.
//
import Flow
import SwiftUI

struct DefenseCategoryView: View {
    let title: String
    let types: [PokemonTypeInfo]

    var body: some View {
        if !types.isEmpty {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                HFlow {
                    ForEach(types) { type in
                        TypePill(typeInfo: type)
                    }
                }
            }
        }
    }
}
