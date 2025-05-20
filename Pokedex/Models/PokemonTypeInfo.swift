//
//  PokemonTypeInfo.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 15/05/2025.
//

import SwiftUI
import SwiftData

struct PokemonTypeInfo: Identifiable, Hashable {
    let id = UUID()
    let typeId: Int?
    let name: String
    
    var typeSystemImage: String {
        Utilities.getTypeSystemImageString(forName: name)
    }
    
    init(name: String, typeId: Int? = nil) {
        self.typeId = typeId
        self.name = name
    }

    var color: Color {
        Utilities.getTypeColor(forTypeName: name)
    }
}
