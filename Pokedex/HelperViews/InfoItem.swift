//
//  InfoItem.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 18/05/2025.
//
import SwiftUI

struct InfoItem: View {
    let label: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Label(value, systemImage: systemImage)
                .font(.headline)
                .fontWeight(.medium)
        }
    }
}
