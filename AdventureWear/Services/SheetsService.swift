import Foundation

final class SheetsService {
    static let shared = SheetsService()

    private let webAppURL: String
    private let token: String

    private init() {
        guard
            let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let dict = NSDictionary(contentsOf: url) as? [String: String]
        else {
            fatalError("Secrets.plist not found — copy Secrets.example.plist to Secrets.plist and fill in your values")
        }
        webAppURL = dict["SheetsWebAppURL"] ?? ""
        token     = dict["SheetsToken"] ?? ""
    }

    func fetchEntries(activity: Activity, currentTemp: Double) async throws -> [OutfitEntry] {
        var components = URLComponents(string: webAppURL)!
        components.queryItems = [
            URLQueryItem(name: "token",    value: token),
            URLQueryItem(name: "activity", value: activity.rawValue),
            URLQueryItem(name: "minTemp",  value: String(Int((currentTemp - 8).rounded()))),
            URLQueryItem(name: "maxTemp",  value: String(Int((currentTemp + 8).rounded()))),
        ]
        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw SheetsError.serverError
        }
        let rows = try JSONDecoder().decode([[String: String]].self, from: data)
        return rows.compactMap { OutfitEntry(from: $0) }
    }

    func logEntry(
        activity: Activity,
        weather: WeatherSnapshot,
        activityWeather: [String: String],
        clothing: [String: String]
    ) async throws {
        var body: [String: Any] = [
            "token":      token,
            "timestamp":  ISO8601DateFormatter().string(from: weather.capturedAt),
            "activity":   activity.rawValue,
            "temp":       weather.temp,
            "feelsLike":  weather.feelsLike ?? "",
            "conditions": weather.conditions,
            "wind":       weather.windSpeed ?? "",
            "humidity":   weather.humidity ?? "",
        ]
        activityWeather.forEach { body[$0.key] = $0.value }
        clothing.forEach { body[$0.key] = $0.value }

        var request = URLRequest(url: URL(string: webAppURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw SheetsError.serverError
        }
    }

    enum SheetsError: LocalizedError {
        case serverError
        var errorDescription: String? { "Failed to communicate with Google Sheets. Check your network and Apps Script URL." }
    }
}
