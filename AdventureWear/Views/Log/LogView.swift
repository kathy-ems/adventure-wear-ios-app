import SwiftUI

struct LogView: View {
    @EnvironmentObject var weatherService: WeatherService
    @StateObject private var viewModel = LogViewModel()

    var body: some View {
        NavigationStack {
            Form {
                weatherSection
                activitySection
                ActivityWeatherSection(activity: viewModel.selectedActivity, values: $viewModel.activityWeather)
                clothingSection
                submitSection
            }
            .navigationTitle("Log Outfit")
            .onChange(of: viewModel.selectedActivity) { _, _ in viewModel.resetForm() }
            .alert("Saved!", isPresented: $viewModel.showSuccess) {
                Button("OK") {}
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    private var weatherSection: some View {
        Section("Current Weather") {
            if weatherService.isLoading {
                HStack {
                    ProgressView()
                    Text("Fetching weather…").foregroundStyle(.secondary)
                }
            } else if let w = weatherService.snapshot {
                HStack {
                    Label(w.tempDisplay, systemImage: "thermometer")
                    if let fl = w.feelsLikeDisplay {
                        Text(fl).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(w.conditions).foregroundStyle(.secondary)
                }
                if let wind = w.windDisplay {
                    Label(wind, systemImage: "wind").foregroundStyle(.secondary)
                }
            } else {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                    Text(weatherService.error ?? "Weather unavailable")
                        .foregroundStyle(.secondary)
                }
                Button("Retry") { Task { await weatherService.fetch() } }
            }
        }
    }

    private var activitySection: some View {
        Section("Activity") {
            Picker("Activity", selection: $viewModel.selectedActivity) {
                ForEach(Activity.allCases) { a in
                    Text(a.rawValue).tag(a)
                }
            }
            .pickerStyle(.segmented)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        }
    }

    private var clothingSection: some View {
        Section("What I Wore") {
            ClothingFormView(
                fields: viewModel.selectedActivity.schema,
                values: $viewModel.clothing
            )
        }
    }

    private var submitSection: some View {
        Section {
            Button {
                guard let snapshot = weatherService.snapshot else { return }
                Task { await viewModel.submit(weather: snapshot) }
            } label: {
                if viewModel.isSubmitting {
                    ProgressView().frame(maxWidth: .infinity)
                } else {
                    Text("Save Entry").frame(maxWidth: .infinity)
                }
            }
            .disabled(viewModel.isSubmitting || weatherService.snapshot == nil)
        }
    }
}
