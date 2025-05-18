//
//  StatRow.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 18/05/2025.
//
import SwiftUI
import Shimmer

struct StatRow: View {
    let stat: PokemonStat
    private let maxStatValue: Double = 255  // Max possible base stat

    var body: some View {
        HStack {
            Text(stat.shortName)
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 40, alignment: .leading)
            Text(String(stat.baseStat))
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 30, alignment: .trailing)

            ProgressView(value: Double(stat.baseStat), total: maxStatValue)
                .progressViewStyle(
                    LinearProgressViewStyle(tint: stat.statColor)
                )
                .frame(height: 8)
                .clipShape(Capsule())
        }
    }
}

struct StatRowPlaceholder: View {
    var body: some View {
        HStack {
            Text("STA").font(.caption)
            Text("100").font(.caption)
            ProgressView(value: 0.5)
                .progressViewStyle(LinearProgressViewStyle(tint: .gray))
        }
        .redacted(reason: .placeholder)
        .shimmering()
    }
}
