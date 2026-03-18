//
//  AllocationsView.swift
//  Midas
//

import SwiftUI

struct AllocationsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "circle.lefthalf.filled")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text("Allocations")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Coming soon")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    AllocationsView()
}
