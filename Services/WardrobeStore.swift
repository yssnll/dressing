import Foundation
import Combine

@MainActor
final class WardrobeStore: ObservableObject {
    @Published var items: [WardrobeItem] {
        didSet { save() }
    }

    private let storageKey = "smart-wardrobe-items"

    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode([WardrobeItem].self, from: data) {
            items = saved
        } else {
            items = Self.demoItems
        }
    }

    func add(_ item: WardrobeItem) {
        items.insert(item, at: 0)
    }

    func delete(_ item: WardrobeItem) {
        items.removeAll { $0.id == item.id }
    }

    func markWorn(_ item: WardrobeItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].lastWorn = Date()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    static let demoItems: [WardrobeItem] = [
        WardrobeItem(name: "Chemise blanche", category: .top, color: "Blanc", material: "Coton", style: "Minimal", season: .all, formality: .smart),
        WardrobeItem(name: "Chemise bleue", category: .top, color: "Bleu ciel", material: "Lin", style: "Business casual", season: .summer, formality: .smart),
        WardrobeItem(name: "T-shirt écru", category: .top, color: "Écru", material: "Coton bio", style: "Décontracté", season: .summer, formality: .casual),
        WardrobeItem(name: "Pantalon gris", category: .bottom, color: "Gris anthracite", material: "Laine froide", style: "Droit", season: .all, formality: .smart),
        WardrobeItem(name: "Pantalon beige", category: .bottom, color: "Beige", material: "Coton", style: "Chino", season: .spring, formality: .smart),
        WardrobeItem(name: "Jean brut", category: .bottom, color: "Indigo", material: "Denim", style: "Droit", season: .all, formality: .casual),
        WardrobeItem(name: "Trench sable", category: .outerwear, color: "Sable", material: "Gabardine", style: "Classique", season: .autumn, formality: .smart),
        WardrobeItem(name: "Veste noire", category: .outerwear, color: "Noir", material: "Laine", style: "Tailoring", season: .all, formality: .formal),
        WardrobeItem(name: "Surchemise kaki", category: .outerwear, color: "Kaki", material: "Coton", style: "Workwear", season: .autumn, formality: .casual),
        WardrobeItem(name: "Mocassins noirs", category: .shoes, color: "Noir", material: "Cuir", style: "Classique", season: .all, formality: .formal),
        WardrobeItem(name: "Sneakers blanches", category: .shoes, color: "Blanc", material: "Cuir", style: "Minimal", season: .all, formality: .casual),
        WardrobeItem(name: "Baskets de marche", category: .shoes, color: "Gris", material: "Mesh", style: "Technique", season: .all, formality: .technical),
        WardrobeItem(name: "Écharpe marine", category: .accessory, color: "Bleu marine", material: "Laine", style: "Classique", season: .winter, formality: .smart),
        WardrobeItem(name: "Ceinture cuir", category: .accessory, color: "Marron", material: "Cuir", style: "Classique", season: .all, formality: .smart)
    ]
}