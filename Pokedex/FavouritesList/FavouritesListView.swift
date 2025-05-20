import SwiftData
//
//  FavouritesListView.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 19/05/2025.
//
import SwiftUI

struct FavouritesListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.networkMonitor) private var networkMonitor
    @Query(sort: \FavouritePokemon.dateAdded, order: .reverse) private
        var favourites: [FavouritePokemon]
    @Namespace var animation
    @State private var selection = Set<FavouritePokemon.ID>()
    @Environment(\.editMode) private var editMode

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !networkMonitor.isConnected {
                    NoInternetView()
                        .animation(.smooth, value: networkMonitor.isConnected)
                }
                if favourites.isEmpty {
                    ContentUnavailableView(
                        "No Favourites Yet",
                        systemImage: "heart.slash",
                        description: Text(
                            "Add Pokémon to your favourites to see them here."
                        )
                    )
                } else {
                    List(selection: $selection) {
                        ForEach(favourites) { favouritePokemon in
                            NavigationLink {
                                PokemonDetailView(
                                    pokemonID: favouritePokemon.id,
                                    pokemonName: favouritePokemon.name,
                                    animation: animation,
                                    pokemonTypes: favouritePokemon.pokemonTypes
                                )
                                .toolbarVisibility(.hidden, for: .tabBar)
                            } label: {
                                PokemonListRow(
                                    pokemonItem: .init(
                                        pokemonSummary: .init(
                                            name: favouritePokemon.name,
                                            url:
                                                "https://pokeapi.co/api/v2/pokemon/\(favouritePokemon.id)/"
                                        ),
                                        dominantColor: favouritePokemon
                                            .dominantColor,
                                        types: favouritePokemon.pokemonTypes
                                    ),
                                    animation: animation
                                )
                            }
                        }
                        .onDelete(perform: deleteFavorites)
                    }
                    .toolbar {
                        if !favourites.isEmpty {
                            ToolbarItem {
                                EditButton()
                            }
                        }
                        if !selection.isEmpty && editMode?.wrappedValue.isEditing == true {
                            ToolbarItem(placement: .topBarLeading) {
                                deleteButton
                            }
                        }
                    }
                }
            }
            .navigationTitle("Favourite Pokémon")
        }
    }

    private var deleteButton: some View {
        Button(
            "Delete Selected",
            systemImage: "trash",
            role: .destructive
        ) {
            deleteSelectedFavorites()
        }
    }

    private func deleteFavorites(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(favourites[index])
                selection.remove(favourites[index].id)
            }
            saveContext()
        }
    }

    private func deleteSelectedFavorites() {
        withAnimation {
            try? modelContext.delete(
                model: FavouritePokemon.self,
                where: #Predicate { selection.contains($0.id) }
            )
            saveContext()
            selection.removeAll()
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

#Preview {
    NavigationStack {
        FavouritesListView()
            .modelContainer(for: FavouritePokemon.self, inMemory: true)
    }
}
