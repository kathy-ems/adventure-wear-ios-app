import SwiftUI

struct ActivityWeatherSection: View {
    let activity: Activity
    @Binding var values: [String: String]

    var body: some View {
        if !activity.activityWeatherFields.isEmpty {
            Section("Activity Details") {
                ForEach(activity.activityWeatherFields, id: \.self) { field in
                    switch field {
                    case .timeOfDay:
                        InlineTextField(activity.timeOfDayLabel, key: "timeOfDay", placeholder: activity.timeOfDayPlaceholder, values: $values)
                    case .lowTemp:
                        InlineTextField("Low Temp (°F)", key: "lowTemp", placeholder: "e.g. 45", values: $values)
                            .keyboardType(.numberPad)
                    case .highTemp:
                        InlineTextField("High Temp (°F)", key: "highTemp", placeholder: "e.g. 65", values: $values)
                            .keyboardType(.numberPad)
                    case .wetGround:
                        Toggle("Dewy / Wet Ground", isOn: Binding(
                            get: { values["wetGround"] == "Yes" },
                            set: { values["wetGround"] = $0 ? "Yes" : "No" }
                        ))
                    }
                }
            }
        }
    }
}

private struct InlineTextField: View {
    let label: String
    let key: String
    let placeholder: String
    @Binding var values: [String: String]

    init(_ label: String, key: String, placeholder: String, values: Binding<[String: String]>) {
        self.label = label
        self.key = key
        self.placeholder = placeholder
        self._values = values
    }

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            TextField(placeholder, text: Binding(
                get: { values[key] ?? "" },
                set: { values[key] = $0 }
            ))
            .multilineTextAlignment(.trailing)
            .foregroundStyle(.primary)
        }
    }
}

// Allows .keyboardType to be applied to InlineTextField
extension InlineTextField {
    func keyboardType(_ type: UIKeyboardType) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField(placeholder, text: Binding(
                get: { values[key] ?? "" },
                set: { values[key] = $0 }
            ))
            .keyboardType(type)
            .multilineTextAlignment(.trailing)
        }
    }
}
