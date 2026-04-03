//
//  TagChipsView.swift
//  Midas
//

import SwiftUI

struct TagChipsView: View {
    let tags: [String]
    var onRemove: ((String) -> Void)?
    var onAdd: (() -> Void)?

    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                tagChip(tag)
            }

            if let onAdd {
                addTagButton(action: onAdd)
            }
        }
    }

    private func tagChip(_ tag: String) -> some View {
        HStack(spacing: 4) {
            Text("#\(tag.uppercased())")
                .font(.caption)
                .fontWeight(.semibold)
                .tracking(1)

            if let onRemove {
                Button {
                    onRemove(tag)
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .bold))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(Color.primary.opacity(0.3), lineWidth: 1)
        )
        .foregroundStyle(.primary)
    }

    private func addTagButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "plus")
                    .font(.system(size: 10, weight: .semibold))
                Text("ADD TAG")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .tracking(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(Color.primary.opacity(0.3), lineWidth: 1)
            )
            .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private struct ArrangeResult {
        var positions: [CGPoint]
        var size: CGSize
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> ArrangeResult {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalSize: CGSize = .zero

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            rowHeight = max(rowHeight, size.height)
            currentX += size.width + spacing
            totalSize.width = max(totalSize.width, currentX - spacing)
            totalSize.height = max(totalSize.height, currentY + rowHeight)
        }

        return ArrangeResult(positions: positions, size: totalSize)
    }
}

#Preview {
    TagChipsView(
        tags: ["monthly", "essentials", "work"],
        onRemove: { _ in },
        onAdd: { }
    )
    .padding()
}
