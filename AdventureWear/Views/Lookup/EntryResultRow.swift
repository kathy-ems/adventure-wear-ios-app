import SwiftUI

struct EntryResultRow: View {
    let entry: OutfitEntry
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Always visible: weather summary header
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
            } label: {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 8) {
                            Text("\(Int(entry.temp.rounded()))°F")
                                .font(.headline)
                            Text(entry.conditions)
                                .foregroundStyle(.secondary)
                            if let wind = entry.wind, wind > 0 {
                                Text("\(Int(wind.rounded())) mph")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        contextLine
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .foregroundStyle(.secondary)
                        .font(.caption)
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.vertical, 10)

            // Expandable: clothing details + notes
            if isExpanded {
                Divider().padding(.bottom, 8)

                ForEach(entry.filledClothing, id: \.label) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Text(item.label)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 110, alignment: .leading)
                        Text(item.value)
                            .font(.subheadline)
                    }
                    .padding(.bottom, 4)
                }

                if let notes = entry.notes {
                    Divider().padding(.vertical, 4)
                    Text(notes)
                        .font(.subheadline)
                        .italic()
                        .foregroundStyle(.primary)
                        .padding(.bottom, 8)
                }
            }
        }
        .padding(.horizontal, 2)
    }

    @ViewBuilder
    private var contextLine: some View {
        let parts: [String] = [
            entry.teeTime.map { "Tee: \($0)" },
            entry.timeOfDay,
            entry.courseName,
            entry.humidity.map { "Humidity \(Int($0.rounded()))%" },
        ].compactMap { $0 }

        if !parts.isEmpty {
            Text(parts.joined(separator: " · "))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
