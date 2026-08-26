import Foundation

enum ClothingCategory: String, CaseIterable, Codable, Identifiable {
    case top
    case bottom
    case outerwear
    case shoes
    case accessory

    var id: String { rawValue }

    var title: String {
        switch self {
        case .top: return "Hauts"
        case .bottom: return "Bas"
        case .outerwear: return "Vestes"
        case .shoes: return "Chaussures"
        case .accessory: return "Accessoires"
        }
    }

    var icon: String {
        switch self {
        case .top: return "tshirt"
        case .bottom: return "figure.walk"
        case .outerwear: return "cloud"
        case .shoes: return "shoeprints.fill"
        case .accessory: return "eyeglasses"
        }
    }
}

enum ClothingFormality: String, CaseIterable, Codable, Identifiable {
    case casual
    case smart
    case formal
    case technical

    var id: String { rawValue }

    var title: String {
        switch self {
        case .casual: return "Casual"
        case .smart: return "Chic décontracté"
        case .formal: return "Élégant"
        case .technical: return "Technique"
        }
    }
}

enum ClothingSeason: String, CaseIterable, Codable, Identifiable {
    case spring
    case summer
    case autumn
    case winter
    case all

    var id: String { rawValue }

    var title: String {
        switch self {
        case .spring: return "Printemps"
        case .summer: return "Été"
        case .autumn: return "Automne"
        case .winter: return "Hiver"
        case .all: return "Toute l'année"
        }
    }
}

struct WardrobeItem: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var category: ClothingCategory
    var color: String
    var material: String
    var style: String
    var season: ClothingSeason
    var formality: ClothingFormality
    var imageData: Data?
    var lastWorn: Date?

    init(
        id: UUID = UUID(),
        name: String,
        category: ClothingCategory,
        color: String,
        material: String = "Coton",
        style: String = "Polyvalent",
        season: ClothingSeason = .all,
        formality: ClothingFormality = .casual,
        imageData: Data? = nil,
        lastWorn: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.color = color
        self.material = material
        self.style = style
        self.season = season
        self.formality = formality
        self.imageData = imageData
        self.lastWorn = lastWorn
    }
}