import PhotosUI
import SwiftUI
import UIKit
import WidgetKit

struct ContentView: View {
    @State private var draftCode: String
    @State private var draftPalette: BarcodePalette
    @State private var savedSettings: CarrierSettings
    @State private var showingWidgetHelp = false
    @State private var wallpaperPickerItem: PhotosPickerItem?
    @State private var wallpaperPalettes: [BarcodePalette] = []
    @State private var wallpaperStatusText: String?
    @State private var isAnalyzingWallpaper = false
    @FocusState private var carrierFieldFocused: Bool

    private var normalizedCode: String {
        CarrierCode.normalize(draftCode)
    }

    private var isValid: Bool {
        CarrierCode.isValid(normalizedCode)
    }

    private var canAutoSave: Bool {
        isValid && draftPalette.meetsCommercialGuidance
    }

    private var draftSettings: CarrierSettings? {
        guard canAutoSave, let carrierCode = CarrierCode(normalizedCode) else {
            return nil
        }

        return CarrierSettings(
            carrierCode: carrierCode.value,
            palette: draftPalette
        )
    }

    private var widgetIsReady: Bool {
        draftSettings == savedSettings
    }

    private var widgetStatusText: String {
        if widgetIsReady {
            return "小工具已準備好，可在主畫面加入"
        }

        if !isValid {
            return "完成載具格式後會自動更新小工具"
        }

        if !draftPalette.meetsCommercialGuidance {
            return "配色可掃描後會自動更新小工具"
        }

        return "小工具設定會自動更新"
    }

    private var paletteGridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)
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
            }
        )
    }

    private var validationText: String {
        if isValid {
            return "格式符合"
        }

        return carrierSuffix.isEmpty ? "未填" : "格式不符"
    }

    init() {
        let usesShowcaseData = ColorInvoRuntime.showcaseDataEnabled
        let settings = usesShowcaseData ? .showcase : CarrierStore.load()
        _draftCode = State(initialValue: settings.carrierCode)
        _draftPalette = State(initialValue: settings.palette)
        _savedSettings = State(initialValue: settings)
        _showingWidgetHelp = State(initialValue: ColorInvoRuntime.screenshotTarget == "widget")
        _wallpaperPalettes = State(initialValue: usesShowcaseData ? BarcodePalette.showcaseOptions : [])
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            carrierSection
            colorSection
            widgetSection
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(ColorInvoColor.background.ignoresSafeArea())
        .preferredColorScheme(.light)
        .tint(ColorInvoColor.primary)
        .sheet(isPresented: $showingWidgetHelp) {
            WidgetHelpSheet()
        }
        .onChange(of: normalizedCode) { _, _ in
            persistCarrierIfReady()
        }
        .onChange(of: draftPalette) { _, _ in
            persistCarrierIfReady()
        }
    }

    private var carrierSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Text("手機載具")
                    .colorInvoText(.heading)

                Spacer()

                validationBadge
            }

            HStack(spacing: 0) {
                Text("/")
                    .colorInvoText(.code)
                    .padding(.leading, 16)

                TextField("請輸入", text: carrierSuffixBinding)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .keyboardType(.asciiCapable)
                    .submitLabel(.done)
                    .focused($carrierFieldFocused)
                    .colorInvoText(.code)
                    .tint(ColorInvoColor.primary)
                    .padding(.leading, 2)
                    .padding(.trailing, 16)
                    .padding(.vertical, 10)
                    .onSubmit {
                        carrierFieldFocused = false
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
        }
    }

    private var validationBadge: some View {
        let statusColor = isValid ? ColorInvoColor.success : ColorInvoColor.muted

        return Label {
            Text(validationText)
                .colorInvoText(.control)
                .foregroundStyle(statusColor)
        } icon: {
            Image(systemName: isValid ? "checkmark.circle.fill" : "exclamationmark.circle")
                .font(.callout)
                .foregroundStyle(statusColor)
        }
    }

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Text("條碼顏色")
                    .colorInvoText(.heading)

                Spacer()

                contrastStatus
            }

            wallpaperColorSection

            ColorChoiceSeparator()

            customColorSection
        }
    }

    private var wallpaperColorSection: some View {
        let pickerTitle = wallpaperPalettes.isEmpty ? "選擇圖片" : "重新選擇"

        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text("從桌布")
                    .colorInvoText(.secondary)

                Spacer()

                PhotosPicker(
                    selection: $wallpaperPickerItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Label(
                        pickerTitle,
                        systemImage: "photo.on.rectangle"
                    )
                    .colorInvoText(.control)
                    .foregroundStyle(ColorInvoColor.primary)
                    .padding(.horizontal, 12)
                    .frame(minHeight: 40)
                    .background(ColorInvoColor.primarySoft)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(isAnalyzingWallpaper)
            }

            if isAnalyzingWallpaper {
                Label("分析中", systemImage: "sparkles")
                    .colorInvoText(.secondary)
                    .frame(minHeight: 40, alignment: .leading)
            } else if !wallpaperPalettes.isEmpty {
                paletteButtonGrid(wallpaperPalettes)
            } else if let wallpaperStatusText {
                Text(wallpaperStatusText)
                    .colorInvoText(.secondary)
                    .frame(minHeight: 40, alignment: .leading)
            }
        }
        .onChange(of: wallpaperPickerItem) { _, item in
            Task {
                await loadWallpaperPalettes(from: item)
            }
        }
    }

    private func paletteButtonGrid(_ palettes: [BarcodePalette]) -> some View {
        LazyVGrid(columns: paletteGridColumns, spacing: 8) {
            ForEach(palettes) { palette in
                Button {
                    draftPalette = palette
                } label: {
                    PaletteOptionButtonContent(
                        palette: palette,
                        isSelected: palette == draftPalette
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(palette.name)
            }
        }
    }

    private var customColorSection: some View {
        HStack(spacing: 8) {
            Text("自訂")
                .colorInvoText(.secondary)
                .frame(width: 40, alignment: .leading)

            compactColorPicker(
                title: "條碼",
                color: Binding(
                    get: { draftPalette.barColor.color },
                    set: { color in
                        draftPalette = draftPalette.replacing(
                            barColor: RGBAColor(color: color)
                        )
                    }
                )
            )

            compactColorPicker(
                title: "背景",
                color: Binding(
                    get: { draftPalette.backgroundColor.color },
                    set: { color in
                        draftPalette = draftPalette.replacing(
                            backgroundColor: RGBAColor(color: color)
                        )
                    }
                )
            )
        }
    }

    private func compactColorPicker(title: String, color: Binding<Color>) -> some View {
        ColorPicker(title, selection: color, supportsOpacity: false)
            .colorInvoText(.control)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(ColorInvoColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(ColorInvoColor.hairline, lineWidth: 1)
            }
    }

    private var contrastStatus: some View {
        let statusColor = draftPalette.meetsCommercialGuidance
            ? ColorInvoColor.success
            : ColorInvoColor.warning

        return HStack(spacing: 6) {
            Image(
                systemName: draftPalette.meetsCommercialGuidance
                    ? "checkmark.circle.fill"
                    : "exclamationmark.triangle.fill"
            )
            .font(.callout)
            .foregroundStyle(statusColor)

            Text(draftPalette.contrastSummary)
                .colorInvoText(.secondary)
                .foregroundStyle(statusColor)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(draftPalette.standardMessage)
    }

    private var widgetSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("小工具預覽")
                .colorInvoText(.heading)

            Group {
                if isValid {
                    CarrierBarcodePanel(
                        value: normalizedCode,
                        palette: draftPalette,
                        showsValue: true,
                        barcodeHeight: 88,
                        horizontalPadding: 0,
                        verticalPadding: 6,
                        fillsAvailableSpace: true
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
            .frame(height: 136)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            HStack(spacing: 8) {
                Label(
                    widgetStatusText,
                    systemImage: widgetIsReady ? "info.circle.fill" : "info.circle"
                )
                .colorInvoText(.secondary)
                .foregroundStyle(widgetIsReady ? ColorInvoColor.success : ColorInvoColor.muted)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 8)

                Button {
                    showingWidgetHelp = true
                } label: {
                    Image(systemName: "questionmark.circle")
                        .font(.title3)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .foregroundStyle(ColorInvoColor.primary)
                .accessibilityLabel("加入小工具說明")
            }
        }
    }

    private func persistCarrierIfReady() {
        guard let settings = draftSettings, settings != savedSettings else {
            return
        }

        CarrierStore.save(settings)
        savedSettings = settings
        WidgetCenter.shared.reloadAllTimelines()
    }

    @MainActor
    private func loadWallpaperPalettes(from item: PhotosPickerItem?) async {
        guard let item else {
            return
        }

        isAnalyzingWallpaper = true
        wallpaperStatusText = nil

        defer {
            isAnalyzingWallpaper = false
        }

        do {
            guard
                let data = try await item.loadTransferable(type: Data.self),
                let image = UIImage(data: data)
            else {
                wallpaperPalettes = []
                wallpaperStatusText = "無法讀取圖片"
                return
            }

            let sourceColors = WallpaperPaletteGenerator.representativeColors(from: image)
            let generatedPalettes = WallpaperPaletteGenerator.palettes(from: sourceColors)
            guard !generatedPalettes.isEmpty else {
                wallpaperPalettes = []
                wallpaperStatusText = "無法讀取圖片"
                return
            }

            wallpaperPalettes = generatedPalettes

            if let firstPalette = generatedPalettes.first {
                draftPalette = firstPalette
            }
        } catch {
            wallpaperPalettes = []
            wallpaperStatusText = "無法讀取圖片"
        }
    }
}

private struct PaletteOptionButtonContent: View {
    let palette: BarcodePalette
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(palette.backgroundColor.color)

                Code39BarcodeView(
                    value: "/A1B2",
                    barColor: palette.barColor.color,
                    backgroundColor: palette.backgroundColor.color
                )
                .padding(.horizontal, 8)
                .padding(.vertical, 10)
            }
            .frame(width: 64, height: 64)
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(ColorInvoColor.hairline, lineWidth: 1)
            }

            Text(palette.name)
                .colorInvoText(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
        }
        .padding(4)
        .frame(maxWidth: .infinity, minHeight: 96, alignment: .top)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isSelected ? ColorInvoColor.primarySoft : .clear)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(
                    isSelected ? ColorInvoColor.primary : .clear,
                    lineWidth: 2
                )
        }
        .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct ColorChoiceSeparator: View {
    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(ColorInvoColor.hairline)
                .frame(height: 1)

            Text("或")
                .colorInvoText(.secondary)

            Rectangle()
                .fill(ColorInvoColor.hairline)
                .frame(height: 1)
        }
        .padding(.vertical, 6)
    }
}

private struct WidgetHelpSheet: View {
    @Environment(\.dismiss) private var dismiss

    private let steps = [
        "長按主畫面空白處",
        "點左上角 +",
        "選擇條色盤",
        "加入小工具",
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Image(systemName: "rectangle.grid.1x2")
                .font(.largeTitle)
                .foregroundStyle(ColorInvoColor.primary)

            Text("加入小工具")
                .colorInvoText(.heading)

            VStack(alignment: .leading, spacing: 14) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    helpRow(number: index + 1, text: step)
                }
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("了解")
                    .colorInvoText(.control)
                    .frame(maxWidth: .infinity, minHeight: 52)
            }
            .buttonStyle(ColorInvoPrimaryButtonStyle())
        }
        .padding(24)
        .tint(ColorInvoColor.primary)
        .presentationDetents([.medium])
    }

    private func helpRow(number: Int, text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text("\(number).")
                .colorInvoText(.control)
                .foregroundStyle(ColorInvoColor.primary)
                .monospacedDigit()
                .frame(width: 24, alignment: .leading)

            Text(text)
                .colorInvoText(.control)
        }
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

private enum ColorInvoTextStyle {
    case heading
    case control
    case secondary
    case code
}

private struct ColorInvoTextStyleModifier: ViewModifier {
    let style: ColorInvoTextStyle

    func body(content: Content) -> some View {
        switch style {
        case .heading:
            content
                .font(.headline)
                .foregroundStyle(ColorInvoColor.text)
        case .control:
            content
                .font(.callout.weight(.semibold))
                .foregroundStyle(ColorInvoColor.text)
        case .secondary:
            content
                .font(.callout.weight(.semibold))
                .foregroundStyle(ColorInvoColor.muted)
        case .code:
            content
                .font(.system(.body, design: .monospaced, weight: .semibold))
                .foregroundStyle(ColorInvoColor.text)
        }
    }
}

private extension View {
    func colorInvoText(_ style: ColorInvoTextStyle) -> some View {
        modifier(ColorInvoTextStyleModifier(style: style))
    }
}

private enum ColorInvoColor {
    static let frozenLake = Color(red: 112 / 255, green: 214 / 255, blue: 255 / 255)
    static let roseKiss = Color(red: 255 / 255, green: 112 / 255, blue: 166 / 255)
    static let primary = Color(red: 0 / 255, green: 126 / 255, blue: 168 / 255)
    static let attention = Color(red: 180 / 255, green: 98 / 255, blue: 20 / 255)
    static let background = Color.white
    static let surface = Color.white
    static let primarySoft = Color(red: 234 / 255, green: 248 / 255, blue: 255 / 255)
    static let hairline = Color(red: 216 / 255, green: 230 / 255, blue: 238 / 255)
    static let text = Color(red: 17 / 255, green: 24 / 255, blue: 39 / 255)
    static let muted = Color(red: 82 / 255, green: 96 / 255, blue: 106 / 255)
    static let success = primary
    static let warning = attention
}

private enum ColorInvoRuntime {
    static var showcaseDataEnabled: Bool {
        ProcessInfo.processInfo.environment["COLORINVO_SHOWCASE_DATA"] == "1"
            || ProcessInfo.processInfo.arguments.contains("--showcase-data")
    }

    static var screenshotTarget: String? {
        if let target = ProcessInfo.processInfo.environment["COLORINVO_SCREENSHOT_TARGET"] {
            return target
        }

        if ProcessInfo.processInfo.arguments.contains("--screenshot-widget") {
            return "widget"
        }

        return nil
    }
}

#Preview {
    ContentView()
}
