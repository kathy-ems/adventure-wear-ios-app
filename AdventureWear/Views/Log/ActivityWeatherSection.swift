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
                        InlineTextField("Time of Run", key: "timeOfDay", placeholder: "e.g. 3:00 PM", values: $values)
                    case .teeTime:
                        InlineTextField("Tee Time", key: "teeTime", placeholder: "e.g. 9:00 AM", values: $values)
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
