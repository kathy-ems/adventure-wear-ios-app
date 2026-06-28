import SwiftUI

struct ClothingFormView: View {
    let fields: [ActivityField]
    @Binding var values: [String: String]

    var body: some View {
        ForEach(fields) { field in
            VStack(alignment: .leading, spacing: 2) {
                Text(field.label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField(field.placeholder, text: binding(for: field.key), axis: .vertical)
                    .lineLimit(1...3)
            }
            .padding(.vertical, 2)
        }
    }

    private func binding(for key: String) -> Binding<String> {
        Binding(
            get: { values[key] ?? "" },
            set: { values[key] = $0 }
        )
    }
}
