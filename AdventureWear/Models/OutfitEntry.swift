import Foundation

struct OutfitEntry: Identifiable {
    let id: UUID
    let activity: Activity
    let temp: Double
    let feelsLike: Double?
    let conditions: String
    let wind: Double?
    let humidity: Double?
    let timeOfDay: String?
    let lowTemp: Double?
    let highTemp: Double?
    let wetGround: String?
    let clothing: [String: String]
    let notes: String?
    let courseName: String?
    let timestamp: String?
    var tempDelta: Double = 0

    // Non-empty clothing fields in schema order, excluding meta fields
    var filledClothing: [(label: String, value: String)] {
        let exclude = Set(["notes", "courseName"])
        return activity.schema
            .filter { !exclude.contains($0.key) }
            .compactMap { field -> (label: String, value: String)? in
                guard let val = clothing[field.key], !val.isEmpty else { return nil }
                return (label: field.label, value: val)
            }
    }
}

extension OutfitEntry {
    init?(from dict: [String: String]) {
        guard
            let activityStr = dict["activity"],
            let activity = Activity(rawValue: activityStr),
            let tempStr = dict["temp"], !tempStr.isEmpty,
            let temp = Double(tempStr)
        else { return nil }

        self.id = UUID()
        self.activity = activity
        self.temp = temp
        self.feelsLike = Double(dict["feelsLike"] ?? "")
        self.conditions = dict["conditions"] ?? ""
        self.wind = Double(dict["wind"] ?? "")
        self.humidity = Double(dict["humidity"] ?? "")
        self.timeOfDay = dict["timeOfDay"].nonEmpty
        self.lowTemp = Double(dict["lowTemp"] ?? "")
        self.highTemp = Double(dict["highTemp"] ?? "")
        self.wetGround = dict["wetGround"].nonEmpty
        self.notes = dict["notes"].nonEmpty
        self.courseName = dict["courseName"].nonEmpty
        self.timestamp = dict["timestamp"].nonEmpty

        let clothingKeys = ["outerwear", "topLong", "topShort", "bottoms", "head", "hands", "feet"]
        self.clothing = clothingKeys.reduce(into: [:]) { acc, key in
            if let val = dict[key], !val.isEmpty { acc[key] = val }
        }
    }
}

private extension Optional where Wrapped == String {
    var nonEmpty: String? { self.flatMap { $0.isEmpty ? nil : $0 } }
}
