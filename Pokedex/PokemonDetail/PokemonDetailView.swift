//
//  PokemonDetailView.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 11/05/2025.
//

import SwiftUI

struct PokemonDetailView: View {
    let animation: Namespace.ID
    private let pokemonID: Int

    @State private var viewModel: PokemonDetailViewModel
    @Environment(\.dismiss) private var dismiss

    init(
        pokemonID: Int,
        animation: Namespace.ID,
        apiService: PokemonAPIService = .shared
    ) {
        self.pokemonID = pokemonID
        viewModel = PokemonDetailViewModel(
            pokemonId: pokemonID,
            apiService: apiService
        )
        self.animation = animation
    }

    var contentUnavailableView: some View {
        ContentUnavailableView(
            "Failed to Load",
            systemImage: "wifi.exclamationmark",
            description: Text(
                viewModel.errorMessage ?? "An unknown error occurred"
            )
        )
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .center
        )
        .padding(.top, 200)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            MeshGradient(
                width: 3,
                height: viewModel.meshGradientRows,
                points: viewModel.meshGradientPoints,
                colors: viewModel.meshGradientColours
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    AsyncImage(
                        url: Utilities.getPokemonSpriteURL(
                            forPokemonID: pokemonID
                        )
                    ) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image.resizable()
                                .scaledToFit()
                        case .failure:
                            Image(systemName: "questionmark.diamond.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(
                                    Color.secondary.opacity(0.6)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 200, height: 200)
                    .padding(.top, 60)
                    .navigationTransition(
                        .zoom(sourceID: pokemonID, in: animation)
                    )

                    if viewModel.isLoading && viewModel.pokemonDetail.id == -1 {
                        ProgressView("Loading details...")
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: .infinity,
                                alignment: .center
                            )
                            .padding(.top, 200)
                    } else if viewModel.pokemonDetail.id != -1 {
                        VStack(spacing: 20) {
                            Text(viewModel.pokemonDetail.name)
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(Color.primary)

                            Text(
                                String(
                                    format: "#%03d",
                                    viewModel.pokemonDetail.id
                                )
                            )
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)

                            HStack {
                                ForEach(viewModel.pokemonDetail.types) {
                                    typeInfo in
                                    Text(typeInfo.name.capitalized)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            typeInfo.color
                                                .opacity(0.8)
                                        )
                                        .foregroundColor(.white)
                                        .clipShape(Capsule())
                                }
                            }

                            // Height & Weight
                            HStack(spacing: 30) {
                                StatPill(
                                    label: "Height",
                                    value: String(
                                        format: "%.1f m",
                                        viewModel.pokemonDetail.height
                                    )
                                )
                                StatPill(
                                    label: "Weight",
                                    value: String(
                                        format: "%.1f kg",
                                        viewModel.pokemonDetail.weight
                                    )
                                )
                            }
                            .padding(.top)
                            Spacer()
                        }
                    } else {
                        contentUnavailableView
                    }
                }
            }
            .frame(maxWidth: .infinity)

            Image(systemName: "xmark")
                .font(.system(size: 16, weight: .bold))
                .padding(10)
                .background(.ultraThinMaterial, in: Circle())
                .onTapGesture {
                    dismiss()
                }
                .padding(.trailing)
        }
        .navigationTitle("Pokemon #\(viewModel.pokemonDetail.id)")
        .toolbarVisibility(.hidden, for: .navigationBar)
        .task {
            if viewModel.pokemonDetail.id == -1 {
                await viewModel.fetchPokemonDetails()
            }
        }
    }
}

#Preview {
    @Previewable @Namespace var animation
    NavigationStack {
        PokemonDetailView(
            pokemonID: 25,
            animation: animation,
            apiService: PokemonAPIService(apiClient: MockPokemonAPIClient())
        )
    }
}

struct StatPill: View {
    let label: String
    let value: String

    var body: some View {
        VStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.quaternary.opacity(0.5))
        .clipShape(Capsule())
    }
}
