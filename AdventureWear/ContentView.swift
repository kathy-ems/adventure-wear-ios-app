import SwiftUI

struct ContentView: View {
    @StateObject private var weatherService = WeatherService()

    var body: some View {
        TabView {
            LogView()
                .tabItem { Label("Log", systemImage: "plus.circle") }
            LookupView()
                .tabItem { Label("Lookup", systemImage: "magnifyingglass") }
        }
        .environmentObject(weatherService)
        .task { await weatherService.fetch() }
    }
}
