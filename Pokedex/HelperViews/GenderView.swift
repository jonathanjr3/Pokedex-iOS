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
                .foregroundStyle(.secondary)
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
                            Label {
                                Text(String(format: "%.0f%%", female))
                            } icon: {
                                Image(systemName: "person.fill")
                                    .foregroundStyle(.pink)
                            }
                        }
                        if let male = probabilities.malePercentage, male > 0 {
                            Image(systemName: "person.fill").foregroundStyle(
                                .blue
                            )
                            Text(String(format: "%.0f%%", male))
                        }
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                }
            } else {
                Text("N/A")
                    .font(.headline)
                    .fontWeight(.medium)
            }
        }
    }
}
