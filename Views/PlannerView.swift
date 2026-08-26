import SwiftUI

struct PlannerView: View {
    @EnvironmentObject private var store: WardrobeStore
    @State private var destination = "Paris"
    @State private var date = Date()
    @State private var startTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var endTime = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var context: DestinationContext = .everyday
    @State private var weather: WeatherSnapshot?
    @State private var outfits: [Outfit] = []
    @State private var isLoading = false
    @State private var hasPlanned = false
    @State private var feedbackMessage: String?

    private let weatherService = DemoWeatherService()
    private let recommendation = OutfitRecommendationService()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    ScreenTitle("Planifie ta tenue", eyebrow: "TON PROCHAIN RENDEZ-VOUS", subtitle: "Donne-moi le lieu et le contexte. Je m'occupe du reste.")
                    destinationForm
                    if let feedbackMessage {
                        Label(feedbackMessage, systemImage: "checkmark.circle.fill")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.wardrobeGreen)
                    }
                    if let weather, hasPlanned {
                        weatherResult(weather)
                        recommendationResult
                    }
                }
                .padding(20)
            }
            .background(Color.wardrobeBackground.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var destinationForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "location.fill")
                    .foregroundStyle(Color.wardrobeCoral)
                TextField("Destination", text: $destination)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
            }
            Divider()
            DatePicker("Date", selection: $date, displayedComponents: .date)
            HStack {
                DatePicker("De", selection: $startTime, displayedComponents: .hourAndMinute)
                DatePicker("À", selection: $endTime, displayedComponents: .hourAndMinute)
            }
            VStack(alignment: .leading, spacing: 10) {
                Text("Contexte")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(DestinationContext.allCases) { value in
                        Button {
                            context = value
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: value.icon)
                                Text(value.title)
                                    .lineLimit(1)
                            }
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(context == value ? .white : Color.wardrobeInk)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .background(context == value ? Color.wardrobeInk : Color.wardrobeBackground, in: RoundedRectangle(cornerRadius: 13))
                        }
                    }
                }
            }
            Button(action: plan) {
                HStack {
                    if isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Image(systemName: "wand.and.stars")
                    }
                    Text(isLoading ? "Analyse en cours…" : "Proposer mes tenues")
                }
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.wardrobeInk, in: RoundedRectangle(cornerRadius: 17))
            }
            .disabled(isLoading || destination.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(18)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 24))
    }

    private func weatherResult(_ weather: WeatherSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Météo prévue")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Spacer()
                Image(systemName: weather.icon)
                    .foregroundStyle(Color.wardrobeCoral)
            }
            HStack {
                weatherMetric(title: "Matin", value: "\(weather.morningTemperature)°")
                weatherMetric(title: "Après-midi", value: "\(weather.afternoonTemperature)°")
                weatherMetric(title: "Pluie", value: "\(weather.rainProbability)%")
                weatherMetric(title: "Vent", value: "\(weather.windKmh) km/h")
            }
            if weather.rainProbability >= 40 {
                Label("Attention : pluie prévue. Une pièce imperméable est recommandée.", systemImage: "cloud.rain.fill")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.wardrobeInk)
            }
        }
        .padding(18)
        .background(Color.wardrobeCream, in: RoundedRectangle(cornerRadius: 24))
    }

    private func weatherMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, design: .rounded))
                .foregroundStyle(Color.wardrobeMuted)
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var recommendationResult: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("3 idées pour \(destination)")
                    .font(.system(size: 21, weight: .bold, design: .rounded))
                Spacer()
                Text(context.title)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.wardrobeCoral)
            }
            ForEach(outfits) { outfit in
                CompactOutfitRow(outfit: outfit)
            }
            HStack(spacing: 10) {
                Button {
                    feedbackMessage = "Je garde ce retour pour affiner tes prochaines suggestions."
                    outfits = recommendation.recommendations(from: store.items, context: .evening, weather: weather ?? WeatherSnapshot(morningTemperature: 14, afternoonTemperature: 20, eveningTemperature: 16, condition: "Variable", icon: "cloud.sun.fill", rainProbability: 20, windKmh: 10, feelsLike: 14))
                } label: {
                    Label("Plus élégant", systemImage: "sparkles")
                }
                .buttonStyle(FeedbackButtonStyle())
                Button {
                    feedbackMessage = "D'accord — j'écarte cette combinaison."
                    outfits = outfits.dropFirst().map { $0 }
                } label: {
                    Label("Je n'aime pas", systemImage: "hand.thumbsdown")
                }
                .buttonStyle(FeedbackButtonStyle())
            }
        }
    }

    private func plan() {
        isLoading = true
        feedbackMessage = nil
        Task {
            do {
                let result = try await weatherService.forecast(for: destination, date: date)
                await MainActor.run {
                    weather = result
                    outfits = recommendation.recommendations(from: store.items, context: context, weather: result)
                    hasPlanned = true
                    isLoading = false
                }
            } catch {
                await MainActor.run { isLoading = false }
            }
        }
    }
}

struct CompactOutfitRow: View {
    let outfit: Outfit

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                ForEach(outfit.items.prefix(3)) { item in
                    ClothingThumbnail(item: item)
                        .frame(width: 52, height: 52)
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(outfit.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                Text(outfit.items.map(\.name).joined(separator: " · "))
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(Color.wardrobeMuted)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(10)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct FeedbackButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundStyle(Color.wardrobeInk)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.wardrobeBackground, in: Capsule())
            .opacity(configuration.isPressed ? 0.65 : 1)
    }
}