import Foundation

protocol WeatherService {
    func forecast(for destination: String, date: Date) async throws -> WeatherSnapshot
}

struct DemoWeatherService: WeatherService {
    func forecast(for destination: String, date: Date) async throws -> WeatherSnapshot {
        try await Task.sleep(for: .milliseconds(350))
        let normalized = destination.folding(options: .diacriticInsensitive, locale: .current).lowercased()

        if normalized.contains("londres") || normalized.contains("london") {
            return WeatherSnapshot(morningTemperature: 11, afternoonTemperature: 17, eveningTemperature: 13, condition: "Averses éparses", icon: "cloud.rain.fill", rainProbability: 65, windKmh: 19, feelsLike: 10)
        }

        if normalized.contains("bruxelles") || normalized.contains("brussels") {
            return WeatherSnapshot(morningTemperature: 12, afternoonTemperature: 18, eveningTemperature: 14, condition: "Nuageux", icon: "cloud.sun.fill", rainProbability: 35, windKmh: 14, feelsLike: 12)
        }

        if normalized.contains("paris") {
            return WeatherSnapshot(morningTemperature: 12, afternoonTemperature: 18, eveningTemperature: 15, condition: "Risque de pluie", icon: "cloud.sun.rain.fill", rainProbability: 45, windKmh: 12, feelsLike: 11)
        }

        return WeatherSnapshot(morningTemperature: 14, afternoonTemperature: 21, eveningTemperature: 16, condition: "Éclaircies", icon: "cloud.sun.fill", rainProbability: 20, windKmh: 10, feelsLike: 14)
    }
}