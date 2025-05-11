//
//  PokemonDetailView.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 11/05/2025.
//

import SwiftUI

struct PokemonDetailView: View {
    let pokemonId: Int
    let animation: Namespace.ID
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView {
                VStack {
                    Text("Details for Pokemon ID: \(pokemonId)")
                        .font(.system(.headline, design: .rounded, weight: .heavy))
                        .frame(maxWidth: .infinity)
                        .navigationTransition(.zoom(sourceID: pokemonId, in: animation))
                }
            }
            
            Image(systemName: "xmark")
                .font(.system(size: 16, weight: .bold))
                .padding(10)
                .background(.ultraThinMaterial, in: Circle())
                .onTapGesture {
                    dismiss()
                }
                .padding(.horizontal)
        }
        .navigationTitle("Pokemon #\(pokemonId)")
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationStack {
        PokemonDetailView(pokemonId: 1, animation: Namespace.init().wrappedValue)
    }
}
