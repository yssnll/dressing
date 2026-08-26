import SwiftUI

@main
struct SmartWardrobeApp: App {
    @StateObject private var store = WardrobeStore()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(store)
                .preferredColorScheme(.light)
        }
    }
}