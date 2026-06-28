import SwiftUI

@MainActor
final class LogViewModel: ObservableObject {
    @Published var selectedActivity: Activity = .golf
    @Published var clothing: [String: String] = [:]
    @Published var activityWeather: [String: String] = [:]
    @Published var isSubmitting = false
    @Published var showSuccess = false
    @Published var errorMessage: String?

    func submit(weather: WeatherSnapshot) async {
        isSubmitting = true
        errorMessage = nil
        do {
            try await SheetsService.shared.logEntry(
                activity: selectedActivity,
                weather: weather,
                activityWeather: activityWeather,
                clothing: clothing
            )
            clothing = [:]
            activityWeather = [:]
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isSubmitting = false
    }

    func resetForm() {
        clothing = [:]
        activityWeather = [:]
    }
}
