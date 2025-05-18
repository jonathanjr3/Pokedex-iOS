//
//  GenderView.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 18/05/2025.
//
import SwiftUI

struct GenderView: View {
    let genderProbabilities: GenderProbabilities?

    var body: some View {
        VStack(alignment: .leading) {
            Text("Gender")
                .font(.caption)
                .foregroundColor(.secondary)
            if let probabilities = genderProbabilities {
                if probabilities.femalePercentage == nil
                    && probabilities.malePercentage == nil
                {
                    Text("Genderless")
                        .font(.headline)
                        .fontWeight(.medium)
                } else {
                    HStack(spacing: 4) {
                        if let female = probabilities.femalePercentage,
                            female > 0
                        {
                            Image(systemName: "person.fill").foregroundColor(
                                .pink
                            )  // Or specific gender symbols
                            Text(String(format: "%.0f%%", female))
                        }
                        if let male = probabilities.malePercentage, male > 0 {
                            Image(systemName: "person.fill").foregroundColor(
                                .blue
                            )
                            Text(String(format: "%.0f%%", male))
                        }
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                }
            } else {
                Text("N/A")  // Or loading state
                    .font(.headline)
                    .fontWeight(.medium)
            }
        }
    }
}
