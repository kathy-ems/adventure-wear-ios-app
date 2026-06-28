import CoreLocation
import Foundation

@MainActor
final class WeatherService: NSObject, ObservableObject {
    @Published var snapshot: WeatherSnapshot?
    @Published var error: String?
    @Published var isLoading = false

    private let locationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func fetch() async {
        isLoading = true
        error = nil
        do {
            let location = try await requestLocation()
            snapshot = try await fetchOpenMeteo(for: location)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    private func fetchOpenMeteo(for location: CLLocation) async throws -> WeatherSnapshot {
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        let url = URL(string:
            "https://api.open-meteo.com/v1/forecast" +
            "?latitude=\(lat)&longitude=\(lon)" +
            "&current=temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,weather_code" +
            "&temperature_unit=fahrenheit&wind_speed_unit=mph&timezone=auto"
        )!
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw WeatherError.apiError
        }
        let decoded = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
        let c = decoded.current
        return WeatherSnapshot(
            temp: c.temperature_2m,
            feelsLike: c.apparent_temperature,
            conditions: wmoDescription(c.weather_code),
            windSpeed: c.wind_speed_10m,
            humidity: Double(c.relative_humidity_2m),
            capturedAt: Date()
        )
    }

    // WMO weather interpretation codes → readable string
    private func wmoDescription(_ code: Int) -> String {
        switch code {
        case 0:          return "Clear"
        case 1:          return "Mostly Clear"
        case 2:          return "Partly Cloudy"
        case 3:          return "Cloudy"
        case 45, 48:     return "Foggy"
        case 51, 53, 55: return "Drizzle"
        case 61, 63, 65: return "Rain"
        case 71, 73, 75: return "Snow"
        case 80, 81, 82: return "Rain Showers"
        case 95:         return "Thunderstorm"
        default:         return "Mixed"
        }
    }

    private func requestLocation() async throws -> CLLocation {
        try await withCheckedThrowingContinuation { cont in
            locationContinuation = cont
            switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.requestLocation()
            default:
                locationContinuation = nil
                cont.resume(throwing: LocationError.denied)
            }
        }
    }

    enum LocationError: LocalizedError {
        case denied
        var errorDescription: String? { "Location access denied. Please enable it in Settings." }
    }

    enum WeatherError: LocalizedError {
        case apiError
        var errorDescription: String? { "Could not fetch weather from Open-Meteo." }
    }
}

// MARK: - Open-Meteo response

private struct OpenMeteoResponse: Decodable {
    let current: Current
    struct Current: Decodable {
        let temperature_2m: Double
        let apparent_temperature: Double
        let relative_humidity_2m: Int
        let wind_speed_10m: Double
        let weather_code: Int
    }
}

// MARK: - CLLocationManagerDelegate

extension WeatherService: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            guard manager.authorizationStatus == .authorizedWhenInUse ||
                  manager.authorizationStatus == .authorizedAlways else { return }
            manager.requestLocation()
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        Task { @MainActor in
            locationContinuation?.resume(returning: location)
            locationContinuation = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            locationContinuation?.resume(throwing: error)
            locationContinuation = nil
        }
    }
}
