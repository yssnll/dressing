import Foundation

enum DestinationContext: String, CaseIterable, Identifiable {
    case everyday
    case work
    case evening
    case sport
    case travel
    case event

    var id: String { rawValue }

    var title: String {
        switch self {
        case .everyday: return "Quotidien"
        case .work: return "Travail"
        case .evening: return "Soirée"
        case .sport: return "Sport"
        case .travel: return "Voyage"
        case .event: return "Événement"
        }
    }

    var icon: String {
        switch self {
        case .everyday: return "sun.max.fill"
        case .work: return "briefcase.fill"
        case .evening: return "moon.stars.fill"
        case .sport: return "figure.run"
        case .travel: return "airplane"
        case .event: return "sparkles"
        }
    }

    var preferredFormality: ClothingFormality {
        switch self {
        case .everyday, .sport: return .casual
        case .work, .travel: return .smart
        case .evening, .event: return .formal
        }
    }

    var subtitle: String {
        switch self {
        case .everyday: return "Une tenue facile à vivre"
        case .work: return "Business casual"
        case .evening: return "Pour sortir avec style"
        case .sport: return "Bouger confortablement"
        case .travel: return "Pratique et polyvalent"
        case .event: return "Tenue adaptée au lieu"
        }
    }
}

struct WeatherSnapshot: Codable, Hashable {
    var morningTemperature: Int
    var afternoonTemperature: Int
    var eveningTemperature: Int
    var condition: String
    var icon: String
    var rainProbability: Int
    var windKmh: Int
    var feelsLike: Int

    var temperatureRange: String {
        "\(morningTemperature)° → \(afternoonTemperature)°"
    }
}

struct Outfit: Identifiable, Hashable {
    var id = UUID()
    var title: String
    var subtitle: String
    var items: [WardrobeItem]
    var reason: String
    var accent: OutfitAccent

    var totalPieces: Int { items.count }
}

enum OutfitAccent: String, CaseIterable {
    case blue
    case coral
    case green

    var color: String {
        switch self {
        case .blue: return "3A6FF7"
        case .coral: return "EA705E"
        case .green: return "399B77"
        }
    }
}