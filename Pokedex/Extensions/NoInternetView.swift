//
//  NoInternetView.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 19/05/2025.
//

import SwiftUI

struct NoInternetView: View {
    var body: some View {
        Label("No Internet Connection", systemImage: "wifi.slash")
            .font(.system(.headline, weight: .medium))
            .frame(maxWidth: .infinity)
            .frame(height: 30)
            .background(Color.orange)
            .transition(.move(edge: .top).combined(with: .opacity))
    }
}

#Preview {
    NoInternetView()
}
