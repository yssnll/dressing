import Foundation

struct OutfitRecommendationService {
    func recommendations(from wardrobe: [WardrobeItem], context: DestinationContext, weather: WeatherSnapshot, excludedIDs: Set<UUID> = []) -> [Outfit] {
        let available = wardrobe.filter { !excludedIDs.contains($0.id) }
        guard !available.isEmpty else { return [] }

        let tops = ranked(available.filter { $0.category == .top }, context: context)
        let bottoms = ranked(available.filter { $0.category == .bottom }, context: context)
        let outerwear = ranked(available.filter { $0.category == .outerwear }, context: context)
        let shoes = ranked(available.filter { $0.category == .shoes }, context: context)
        let accessories = ranked(available.filter { $0.category == .accessory }, context: context)

        let needsLayer = weather.morningTemperature < 14 || weather.rainProbability >= 40
        let warmEnoughForCasual = weather.afternoonTemperature >= 19
        let practicalShoes = weather.rainProbability >= 40 ? shoes.first(where: { $0.style.localizedCaseInsensitiveContains("technique") }) : nil

        let firstTop = tops.first ?? available.first!
        let secondTop = tops.dropFirst().first ?? firstTop
        let firstBottom = bottoms.first ?? available.first!
        let secondBottom = bottoms.dropFirst().first ?? firstBottom
        let firstShoes = practicalShoes ?? shoes.first ?? available.first!
        let secondShoes = shoes.dropFirst().first ?? firstShoes
        let layer = needsLayer ? outerwear.first : nil
        let elegantLayer = outerwear.first(where: { $0.formality == .formal }) ?? outerwear.first
        let accessory = weather.morningTemperature < 10 ? accessories.first : nil

        let outfitOneItems = unique([firstTop, firstBottom, firstShoes, layer, accessory])
        let outfitTwoItems = unique([secondTop, firstBottom, secondShoes, elegantLayer])
        let outfitThreeItems = unique([firstTop, secondBottom, secondShoes, warmEnoughForCasual ? nil : layer])

        return [
            Outfit(title: "Casual chic", subtitle: "Équilibre parfait", items: outfitOneItems, reason: reason(for: context, weather: weather, practical: practicalShoes != nil), accent: .blue),
            Outfit(title: context == .event || context == .evening ? "Élégance sobre" : "Smart de tous les jours", subtitle: "Prêt pour les imprévus", items: outfitTwoItems, reason: "Une silhouette plus habillée, facile à faire évoluer du jour au soir.", accent: .coral),
            Outfit(title: "Confort maîtrisé", subtitle: "Liberté de mouvement", items: outfitThreeItems, reason: "Des pièces polyvalentes pour rester à l'aise sans perdre le style.", accent: .green)
        ].filter { !$0.items.isEmpty }
    }

    private func ranked(_ items: [WardrobeItem], context: DestinationContext) -> [WardrobeItem] {
        items.sorted {
            score($0, context: context) > score($1, context: context)
        }
    }

    private func score(_ item: WardrobeItem, context: DestinationContext) -> Int {
        var value = 0
        if item.formality == context.preferredFormality { value += 5 }
        if context == .sport && item.formality == .technical { value += 8 }
        if context == .travel && item.style == "Polyvalent" { value += 3 }
        if item.lastWorn == nil { value += 2 }
        if let lastWorn = item.lastWorn {
            let daysSinceWorn = Calendar.current.dateComponents([.day], from: lastWorn, to: Date()).day ?? 0
            value += min(4, max(0, daysSinceWorn / 10))
        }
        return value
    }

    private func unique(_ items: [WardrobeItem?]) -> [WardrobeItem] {
        var result: [WardrobeItem] = []
        for item in items.compactMap({ $0 }) where !result.contains(item) {
            result.append(item)
        }
        return result
    }

    private func reason(for context: DestinationContext, weather: WeatherSnapshot, practical: Bool) -> String {
        let contextText = context == .event ? "adaptée à ton événement" : context.subtitle.lowercased()
        let rainText = practical ? "Les chaussures techniques sécurisent tes déplacements sous la pluie." : "Les couches restent faciles à retirer si la journée se réchauffe."
        return "Une tenue \(contextText). \(rainText)"
    }
}