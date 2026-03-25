import SwiftUI

struct TopicBadge: View {
    let topic: String
    var isEditable: Bool = false
    var onEdit: (() -> Void)?

    var body: some View {
        HStack(spacing: 6) {
            Text(topic)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)

            if isEditable {
                Image(systemName: "pencil")
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "8B9BB4"))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(hex: "243044"))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "2D3F54"), lineWidth: 1)
        )
        .onTapGesture {
            onEdit?()
        }
    }
}
