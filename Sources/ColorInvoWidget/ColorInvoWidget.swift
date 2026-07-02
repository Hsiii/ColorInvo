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
        ZStack {
            if CarrierCode.isValid(carrierCode) {
                VStack(spacing: 12) {
                    Code39BarcodeView(
                        value: carrierCode,
                        barColor: entry.settings.palette.barColor.color,
                        backgroundColor: entry.settings.palette.backgroundColor.color
                    )
                        .frame(height: 78)
                    Text(carrierCode)
                        .font(.system(.headline, design: .monospaced, weight: .semibold))
                        .foregroundStyle(entry.settings.palette.barColor.color)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 14)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "barcode.viewfinder")
                        .font(.title2)
                    Text("開啟 App 儲存載具")
                        .font(.headline)
                }
                .foregroundStyle(.secondary)
            }
        }
        .containerBackground(entry.settings.palette.backgroundColor.color, for: .widget)
    }
}

struct ColorInvoWidget: Widget {
    let kind = "ColorInvoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CarrierProvider()) { entry in
            CarrierWidgetView(entry: entry)
        }
        .configurationDisplayName("app.title")
        .description("widget.description")
        .supportedFamilies([.systemMedium])
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
