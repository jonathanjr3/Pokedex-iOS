//
//  PokemonGridCell.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 20/05/2025.
//

import Shimmer
import SwiftUI

struct PokemonGridCell: View {
    let pokemonItem: PokemonListItem
    let animation: Namespace.ID

    var body: some View {
        VStack {
            AsyncImage(url: pokemonItem.spriteURL) { phase in
                switch phase {
                case .empty:
                    Image(systemName: "diamond.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .padding(10)
                        .foregroundStyle(.secondary.opacity(0.5))
                        .shimmering()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .aspectRatio(1, contentMode: .fit)
                case .failure:
                    Image(systemName: "questionmark.diamond")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .padding(10)
                        .foregroundStyle(.secondary)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 100)
            .padding(.top, 8)
            .matchedTransitionSource(id: pokemonItem.id, in: animation)

            Text(pokemonItem.name)
                .font(.callout)
                .fontWeight(.medium)
                .lineLimit(1)
                .truncationMode(.tail)

            Text(String(format: "#%03d", pokemonItem.id))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(Color.gridCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contentShape(RoundedRectangle(cornerRadius: 12))  // For tap targets
    }
}

#Preview {
    @Previewable @Namespace var animation
    let mockItem = PokemonListItem(
        pokemonSummary: .init(
            name: "Pikachu",
            url: "https://pokeapi.co/api/v2/pokemon/25/"
        ),
        dominantColor: .yellow,
        types: []
    )

    return ScrollView {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
            PokemonGridCell(pokemonItem: mockItem, animation: animation)
            PokemonGridCell(pokemonItem: mockItem, animation: animation)
        }
        .padding()
    }
}
