//
//  PokemonDetailView.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 11/05/2025.
//

import FancyScrollView
import Flow
import Shimmer
import SwiftUI

struct PokemonDetailView: View {
    let animation: Namespace.ID
    private let pokemonID: Int
    private let pokemonName: String

    @State private var viewModel: PokemonDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    init(
        pokemonID: Int,
        pokemonName: String,
        animation: Namespace.ID,
        pokemonTypes: [PokemonTypeInfo] = [],
        apiService: PokemonAPIService = .shared
    ) {
        self.pokemonID = pokemonID
        self.pokemonName = pokemonName
        viewModel = PokemonDetailViewModel(
            pokemonId: pokemonID,
            pokemonTypes: pokemonTypes,
            apiService: apiService
        )
        self.animation = animation
    }

    var contentUnavailableView: some View {
        ContentUnavailableView(
            "Failed to Load Details",
            systemImage: "exclamationmark.triangle",
            description: Text(
                viewModel.errorMessage ?? "An unknown error occurred"
            )
        )
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .center
        )
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            MeshGradient(
                width: 3,
                height: 3,
                points: viewModel.meshGradientPoints,
                colors: viewModel.meshGradientColours,
                background: Color.accentColor
            )
            .ignoresSafeArea()

            FancyScrollView {
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
                    .padding(.top, 40)
                    .navigationTransition(
                        .zoom(sourceID: pokemonID, in: animation)
                    )
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .center) {
                            Text(pokemonName)
                                .font(
                                    .system(
                                        size: 34,
                                        weight: .bold
                                    )
                                )
                                .foregroundStyle(.primary)
                            Text(
                                String(
                                    format: "#%03d",
                                    pokemonID
                                )
                            )
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)

                            HFlow {
                                if viewModel.isLoading
                                    && viewModel.pokemonDetail.types
                                        .isEmpty
                                {
                                    ForEach(0..<2) { _ in
                                        TypePillPlaceholder()
                                    }
                                } else if viewModel.pokemonDetail.types
                                    .isEmpty
                                {
                                    Text("No types found.")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                } else {
                                    ForEach(
                                        viewModel.pokemonDetail.types
                                    ) { typeInfo in
                                        TypePill(typeInfo: typeInfo)
                                    }
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10).fill(
                                .ultraThinMaterial)
                        )
                        .padding(.horizontal)

                        if viewModel.errorOccurred {
                            contentUnavailableView
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding(.horizontal)
                        } else {
                            Group {
                                // Description Section
                                SectionView(title: "Description") {
                                    Text(viewModel.pokemonDetail.description)
                                        .font(.body)
                                        .lineLimit(nil)
                                        .fixedSize(
                                            horizontal: false,
                                            vertical: true
                                        )
                                }
                                .redacted(reason: viewModel.isLoading ? .placeholder : [])
                                .shimmering(active: viewModel.isLoading)
                                // Physical Attributes Section
                                SectionView(title: "Physical Attributes") {
                                    HStack {
                                        InfoItem(
                                            label: "Height",
                                            value: String(
                                                format: "%.1f m",
                                                viewModel.pokemonDetail.height
                                            ),
                                            systemImage: "ruler.fill"
                                        )
                                        Spacer()
                                        InfoItem(
                                            label: "Weight",
                                            value: String(
                                                format: "%.1f kg",
                                                viewModel.pokemonDetail.weight
                                            ),
                                            systemImage: "scalemass.fill"
                                        )
                                        Spacer()
                                        GenderView(
                                            genderProbabilities: viewModel
                                                .pokemonDetail
                                                .genderProbabilities
                                        )
                                    }
                                }
                                .redacted(
                                    reason: viewModel.isLoading
                                        && viewModel.pokemonDetail.height == 0
                                        ? .placeholder : []
                                )
                                .shimmering(
                                    active: viewModel.isLoading
                                        && viewModel.pokemonDetail.height == 0
                                )
                                // Abilities Section
                                SectionView(title: "Abilities") {
                                    VStack(alignment: .leading, spacing: 8) {
                                        if viewModel.isLoading
                                            && viewModel.pokemonDetail.abilities
                                                .isEmpty
                                        {
                                            Text("Loading abilities...")
                                                .font(.caption)
                                                .shimmering()
                                        } else if viewModel.pokemonDetail
                                            .abilities.isEmpty
                                        {
                                            Text("No abilities found.")
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        } else {
                                            ForEach(
                                                viewModel.pokemonDetail
                                                    .abilities
                                            ) { ability in
                                                AbilityRow(ability: ability)
                                            }
                                        }
                                    }
                                }
                                // Base Stats Section
                                SectionView(title: "Base Stats") {
                                    VStack(spacing: 8) {
                                        if viewModel.isLoading
                                            && viewModel.pokemonDetail.stats
                                                .isEmpty
                                        {
                                            ForEach(0..<6) { _ in
                                                StatRowPlaceholder()
                                            }
                                        } else if viewModel.pokemonDetail.stats
                                            .isEmpty
                                        {
                                            Text("No stats found.").font(
                                                .subheadline
                                            ).foregroundStyle(.secondary)
                                        } else {
                                            ForEach(
                                                viewModel.pokemonDetail.stats
                                            ) { stat in
                                                StatRow(stat: stat)
                                            }
                                        }
                                    }
                                }

                                // Type Defenses Section
                                if let defenses = viewModel.pokemonDetail
                                    .typeDefenses
                                {
                                    SectionView(title: "Type Defenses") {
                                        TypeDefensesView(defenses: defenses)
                                    }
                                } else if viewModel.isLoading {
                                    Text("Loading defenses...").font(.caption)
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .scrollIndicators(.hidden)

            HStack {
                Image(
                    systemName: viewModel.isFavourite
                        ? "heart.fill" : "heart"
                )
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(viewModel.isFavourite ? .red : .gray)
                .padding(8)
                .background(.ultraThinMaterial, in: Circle())
                .onTapGesture {
                    viewModel.toggleFavourite()
                }
                .padding(.trailing)
                .symbolEffect(.bounce, value: viewModel.isFavourite)
                .sensoryFeedback(.success, trigger: viewModel.isFavourite)
                Spacer()
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .padding(10)
                    .background(.ultraThinMaterial, in: Circle())
                    .onTapGesture {
                        dismiss()
                    }
            }
            .frame(maxWidth: .infinity)
            .padding([.horizontal, .top])
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
        .toolbarVisibility(.hidden, for: .tabBar)
        .task {
            viewModel.setModelContext(modelContext)
            if viewModel.pokemonDetail.id == -1 || viewModel.errorOccurred {
                await viewModel.fetchPokemonDetails()
            }
        }
    }
}

#Preview {
    @Previewable @Namespace var animation
    NavigationStack {
        PokemonDetailView(
            pokemonID: 10275,
            pokemonName: "Ogerpon-Corenerstone-Mask",
            animation: animation
        )
    }
}

struct SectionView<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(.title2, weight: .bold))
            content
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial))
    }
}
