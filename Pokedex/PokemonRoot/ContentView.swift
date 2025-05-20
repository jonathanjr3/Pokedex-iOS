//
//  ContentView.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 10/05/2025.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Browse", systemImage: "list.bullet", value: 0, role: .search) {
                PokemonListView()
            }
            Tab("Favourites", systemImage: "star", value: 1) {
                FavouritesListView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .sensoryFeedback(.selection, trigger: selectedTab)
        .onAppear(perform: {
            if let action = Utilities.quickActionManager.selectedAction {
                handleQuickAction(action: action)
            }
        })
        .onChange(
            of: Utilities.quickActionManager.selectedAction,
            { oldValue, newValue in
                if let action = newValue {
                    handleQuickAction(action: action)
                }
            }
        )
    }
    
    private func handleQuickAction(action: QuickActionType) {
        switch action {
        case .viewFavourites:
            selectedTab = 1
            Utilities.quickActionManager.selectedAction = nil
        case .search:
            selectedTab = 0
        case .none:
            break
        }
    }
}

#Preview {
    ContentView()
}
