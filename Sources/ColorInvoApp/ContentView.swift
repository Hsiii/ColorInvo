import SwiftUI
import WidgetKit

struct ContentView: View {
    @State private var draftCode: String
    @State private var draftPalette: BarcodePalette
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

    private var carrierSuffix: String {
        let code = CarrierCode.normalize(draftCode)
        guard code.hasPrefix("/") else {
            return code
        }

        return String(code.dropFirst())
    }

    private var carrierSuffixBinding: Binding<String> {
        Binding(
            get: { carrierSuffix },
            set: { newValue in
                let suffix = CarrierCode.normalize(newValue)
                    .replacingOccurrences(of: "/", with: "")
                draftCode = suffix.isEmpty ? "" : "/\(suffix)"
                didSave = false
            }
        )
    }

    private var validationText: String {
        if isValid {
            return "正確"
        }

        return carrierSuffix.isEmpty ? "未填" : "無效"
    }

    init() {
        let settings = CarrierStore.load()
        _draftCode = State(initialValue: settings.carrierCode)
        _draftPalette = State(initialValue: settings.palette)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                carrierSection
                colorSection
                widgetSection
            }
            .padding(.horizontal, 24)
            .padding(.top, 36)
            .padding(.bottom, 44)
        }
        .background(ColorInvoColor.background.ignoresSafeArea())
        .preferredColorScheme(.light)
        .tint(ColorInvoColor.primary)
        .sheet(isPresented: $showingWidgetHelp) {
            WidgetHelpSheet()
        }
    }

    private var carrierSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Text("手機載具")
                    .font(.headline)
                    .foregroundStyle(ColorInvoColor.text)

                Spacer()

                validationBadge
            }

            HStack(spacing: 0) {
                Text("/")
                    .font(.system(.body, design: .monospaced, weight: .semibold))
                    .foregroundStyle(ColorInvoColor.text)
                    .padding(.leading, 16)

                TextField("請輸入", text: carrierSuffixBinding)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .keyboardType(.asciiCapable)
                    .submitLabel(.done)
                    .focused($carrierFieldFocused)
                    .font(.system(.body, design: .monospaced, weight: .semibold))
                    .foregroundStyle(ColorInvoColor.text)
                    .tint(ColorInvoColor.primary)
                    .padding(.leading, 2)
                    .padding(.trailing, 16)
                    .padding(.vertical, 12)
                    .onSubmit {
                        if canSave {
                            saveCarrier()
                        }
                    }
            }
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(ColorInvoColor.surface)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .strokeBorder(
                                isValid ? ColorInvoColor.primary : ColorInvoColor.hairline,
                                lineWidth: 1
                            )
                    }
            }

            Button {
                saveCarrier()
                carrierFieldFocused = false
            } label: {
                Label(didSave ? "已儲存" : "儲存載具", systemImage: didSave ? "checkmark" : "tray.and.arrow.down")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 52)
            }
            .buttonStyle(ColorInvoPrimaryButtonStyle())
            .disabled(!canSave)
        }
    }

    private var validationBadge: some View {
        Label {
            Text(validationText)
                .font(.subheadline.weight(.semibold))
        } icon: {
            Image(systemName: isValid ? "checkmark.circle.fill" : "exclamationmark.circle")
                .font(.subheadline)
        }
        .foregroundStyle(isValid ? ColorInvoColor.success : ColorInvoColor.muted)
    }

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("條碼顏色")
                .font(.title2.weight(.semibold))
                .foregroundStyle(ColorInvoColor.text)

            Text("推薦")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(ColorInvoColor.secondary)

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

            Text("自訂")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(ColorInvoColor.secondary)

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
                .foregroundStyle(ColorInvoColor.text)

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
                .foregroundStyle(ColorInvoColor.text)

            Text(draftPalette.reflectanceSummary)
                .font(.caption)
                .foregroundStyle(ColorInvoColor.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(draftPalette.meetsCommercialGuidance ? ColorInvoColor.primarySoft : ColorInvoColor.secondarySoft)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var widgetSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("小工具預覽")
                .font(.title2.weight(.semibold))
                .foregroundStyle(ColorInvoColor.text)

            Group {
                if isValid {
                    CarrierBarcodePanel(
                        value: normalizedCode,
                        palette: draftPalette,
                        showsValue: true,
                        barcodeHeight: 88,
                        horizontalPadding: 0,
                        verticalPadding: 8
                    )
                } else {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(ColorInvoColor.primarySoft)
                        .overlay {
                            Image(systemName: "barcode.viewfinder")
                                .font(.largeTitle)
                                .foregroundStyle(ColorInvoColor.primary.opacity(0.48))
                        }
                }
            }
            .frame(height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            Button {
                saveCarrier()
                showingWidgetHelp = true
            } label: {
                Label("加入小工具", systemImage: "plus.rectangle.on.rectangle")
                    .frame(maxWidth: .infinity, minHeight: 52)
            }
            .buttonStyle(ColorInvoPrimaryButtonStyle())
            .disabled(!canSave)
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
                    .strokeBorder(isSelected ? ColorInvoColor.primary : ColorInvoColor.hairline, lineWidth: isSelected ? 4 : 1)
            }

            Text(palette.name)
                .font(.callout)
                .foregroundStyle(ColorInvoColor.text)
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
                .foregroundStyle(ColorInvoColor.primary)

            Text("加入小工具")
                .font(.largeTitle.weight(.bold))

            VStack(alignment: .leading, spacing: 14) {
                helpRow("長按主畫面空白處")
                helpRow("點左上角 +")
                helpRow("選擇條色盤")
                helpRow("加入中尺寸小工具")
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
            .buttonStyle(ColorInvoPrimaryButtonStyle())
        }
        .padding(24)
        .tint(ColorInvoColor.primary)
        .presentationDetents([.medium])
    }

    private func helpRow(_ text: String) -> some View {
        Label(text, systemImage: "checkmark.circle.fill")
            .foregroundStyle(.primary)
    }
}

private struct ColorInvoPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background(isEnabled ? ColorInvoColor.primary : ColorInvoColor.hairline)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .opacity(configuration.isPressed ? 0.82 : 1)
    }
}

private enum ColorInvoColor {
    static let frozenLake = Color(red: 112 / 255, green: 214 / 255, blue: 255 / 255)
    static let roseKiss = Color(red: 255 / 255, green: 112 / 255, blue: 166 / 255)
    static let primary = Color(red: 0 / 255, green: 126 / 255, blue: 168 / 255)
    static let secondary = Color(red: 176 / 255, green: 0 / 255, blue: 79 / 255)
    static let background = Color.white
    static let surface = Color.white
    static let primarySoft = Color(red: 234 / 255, green: 248 / 255, blue: 255 / 255)
    static let secondarySoft = Color(red: 255 / 255, green: 240 / 255, blue: 246 / 255)
    static let hairline = Color(red: 216 / 255, green: 230 / 255, blue: 238 / 255)
    static let text = Color(red: 17 / 255, green: 24 / 255, blue: 39 / 255)
    static let muted = Color(red: 82 / 255, green: 96 / 255, blue: 106 / 255)
    static let success = primary
    static let warning = secondary
}

#Preview {
    ContentView()
}
