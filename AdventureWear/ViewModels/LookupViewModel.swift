import SwiftUI

@MainActor
final class LookupViewModel: ObservableObject {
    @Published var selectedActivity: Activity = .golf
    @Published var results: [OutfitEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var tempOverride: String = ""

    func search(currentTemp: Double) async {
        let temp = Double(tempOverride) ?? currentTemp
        isLoading = true
        errorMessage = nil
        do {
            var entries = try await SheetsService.shared.fetchEntries(activity: selectedActivity, currentTemp: temp)
            entries = entries
                .map { var e = $0; e.tempDelta = abs($0.temp - temp); return e }
                .sorted { $0.tempDelta < $1.tempDelta }
            results = entries
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func effectiveTemp(fallback: Double?) -> Double? {
        if let override = Double(tempOverride) { return override }
        return fallback
    }
}
