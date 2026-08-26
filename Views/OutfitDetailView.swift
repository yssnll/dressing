import SwiftUI

struct OutfitDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let outfit: Outfit

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(outfit.title)
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                            Text(outfit.subtitle)
                                .foregroundStyle(Color.wardrobeMuted)
                        }
                        Spacer()
                        Text("\(outfit.totalPieces) pièces")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.wardrobeInk)
                            .padding(10)
                            .background(Color.wardrobeCream, in: Capsule())
                    }
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(outfit.items) { item in
                            VStack(alignment: .leading, spacing: 8) {
                                ClothingThumbnail(item: item)
                                    .frame(height: 150)
                                Text(item.name)
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                Text("\(item.color) · \(item.material)")
                                    .font(.system(size: 11, design: .rounded))
                                    .foregroundStyle(Color.wardrobeMuted)
                            }
                            .padding(10)
                            .background(Color.white, in: RoundedRectangle(cornerRadius: 18))
                        }
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Pourquoi ça marche", systemImage: "lightbulb.fill")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                        Text(outfit.reason)
                            .font(.system(size: 14, design: .rounded))
                            .foregroundStyle(Color.wardrobeMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(18)
                    .background(Color.wardrobeCream, in: RoundedRectangle(cornerRadius: 20))
                }
                .padding(20)
            }
            .background(Color.wardrobeBackground.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var value: UInt64 = 0
        scanner.scanHexInt64(&value)
        self.init(
            .sRGB,
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255,
            opacity: 1
        )
    }
}