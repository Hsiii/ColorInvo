import SwiftUI
import WidgetKit

struct CarrierEntry: TimelineEntry {
    let date: Date
    let settings: CarrierSettings
}

struct CarrierProvider: TimelineProvider {
    func placeholder(in context: Context) -> CarrierEntry {
        CarrierEntry(
            date: Date(),
            settings: CarrierSettings(carrierCode: "/AB12+CD")
        )
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (CarrierEntry) -> Void
    ) {
        completion(CarrierEntry(date: Date(), settings: CarrierStore.load()))
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<CarrierEntry>) -> Void
    ) {
        let entry = CarrierEntry(date: Date(), settings: CarrierStore.load())
        completion(Timeline(entries: [entry], policy: .never))
    }
}

struct CarrierWidgetView: View {
    let entry: CarrierEntry

    private var carrierCode: String {
        entry.settings.carrierCode
    }

    var body: some View {
        CarrierWidgetContentView(
            carrierCode: carrierCode,
            palette: entry.settings.palette,
            dominantColors: entry.settings.wallpaperDominantColors,
            waveColor: entry.settings.waveColor,
            showsWave: entry.settings.showsWave,
            showsBarcodeValue: entry.settings.showsBarcodeValue
        )
        .containerBackground(entry.settings.palette.backgroundColor.color, for: .widget)
    }
}

struct ColorInvoWidget: Widget {
    let kind = CarrierWidgetKind.colorInvo

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CarrierProvider()) { entry in
            CarrierWidgetView(entry: entry)
        }
        .configurationDisplayName("app.title")
        .description("widget.description")
        .supportedFamilies([.systemMedium])
        .contentMarginsDisabled()
    }
}

@main
struct ColorInvoWidgetBundle: WidgetBundle {
    var body: some Widget {
        ColorInvoWidget()
    }
}

#Preview(as: .systemMedium) {
    ColorInvoWidget()
} timeline: {
    CarrierEntry(
        date: .now,
        settings: CarrierSettings(carrierCode: "/AB12+CD")
    )
}
