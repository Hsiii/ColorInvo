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
                    Code39BarcodeView(value: carrierCode)
                        .frame(height: 78)
                    Text(carrierCode)
                        .font(.system(.headline, design: .monospaced, weight: .semibold))
                        .foregroundStyle(.black)
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
        .containerBackground(.white, for: .widget)
    }
}

struct InvoiceCarrierWidget: Widget {
    let kind = "InvoiceCarrierWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CarrierProvider()) { entry in
            CarrierWidgetView(entry: entry)
        }
        .configurationDisplayName("載具條碼")
        .description("在中尺寸 Widget 顯示手機發票載具一維條碼。")
        .supportedFamilies([.systemMedium])
    }
}

@main
struct InvoiceCarrierWidgetBundle: WidgetBundle {
    var body: some Widget {
        InvoiceCarrierWidget()
    }
}

#Preview(as: .systemMedium) {
    InvoiceCarrierWidget()
} timeline: {
    CarrierEntry(
        date: .now,
        settings: CarrierSettings(carrierCode: "/AB12+CD")
    )
}
