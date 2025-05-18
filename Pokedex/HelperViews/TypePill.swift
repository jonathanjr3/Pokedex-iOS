//
//  TypePill.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 18/05/2025.
//
import SwiftUI
import Shimmer

struct TypePill: View {
    let typeInfo: PokemonTypeInfo

    var body: some View {
        Label(typeInfo.name.capitalized, systemImage: typeInfo.typeSystemImage)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(typeInfo.color.opacity(0.8))
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}

struct TypePillPlaceholder: View {
    var body: some View {
        Text("Type")
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.gray.opacity(0.3))
            .foregroundColor(.secondary)
            .clipShape(Capsule())
            .redacted(reason: .placeholder)
            .shimmering()
    }
}
