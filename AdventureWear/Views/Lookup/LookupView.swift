import SwiftUI

struct LookupView: View {
    @EnvironmentObject var weatherService: WeatherService
    @StateObject private var viewModel = LookupViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Weather card
                CurrentWeatherCard(
                    weather: weatherService.snapshot,
                    isLoading: weatherService.isLoading,
                    tempOverride: $viewModel.tempOverride
                )
                .padding(.horizontal)
                .padding(.top, 8)

                // Activity picker
                Picker("Activity", selection: $viewModel.selectedActivity) {
                    ForEach(Activity.allCases) { a in Text(a.rawValue).tag(a) }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 10)

                Divider()

                // Results
                Group {
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView("Searching…")
                        Spacer()
                    } else if viewModel.results.isEmpty {
                        ContentUnavailableView(
                            "No Matches",
                            systemImage: "tshirt",
                            description: Text("No \(viewModel.selectedActivity.rawValue) entries within 8° of the selected temperature.")
                        )
                    } else {
                        List(viewModel.results) { entry in
                            EntryResultRow(entry: entry)
                                .listRowSeparator(.visible)
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle("Lookup")
            .onChange(of: viewModel.selectedActivity) { _, _ in triggerSearch() }
            .onChange(of: viewModel.tempOverride)     { _, _ in triggerSearch() }
            .onChange(of: weatherService.snapshot)    { _, snap in
                guard viewModel.tempOverride.isEmpty else { return }
                if let temp = snap?.temp { Task { await viewModel.search(currentTemp: temp) } }
            }
        }
    }

    private func triggerSearch() {
        guard let temp = viewModel.effectiveTemp(fallback: weatherService.snapshot?.temp) else { return }
        Task { await viewModel.search(currentTemp: temp) }
    }
}
