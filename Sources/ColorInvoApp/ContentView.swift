import SwiftUI
import WidgetKit

struct ContentView: View {
    @State private var draftCode: String
    @State private var draftPalette: BarcodePalette
    @State private var savedCode: String
    @State private var savedPalette: BarcodePalette
    @State private var didSave = false

    private var normalizedCode: String {
        CarrierCode.normalize(draftCode)
    }

    private var isValid: Bool {
        CarrierCode.isValid(normalizedCode)
    }

    init() {
        let settings = CarrierStore.load()
        _draftCode = State(initialValue: settings.carrierCode)
        _draftPalette = State(initialValue: settings.palette)
        _savedCode = State(initialValue: settings.carrierCode)
        _savedPalette = State(initialValue: settings.palette)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    barcodePreview
                    carrierForm
                    colorControls
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("app.title")
        }
    }

    private var barcodePreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(savedCode.isEmpty ? "尚未儲存載具" : savedCode)
                .font(.system(.title3, design: .monospaced, weight: .semibold))
                .foregroundStyle(savedCode.isEmpty ? .secondary : .primary)

            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(savedPalette.backgroundColor.color)

                if CarrierCode.isValid(savedCode) {
                    VStack(spacing: 10) {
                        Code39BarcodeView(
                            value: savedCode,
                            barColor: savedPalette.barColor.color,
                            backgroundColor: savedPalette.backgroundColor.color
                        )
                            .frame(height: 88)
                        Text(savedCode)
                            .font(.system(.callout, design: .monospaced, weight: .medium))
                            .foregroundStyle(savedPalette.barColor.color)
                    }
                    .padding(16)
                } else {
                    Text("儲存後會顯示條碼")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 144)
            .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: 8)
        }
    }

    private var carrierForm: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("手機發票載具號碼")
                .font(.headline)

            TextField("/AB12+CD", text: $draftCode)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .keyboardType(.asciiCapable)
                .font(.system(.title3, design: .monospaced, weight: .semibold))
                .textFieldStyle(.roundedBorder)
                .onChange(of: draftCode) { _, newValue in
                    draftCode = CarrierCode.normalize(newValue)
                    didSave = false
                }

            Label(
                isValid ? "格式正確" : CarrierCode.validationMessage(for: draftCode),
                systemImage: isValid ? "checkmark.circle.fill" : "exclamationmark.circle"
            )
            .font(.callout)
            .foregroundStyle(isValid ? .green : .secondary)

            Button {
                saveCarrier()
            } label: {
                Label(didSave ? "已儲存" : "儲存載具", systemImage: didSave ? "checkmark" : "tray.and.arrow.down")
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!isValid || !draftPalette.meetsCommercialGuidance)
        }
        .padding(16)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 14, x: 0, y: 6)
    }

    private var colorControls: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("條碼顏色")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(BarcodePalette.presets) { preset in
                        Button {
                            draftPalette = preset
                            didSave = false
                        } label: {
                            PresetSwatch(
                                palette: preset,
                                isSelected: preset == draftPalette
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(preset.name)
                    }
                }
                .padding(.vertical, 2)
            }

            VStack(spacing: 12) {
                ColorPicker(
                    "線條",
                    selection: Binding(
                        get: { draftPalette.barColor.color },
                        set: { color in
                            draftPalette = draftPalette.replacing(
                                barColor: RGBAColor(color: color)
                            )
                            didSave = false
                        }
                    ),
                    supportsOpacity: false
                )

                ColorPicker(
                    "背景",
                    selection: Binding(
                        get: { draftPalette.backgroundColor.color },
                        set: { color in
                            draftPalette = draftPalette.replacing(
                                backgroundColor: RGBAColor(color: color)
                            )
                            didSave = false
                        }
                    ),
                    supportsOpacity: false
                )
            }

            Label(
                draftPalette.standardMessage,
                systemImage: draftPalette.meetsCommercialGuidance
                    ? "checkmark.shield.fill"
                    : "exclamationmark.triangle"
            )
            .font(.callout)
            .foregroundStyle(draftPalette.meetsCommercialGuidance ? .green : .orange)
        }
        .padding(16)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 14, x: 0, y: 6)
    }

    private func saveCarrier() {
        guard let carrierCode = CarrierCode(normalizedCode) else {
            return
        }

        let settings = CarrierSettings(
            carrierCode: carrierCode.value,
            palette: draftPalette
        )
        CarrierStore.save(settings)
        savedCode = carrierCode.value
        savedPalette = draftPalette
        didSave = true
        WidgetCenter.shared.reloadAllTimelines()
    }
}

private struct PresetSwatch: View {
    let palette: BarcodePalette
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(palette.backgroundColor.color)

                HStack(spacing: 3) {
                    ForEach(0..<7) { index in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(palette.barColor.color)
                            .frame(width: index.isMultiple(of: 3) ? 7 : 3)
                    }
                }
            }
            .frame(width: 96, height: 44)
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(isSelected ? Color.accentColor : .clear, lineWidth: 3)
            }

            Text(palette.name)
                .font(.caption)
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
        .padding(6)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    ContentView()
}
