import Foundation

struct WeatherSnapshot: Equatable {
    var temp: Double
    var feelsLike: Double?
    var conditions: String
    var windSpeed: Double?
    var humidity: Double?
    var capturedAt: Date

    var tempDisplay: String { "\(Int(temp.rounded()))°F" }

    var feelsLikeDisplay: String? {
        guard let f = feelsLike else { return nil }
        return "Feels \(Int(f.rounded()))°"
    }

    var windDisplay: String? {
        guard let w = windSpeed, w > 0 else { return nil }
        return "\(Int(w.rounded())) mph wind"
    }
}
