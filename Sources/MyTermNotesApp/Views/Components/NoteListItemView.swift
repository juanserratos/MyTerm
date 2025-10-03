import SwiftUI

struct NoteListItemView: View {
    let note: Note
    let isSelected: Bool

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: note.updatedAt)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(note.title.isEmpty ? "Untitled" : note.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(isSelected ? .white : Color.primary.opacity(0.92))
                    .lineLimit(1)

                Spacer()

                Circle()
                    .fill(note.tint.gradient)
                    .frame(width: 8, height: 8)
            }

            Text(formattedDate)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(isSelected ? Color.white.opacity(0.7) : Color.secondary)

            Text(note.preview)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(isSelected ? Color.white.opacity(0.85) : Color.secondary)
                .lineLimit(2)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(isSelected ? note.tint.gradient : Color(.windowBackgroundColor))
                .shadow(color: isSelected ? note.tint.color.opacity(0.35) : Color.black.opacity(0.06), radius: isSelected ? 16 : 6, y: isSelected ? 8 : 2)
        )
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
    }
}
