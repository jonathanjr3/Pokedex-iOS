//
//  PokemonListRow.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 18/05/2025.
//
import SwiftUI
import Shimmer
import Flow

struct PokemonListRow: View {
    let pokemonItem: PokemonListItem
    let animation: Namespace.ID

    var body: some View {
        HStack {
            AsyncImage(url: pokemonItem.spriteURL) { phase in
                switch phase {
                case .empty:
                    Image(systemName: "diamond.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .padding(10)
                        .shimmering()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                case .failure:
                    Image(systemName: "questionmark.diamond")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .padding(10)
                        .foregroundStyle(.secondary)
                @unknown default:
                    EmptyView()
                }
            }
            .matchedTransitionSource(id: pokemonItem.id, in: animation)

            VStack(alignment: .leading) {
                Text(pokemonItem.name)
                    .font(.headline)
                Text(String(format: "#%03d", pokemonItem.id))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if !pokemonItem.types.isEmpty {
                    HFlow {
                        ForEach(pokemonItem.types) { typeInfo in
                            TypePill(typeInfo: typeInfo)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
