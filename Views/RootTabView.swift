import SwiftUI
import UIKit

struct RootTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Aujourd'hui", systemImage: "sparkles") }
            WardrobeView()
                .tabItem { Label("Dressing", systemImage: "tshirt") }
            PlannerView()
                .tabItem { Label("Planifier", systemImage: "location.fill") }
        }
        .tint(.wardrobeInk)
    }
}

struct HomeView: View {
    @EnvironmentObject private var store: WardrobeStore
    @State private var selectedContext: DestinationContext = .everyday
    @State private var outfits: [Outfit] = []
    @State private var weather = WeatherSnapshot(morningTemperature: 14, afternoonTemperature: 21, eveningTemperature: 16, condition: "Éclaircies", icon: "cloud.sun.fill", rainProbability: 20, windKmh: 10, feelsLike: 14)
    @State private var selectedOutfit: Outfit?

    private let recommendation = OutfitRecommendationService()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    ScreenTitle("Ton style, aujourd'hui", eyebrow: "SMART WARDROBE", subtitle: "Des tenues pensées pour ta journée et les pièces que tu possèdes.")
                    weatherCard
                    contextPicker
                    HStack {
                        Text("Tes suggestions")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.wardrobeInk)
                        Spacer()
                        Text("\(outfits.count) looks")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.wardrobeMuted)
                    }
                    ForEach(outfits) { outfit in
                        OutfitCard(outfit: outfit) {
                            selectedOutfit = outfit
                        }
                    }
                }
                .padding(20)
            }
            .background(Color.wardrobeBackground.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $selectedOutfit) { outfit in
                OutfitDetailView(outfit: outfit)
            }
            .onAppear(perform: refresh)
            .onChange(of: selectedContext) { _, _ in refresh() }
        }
    }

    private var weatherCard: some View {
        HStack(spacing: 16) {
            Image(systemName: weather.icon)
                .font(.system(size: 32, weight: .medium))
                .foregroundStyle(Color.wardrobeInk)
                .frame(width: 54, height: 54)
                .background(Color.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 18))
            VStack(alignment: .leading, spacing: 4) {
                Text("Bruxelles · Aujourd'hui")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                Text(weather.condition)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(Color.wardrobeMuted)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text(weather.temperatureRange)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Text("Ressenti \(weather.feelsLike)°")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(Color.wardrobeMuted)
            }
        }
        .padding(16)
        .background(Color.wardrobeCream, in: RoundedRectangle(cornerRadius: 24))
        .overlay(alignment: .bottomLeading) {
            if weather.rainProbability >= 40 {
                Label("Pluie possible · prends une couche", systemImage: "umbrella.fill")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.wardrobeInk)
                    .padding(.leading, 16)
                    .padding(.bottom, -25)
            }
        }
    }

    private var contextPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Contexte")
                .font(.system(size: 16, weight: .bold, design: .rounded))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(DestinationContext.allCases) { context in
                        Button {
                            selectedContext = context
                        } label: {
                            Label(context.title, systemImage: context.icon)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(selectedContext == context ? .white : Color.wardrobeInk)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(selectedContext == context ? Color.wardrobeInk : Color.white, in: Capsule())
                        }
                    }
                }
            }
        }
    }

    private func refresh() {
        outfits = recommendation.recommendations(from: store.items, context: selectedContext, weather: weather)
    }
}

struct OutfitCard: View {
    let outfit: Outfit
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(outfit.title)
                            .font(.system(size: 21, weight: .bold, design: .rounded))
                        Text(outfit.subtitle)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(Color.wardrobeMuted)
                    }
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.wardrobeInk)
                        .frame(width: 32, height: 32)
                        .background(Color.wardrobeBackground, in: Circle())
                }
                HStack(spacing: 8) {
                    ForEach(outfit.items.prefix(4)) { item in
                        ClothingThumbnail(item: item)
                    }
                }
                Text(outfit.reason)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(Color.wardrobeInk.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(18)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 24))
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(hex: outfit.accent.color))
                    .frame(width: 5)
                    .padding(.vertical, 18)
            }
        }
        .buttonStyle(.plain)
    }
}

struct ClothingThumbnail: View {
    let item: WardrobeItem

    var body: some View {
        Group {
            if let data = item.imageData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                EmptyPhotoView(category: item.category)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 92)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}