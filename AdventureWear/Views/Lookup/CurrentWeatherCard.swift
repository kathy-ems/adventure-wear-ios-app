import SwiftUI

struct CurrentWeatherCard: View {
    let weather: WeatherSnapshot?
    let isLoading: Bool
    @Binding var tempOverride: String
    @State private var showingOverrideAlert = false
    @State private var draftTemp = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Current Weather")
                    .font(.caption.uppercaseSmallCaps())
                    .foregroundStyle(.secondary)
                Spacer()
                if !tempOverride.isEmpty {
                    Button("Clear Override") { tempOverride = "" }
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }

            if isLoading {
                HStack { ProgressView(); Text("Fetching weather…").foregroundStyle(.secondary) }
            } else if let w = weather {
                HStack(alignment: .top, spacing: 16) {
                    Button { draftTemp = tempOverride.isEmpty ? String(Int(w.temp.rounded())) : tempOverride
                             showingOverrideAlert = true } label: {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(tempOverride.isEmpty ? w.tempDisplay : "\(tempOverride)°F")
                                .font(.largeTitle.bold())
                                .foregroundStyle(tempOverride.isEmpty ? .primary : .orange)
                            if !tempOverride.isEmpty {
                                Text("tap to edit").font(.caption2).foregroundStyle(.orange)
                            } else {
                                Text("tap to override").font(.caption2).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(w.conditions).font(.subheadline)
                        if let fl = w.feelsLikeDisplay {
                            Text(fl).font(.caption).foregroundStyle(.secondary)
                        }
                        if let wind = w.windDisplay {
                            Text(wind).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                }
            } else {
                Text("Weather unavailable — use temp override to search")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Button("Set Temperature") {
                    draftTemp = ""
                    showingOverrideAlert = true
                }
                .font(.subheadline)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .alert("Override Temperature", isPresented: $showingOverrideAlert) {
            TextField("Temperature (°F)", text: $draftTemp)
                .keyboardType(.numberPad)
            Button("Search") { tempOverride = draftTemp }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter a temperature to search instead of using current weather.")
        }
    }
}
