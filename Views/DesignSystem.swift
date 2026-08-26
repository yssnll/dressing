import SwiftUI

extension Color {
    static let wardrobeInk = Color(red: 0.11, green: 0.12, blue: 0.16)
    static let wardrobeMuted = Color(red: 0.42, green: 0.43, blue: 0.47)
    static let wardrobeBackground = Color(red: 0.97, green: 0.96, blue: 0.94)
    static let wardrobeCream = Color(red: 0.91, green: 0.88, blue: 0.82)
    static let wardrobeBlue = Color(red: 0.23, green: 0.43, blue: 0.97)
    static let wardrobeCoral = Color(red: 0.91, green: 0.44, blue: 0.37)
    static let wardrobeGreen = Color(red: 0.22, green: 0.61, blue: 0.47)
}

struct ScreenTitle: View {
    let eyebrow: String
    let title: String
    let subtitle: String?

    init(_ title: String, eyebrow: String = "", subtitle: String? = nil) {
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            if !eyebrow.isEmpty {
                Text(eyebrow.uppercased())
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(1.7)
                    .foregroundStyle(Color.wardrobeCoral)
            }
            Text(title)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(Color.wardrobeInk)
            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.wardrobeMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct Pill: View {
    let text: String
    var color: Color = .wardrobeInk

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.10), in: Capsule())
    }
}

struct EmptyPhotoView: View {
    let category: ClothingCategory

    var body: some View {
        ZStack {
            LinearGradient(colors: [.wardrobeCream, .white], startPoint: .topLeading, endPoint: .bottomTrailing)
            Image(systemName: category.icon)
                .font(.system(size: 34, weight: .medium))
                .foregroundStyle(Color.wardrobeInk.opacity(0.45))
        }
    }
}