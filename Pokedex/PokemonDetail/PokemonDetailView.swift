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
    @State var imageURL: URL?
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView {
                VStack {
                    AsyncImage(url: imageURL, content: { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                    }, placeholder: {
                        ProgressView()
                    })
                    .padding(.top)
                    .navigationTransition(.zoom(sourceID: pokemonId, in: animation))
                    Text("Details for Pokemon ID: \(pokemonId)")
                        .font(.system(.headline, design: .rounded, weight: .heavy))
                        .frame(maxWidth: .infinity)
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
        .toolbarVisibility(.hidden, for: .navigationBar)
    }
}

#Preview {
    @Previewable @Namespace var animation
    NavigationStack {
        PokemonDetailView(pokemonId: 1, animation: animation, imageURL: getPokemonSpriteURL(ID: 1))
    }
}
