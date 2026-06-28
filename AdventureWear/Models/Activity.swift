import Foundation

enum Activity: String, CaseIterable, Identifiable, Codable {
    case golf = "Golf"
    case running = "Running"

    var id: String { rawValue }

    var schema: [ActivityField] {
        switch self {
        case .golf:
            return [
                ActivityField(key: "outerwear",  label: "Outerwear",          placeholder: "e.g. windbreaker, fleece, light vest"),
                ActivityField(key: "topLong",     label: "Top (Long Sleeve)",  placeholder: "e.g. Smartwool, cotton long sleeve"),
                ActivityField(key: "topShort",    label: "Top (Short Sleeve)", placeholder: "e.g. polo, SPF shrug"),
                ActivityField(key: "bottoms",     label: "Bottoms",            placeholder: "e.g. pants, black skirt with tights"),
                ActivityField(key: "head",        label: "Head",               placeholder: "e.g. purple headband, beanie"),
                ActivityField(key: "hands",       label: "Hands",              placeholder: "e.g. gloves, hand warmers"),
                ActivityField(key: "feet",        label: "Feet",               placeholder: "e.g. light socks, rain shoes"),
                ActivityField(key: "notes",       label: "Outcome / Notes",    placeholder: "e.g. comfortable; next time wear heavier socks"),
                ActivityField(key: "courseName",  label: "Course Name",        placeholder: "e.g. Pebble Beach"),
            ]
        case .running:
            return [
                ActivityField(key: "outerwear",  label: "Outerwear / Jacket", placeholder: "e.g. blue windbreaker, light fleece"),
                ActivityField(key: "topLong",     label: "Long Sleeve Top",    placeholder: "e.g. grey tech long sleeve"),
                ActivityField(key: "topShort",    label: "Short Sleeve / Tee", placeholder: "e.g. race tee"),
                ActivityField(key: "bottoms",     label: "Bottoms",            placeholder: "e.g. running tights, yoga pants"),
                ActivityField(key: "head",        label: "Head",               placeholder: "e.g. purple headband, hat"),
                ActivityField(key: "hands",       label: "Hands",              placeholder: "e.g. light mitts"),
                ActivityField(key: "feet",        label: "Feet / Shoes",       placeholder: "e.g. light socks, trail shoes"),
                ActivityField(key: "notes",       label: "Notes / Outcome",    placeholder: "e.g. was too warm, should have skipped the jacket"),
            ]
        }
    }

    var activityWeatherFields: [ActivityWeatherField] {
        switch self {
        case .golf:    return [.timeOfDay, .lowTemp, .highTemp, .wetGround]
        case .running: return [.timeOfDay]
        }
    }

    var timeOfDayLabel: String {
        switch self {
        case .golf:    return "Tee Time"
        case .running: return "Time of Run"
        }
    }

    var timeOfDayPlaceholder: String {
        switch self {
        case .golf:    return "e.g. 9:00 AM"
        case .running: return "e.g. 3:00 PM"
        }
    }
}

struct ActivityField: Identifiable {
    let key: String
    let label: String
    let placeholder: String
    var id: String { key }
}

enum ActivityWeatherField: Hashable {
    case timeOfDay, lowTemp, highTemp, wetGround
}
