import SwiftUI
import WidgetKit

struct ContentView: View {
    @State private var draftCode: String
    @State private var draftPalette: BarcodePalette
    @State private var savedCode: String
    @State private var savedPalette: BarcodePalette
    @State private var didSave = false
    @State private var showingWidgetHelp = false
    @FocusState private var carrierFieldFocused: Bool

    private var normalizedCode: String {
        CarrierCode.normalize(draftCode)
    }

    private var isValid: Bool {
        CarrierCode.isValid(normalizedCode)
    }

    private var canSave: Bool {
        isValid && draftPalette.meetsCommercialGuidance
    }

    init() {
        let settings = CarrierStore.load()
        _draftCode = State(initialValue: settings.carrierCode)
        _draftPalette = State(initialValue: settings.palette)
        _savedCode = State(initialValue: settings.carrierCode)
        _savedPalette = State(initialValue: settings.palette)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                carrierSection
                barcodePreview
                colorSection
                widgetSection
            }
            .padding(.horizontal, 24)
            .padding(.top, 36)
            .padding(.bottom, 44)
        }
        .background(Color.black.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .tint(ColorInvoColor.frozenLake)
        .sheet(isPresented: $showingWidgetHelp) {
            WidgetHelpSheet()
        }
    }

    private var carrierSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("手機發票載具號碼")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)

            TextField("/2HEE8EZ", text: $draftCode)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .keyboardType(.asciiCapable)
                .submitLabel(.done)
                .focused($carrierFieldFocused)
                .font(.system(.title, design: .monospaced, weight: .semibold))
                .foregroundStyle(.white)
                .tint(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(
                            isValid ? ColorInvoColor.success : .white.opacity(0.18),
                            lineWidth: 1
                        )
                }
                .onChange(of: draftCode) { _, newValue in
                    let normalizedValue = CarrierCode.normalize(newValue)
                    if normalizedValue != newValue {
                        draftCode = normalizedValue
                    }
                    didSave = false
                }
                .onSubmit {
                    if canSave {
                        saveCarrier()
                    }
                }

            validationRow

            Button {
                saveCarrier()
                carrierFieldFocused = false
            } label: {
                Label(didSave ? "已儲存" : "儲存載具", systemImage: didSave ? "checkmark" : "tray.and.arrow.down")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 52)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!canSave)
        }
    }

    private var validationRow: some View {
        Label {
            Text(isValid ? "格式正確" : CarrierCode.validationMessage(for: draftCode))
                .font(.headline)
        } icon: {
            Image(systemName: isValid ? "checkmark.circle.fill" : "exclamationmark.circle")
                .font(.title3)
        }
        .foregroundStyle(isValid ? ColorInvoColor.success : .white.opacity(0.62))
    }

    private var barcodePreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isValid {
                CarrierBarcodePanel(
                    value: normalizedCode,
                    palette: draftPalette,
                    showsValue: false,
                    barcodeHeight: 112,
                    horizontalPadding: 22
                )
                .shadow(color: draftPalette.backgroundColor.color.opacity(0.16), radius: 18, x: 0, y: 8)
            } else {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(.white.opacity(0.08))
                    .frame(height: 150)
                    .overlay {
                        Text("輸入有效載具後顯示條碼")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.52))
                    }
            }
        }
    }

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("條碼顏色")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
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

            VStack(spacing: 14) {
                colorPickerRow(
                    title: "線條",
                    color: Binding(
                        get: { draftPalette.barColor.color },
                        set: { color in
                            draftPalette = draftPalette.replacing(
                                barColor: RGBAColor(color: color)
                            )
                            didSave = false
                        }
                    )
                )

                colorPickerRow(
                    title: "背景",
                    color: Binding(
                        get: { draftPalette.backgroundColor.color },
                        set: { color in
                            draftPalette = draftPalette.replacing(
                                backgroundColor: RGBAColor(color: color)
                            )
                            didSave = false
                        }
                    )
                )
            }

            contrastStatus
        }
    }

    private func colorPickerRow(title: String, color: Binding<Color>) -> some View {
        HStack {
            Text(title)
                .font(.title3.weight(.medium))
                .foregroundStyle(.white)

            Spacer()

            ColorPicker(title, selection: color, supportsOpacity: false)
                .labelsHidden()
        }
    }

    private var contrastStatus: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(
                draftPalette.meetsCommercialGuidance ? "可掃描配色" : draftPalette.standardMessage,
                systemImage: draftPalette.meetsCommercialGuidance
                    ? "checkmark.circle.fill"
                    : "exclamationmark.triangle.fill"
            )
            .font(.headline)
            .foregroundStyle(draftPalette.meetsCommercialGuidance ? ColorInvoColor.success : ColorInvoColor.warning)

            Text(draftPalette.contrastSummary)
                .font(.system(.body, design: .monospaced, weight: .semibold))
                .foregroundStyle(.white)

            Text(draftPalette.luminanceSummary)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.58))
                .lineLimit(2)
                .minimumScaleFactor(0.82)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var widgetSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Widget 預覽")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)

            Group {
                if isValid {
                    CarrierBarcodePanel(
                        value: normalizedCode,
                        palette: draftPalette,
                        showsValue: true,
                        barcodeHeight: 74,
                        horizontalPadding: 14
                    )
                } else {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(.white.opacity(0.08))
                        .overlay {
                            Image(systemName: "barcode.viewfinder")
                                .font(.largeTitle)
                                .foregroundStyle(.white.opacity(0.38))
                        }
                }
            }
            .frame(height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            HStack(spacing: 12) {
                Button {
                    saveCarrier()
                    showingWidgetHelp = true
                } label: {
                    Label("加入 Widget", systemImage: "plus.rectangle.on.rectangle")
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canSave)

                Button {
                    WidgetCenter.shared.reloadAllTimelines()
                    didSave = savedCode == normalizedCode && savedPalette == draftPalette
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.bordered)
                .disabled(savedCode.isEmpty)
                .accessibilityLabel("重新整理 Widget")
            }
        }
    }

    private func saveCarrier() {
        guard canSave, let carrierCode = CarrierCode(normalizedCode) else {
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
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(palette.backgroundColor.color)

                HStack(spacing: 3) {
                    ForEach(0..<7) { index in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(palette.barColor.color)
                            .frame(width: index.isMultiple(of: 3) ? 8 : 3)
                    }
                }
            }
            .frame(width: 116, height: 52)
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(isSelected ? ColorInvoColor.frozenLake : .white.opacity(0.18), lineWidth: isSelected ? 4 : 1)
            }

            Text(palette.name)
                .font(.callout)
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.86)
        }
        .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct WidgetHelpSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Image(systemName: "rectangle.grid.1x2")
                .font(.system(size: 48, weight: .semibold))
                .foregroundStyle(ColorInvoColor.frozenLake)

            Text("加入 Widget")
                .font(.largeTitle.weight(.bold))

            VStack(alignment: .leading, spacing: 14) {
                helpRow("長按主畫面空白處")
                helpRow("點左上角 +")
                helpRow("選擇條色盤")
                helpRow("加入中尺寸 Widget")
            }
            .font(.title3.weight(.medium))

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("完成")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 52)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .presentationDetents([.medium])
    }

    private func helpRow(_ text: String) -> some View {
        Label(text, systemImage: "checkmark.circle.fill")
            .foregroundStyle(.primary)
    }
}

private enum ColorInvoColor {
    static let frozenLake = Color(red: 112 / 255, green: 214 / 255, blue: 255 / 255)
    static let success = Color(red: 48 / 255, green: 209 / 255, blue: 88 / 255)
    static let warning = Color(red: 255 / 255, green: 214 / 255, blue: 112 / 255)
}

#Preview {
    ContentView()
}
