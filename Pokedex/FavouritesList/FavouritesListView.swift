//
//  FavoritesListView.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 19/05/2025.
//
import SwiftUI
import SwiftData

struct FavouritesListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FavouritePokemon.dateAdded, order: .reverse) private var favorites: [FavouritePokemon]
    @Namespace var animation

    @State private var editMode: EditMode = .inactive
    @State private var selection = Set<FavouritePokemon.ID>()

    var body: some View {
        List(selection: $selection) {
            if favorites.isEmpty {
                ContentUnavailableView(
                    "No Favorites Yet",
                    systemImage: "heart.slash",
                    description: Text("Add Pokémon to your favorites to see them here.")
                )
            } else {
                ForEach(favorites) { favoritePokemon in
                    NavigationLink {
                        // Navigate to PokemonDetailView, configured for OFFLINE data
                        // This means PokemonDetailViewModel needs an init that can take FavoritePokemon
                        PokemonDetailView(
                            pokemonID: favoritePokemon.id,
                            initialName: favoritePokemon.name, // Pass initial name
                            animation: animation,
                            favoriteData: favoritePokemon // Pass the favorite object
                        )
                    } label: {
                        FavoriteListRow(favoritePokemon: favoritePokemon, animation: animation)
                            // For matched transition from favorites list
                            .matchedTransitionSource(id: favoritePokemon.id, in: animation)
                    }
                }
                .onDelete(perform: deleteFavorites)
            }
        }
        .navigationTitle("Favorite Pokémon")
        .environment(\.editMode, $editMode)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if !favorites.isEmpty { EditButton() }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if editMode == .active && !selection.isEmpty {
                    Button("Delete Selected", systemImage: "trash", role: .destructive) {
                        deleteSelectedFavorites()
                    }
                }
            }
        }
    }

    private func deleteFavorites(offsets: IndexSet) {
        withAnimation {
            offsets.map { favorites[$0] }.forEach(modelContext.delete)
            saveContext()
        }
    }
    
    private func deleteSelectedFavorites() {
        withAnimation {
            for id in selection {
                if let favoriteToDelete = favorites.first(where: { $0.id == id }) {
                    modelContext.delete(favoriteToDelete)
                }
            }
            saveContext()
            selection.removeAll()
            editMode = .inactive // Exit edit mode after deletion
        }
    }

    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context after deletion: \(error)")
        }
    }
}

struct FavoriteListRow: View {
    let favoritePokemon: FavouritePokemon
    let animation: Namespace.ID

    var body: some View {
        HStack {
            AsyncImage(url: favoritePokemon.spriteURL) { phase in
                // ... (same AsyncImage logic as PokemonListRow) ...
                switch phase {
                case .empty: ProgressView().frame(width: 70, height: 70)
                case .success(let image): image.resizable().aspectRatio(contentMode: .fit).frame(width: 70, height: 70)
                case .failure: Image(systemName: "questionmark.diamond").resizable().scaledToFit().frame(width:50, height:50).padding(10).foregroundColor(.gray)
                @unknown default: EmptyView()
                }
            }
            .background(favoritePokemon.dominantColor.opacity(0.1)) // Use stored color
            .clipShape(Circle())

            VStack(alignment: .leading) {
                Text(favoritePokemon.name)
                    .font(.headline)
                Text(String(format: "#%03d", favoritePokemon.id))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                // Optionally show types
                HStack {
                    ForEach(favoritePokemon.types, id: \.self) { typeName in
                        Text(typeName.capitalized)
                            .font(.caption2)
                            .padding(.horizontal, 6).padding(.vertical, 3)
                            .background(PokemonTypeInfo.color(for: typeName).opacity(0.7))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// Preview for FavoritesListView
#Preview {
    NavigationStack {
        FavouritesListView()
            .modelContainer(for: FavouritePokemon.self, inMemory: true) // For preview
    }
}
