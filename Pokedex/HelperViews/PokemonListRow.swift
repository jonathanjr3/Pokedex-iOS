//
//  PokemonListRow.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 18/05/2025.
//
import SwiftUI

struct PokemonListRow: View {
    let pokemonItem: PokemonListItem
    let animation: Namespace.ID

    var body: some View {
        HStack {
            AsyncImage(url: pokemonItem.spriteURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 70, height: 70)
                case .success(let image):
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 70, height: 70)
                case .failure:
                    Image(systemName: "questionmark.diamond")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .padding(10)
                        .foregroundColor(.gray)
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
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
