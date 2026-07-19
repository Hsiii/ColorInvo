import PhotosUI
import SwiftUI
import UIKit

struct ContentView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @StateObject private var model: CarrierEditorModel
    @FocusState private var carrierFieldFocused: Bool

    private var carrierSuffixBinding: Binding<String> {
        Binding(
            get: { model.carrierSuffix },
            set: { value in
                model.updateCarrierSuffix(value)
            }
        )
    }

    init(model: CarrierEditorModel = CarrierEditorModel()) {
        _model = StateObject(wrappedValue: model)
    }

#if DEBUG
    private var opensWidgetScreenshot: Bool {
        ProcessInfo.processInfo.environment["COLORINVO_SCREENSHOT_TARGET"] == "widget"
            || ProcessInfo.processInfo.arguments.contains("--screenshot-widget")
    }
#endif

    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    scrollContentSections
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .scrollDismissesKeyboard(.interactively)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(ColorInvoColor.background.ignoresSafeArea())
#if DEBUG
            .onAppear {
                guard opensWidgetScreenshot else {
                    return
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    scrollProxy.scrollTo(Self.widgetScreenshotSectionID, anchor: .top)
                }
            }
#endif
        }
        .preferredColorScheme(.light)
        .tint(ColorInvoColor.primary)
        .task {
            await model.start()
        }
    }

    private static let widgetScreenshotSectionID = "colorinvo-widget-screenshot-section"

    @ViewBuilder
    private var scrollContentSections: some View {
#if DEBUG
        if opensWidgetScreenshot {
            widgetSection
                .id(Self.widgetScreenshotSectionID)

            Color.clear
                .frame(height: 520)
        } else {
            editorSections
        }
#else
        editorSections
#endif
    }

    @ViewBuilder
    private var editorSections: some View {
        widgetSection
        carrierSection
        themeSection
        displayOptionsSection
    }

    private var carrierSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 8) {
                    Text("手機載具")
                        .colorInvoText(.heading)

                    validationBadge
                }
            } else {
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text("手機載具")
                        .colorInvoText(.heading)

                    Spacer()

                    validationBadge
                }
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
                                model.isValid ? ColorInvoColor.primary : ColorInvoColor.hairline,
                                lineWidth: 1
                            )
                    }
            }
        }
    }

    private var validationBadge: some View {
        let statusColor = model.isValid ? ColorInvoColor.success : ColorInvoColor.muted

        return Label {
            Text(model.validationText)
                .colorInvoText(.control)
                .foregroundStyle(statusColor)
                .fixedSize(horizontal: false, vertical: true)
        } icon: {
            Image(systemName: model.isValid ? "checkmark.circle.fill" : "exclamationmark.circle")
                .font(.callout)
                .foregroundStyle(statusColor)
        }
    }

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 8) {
                    Text("主題")
                        .colorInvoText(.heading)

                    if model.isValid {
                        scanReadinessStatus
                    }
                }
            } else {
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text("主題")
                        .colorInvoText(.heading)

                    Spacer()

                    if model.isValid {
                        scanReadinessStatus
                    }
                }
            }

            wallpaperColorSection
            wallpaperPaletteChoices
            paletteFineTuningSection
            wallpaperWaveColorChoices
        }
    }

    private var wallpaperColorSection: some View {
        PhotosPicker(
            selection: $model.wallpaperPickerItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            Label("選擇桌布以產生配色", systemImage: "photo.on.rectangle")
                .colorInvoText(.control)
                .foregroundStyle(ColorInvoColor.primary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(ColorInvoColor.primarySoft)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(model.isAnalyzingWallpaper)
        .onChange(of: model.wallpaperPickerItem) { _, item in
            model.loadWallpaperPalettes(from: item)
        }
    }

    private var wallpaperPaletteChoices: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("條碼配色")
                .colorInvoText(.secondary)

            paletteStatus
            paletteButtonGrid(model.wallpaperPalettes)
        }
    }

    @ViewBuilder
    private var paletteStatus: some View {
        if model.isAnalyzingWallpaper {
            Label("正在分析桌布…", systemImage: "sparkles")
                .colorInvoText(.secondary)
                .frame(minHeight: 40, alignment: .leading)
        } else if let wallpaperStatusText = model.wallpaperStatusText {
            Text(wallpaperStatusText)
                .colorInvoText(.secondary)
                .frame(minHeight: 40, alignment: .leading)
        } else if model.wallpaperPalettes.isEmpty {
            Text("選擇桌布後會產生三組條碼配色")
                .colorInvoText(.secondary)
                .frame(minHeight: 40, alignment: .leading)
        }
    }

    private func paletteButtonGrid(_ palettes: [BarcodePalette]) -> some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { index in
                let palette = palettes.indices.contains(index) ? palettes[index] : nil
                let isSelected = index == model.selectedWallpaperPaletteIndex

                Button {
                    if let palette {
                        model.selectPalette(palette)
                    }
                } label: {
                    PaletteOptionButtonContent(
                        palette: palette,
                        isSelected: isSelected
                    )
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .disabled(palette == nil || model.isAnalyzingWallpaper)
                .accessibilityLabel(
                    palette == nil
                        ? "條碼配色 \(index + 1)，尚未產生"
                        : "條碼配色 \(index + 1)"
                )
                .accessibilityValue(isSelected ? "selected" : "not selected")
                .accessibilityAddTraits(isSelected ? .isSelected : [])
                .accessibilityIdentifier("wallpaperPaletteOption.\(index)")
            }
        }
        .frame(height: 88)
    }

    private var paletteFineTuningSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Text("手動微調")
                    .colorInvoText(.secondary)

                Spacer()

                Button {
                    model.resetPaletteToWallpaper()
                } label: {
                    Label("重設", systemImage: "arrow.counterclockwise")
                        .colorInvoText(.control)
                        .foregroundStyle(
                            model.canResetWallpaperPalette
                                ? ColorInvoColor.primary
                                : ColorInvoColor.muted
                        )
                        .frame(minHeight: 44)
                }
                .buttonStyle(.plain)
                .disabled(!model.canResetWallpaperPalette)
                .accessibilityIdentifier("resetWallpaperPaletteButton")
            }

            customColorSection
        }
        .disabled(model.wallpaperBasePalette == nil || model.isAnalyzingWallpaper)
    }

    private var customColorSection: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: 8) {
                    backgroundColorPicker
                    barColorPicker
                }
            } else {
                HStack(spacing: 8) {
                    backgroundColorPicker
                    barColorPicker
                }
            }
        }
    }

    private var backgroundColorPicker: some View {
        compactColorPicker(
            title: "背景",
            color: Binding(
                get: { model.draftPalette.backgroundColor.color },
                set: { color in
                    model.updateBackgroundColor(color)
                }
            )
        )
    }

    private var barColorPicker: some View {
        compactColorPicker(
            title: "條碼",
            color: Binding(
                get: { model.draftPalette.barColor.color },
                set: { color in
                    model.updateBarColor(color)
                }
            )
        )
    }

    private var wallpaperWaveColorChoices: some View {
        let colors = Array(model.wallpaperDominantColors.prefix(3))
        let selectedIndex = colors.firstIndex { $0 == model.selectedWaveColor } ?? -1

        return HStack(spacing: 12) {
            Text("波浪顏色")
                .colorInvoText(.secondary)
                .accessibilityIdentifier("selectedWaveColorIndex")
                .accessibilityValue("\(selectedIndex)")

            Spacer()

            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    let color = colors.indices.contains(index) ? colors[index] : nil
                    let isSelected = index == selectedIndex

                    Button {
                        if let color {
                            model.updateWaveColor(color)
                        }
                    } label: {
                        WaveColorDot(color: color, isSelected: isSelected)
                    }
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                    .buttonStyle(.plain)
                    .disabled(color == nil || model.isAnalyzingWallpaper)
                    .accessibilityLabel(
                        color == nil
                            ? "波浪色彩 \(index + 1)，尚未產生"
                            : "波浪色彩 \(index + 1)"
                    )
                    .accessibilityValue(isSelected ? "selected" : "not selected")
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                    .accessibilityIdentifier("waveColorDot.\(index)")
                }
            }
        }
        .padding(.leading, 12)
        .padding(.trailing, 8)
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .background(ColorInvoColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(ColorInvoColor.hairline, lineWidth: 1)
                .allowsHitTesting(false)
        }
    }

    private func compactColorPicker(
        title: String,
        color: Binding<Color>
    ) -> some View {
        let identifier = title == "背景" ? "backgroundColorPicker" : "barColorPicker"

        return ColorPicker(title, selection: color, supportsOpacity: false)
            .colorInvoText(.control)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .background(ColorInvoColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(ColorInvoColor.hairline, lineWidth: 1)
                    .allowsHitTesting(false)
            }
            .accessibilityIdentifier(identifier)
    }

    private var displayOptionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("內容")
                .colorInvoText(.heading)

            VStack(spacing: 0) {
                Toggle(isOn: showsBarcodeValueBinding) {
                    Text("顯示載具文字")
                        .colorInvoText(.control)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(minHeight: 52)
                .accessibilityIdentifier("showsBarcodeValueToggle")

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("裝飾")
                        .colorInvoText(.secondary)

                    Picker("裝飾", selection: decorationBinding) {
                        Text("無").tag(CarrierDecoration.none)
                        Text("波浪").tag(CarrierDecoration.wave)
                        Text("貓咪").tag(CarrierDecoration.cat)
                    }
                    .pickerStyle(.segmented)
                    .frame(minHeight: 44)
                    .accessibilityIdentifier("decorationPicker")
                }
                .padding(.vertical, 12)
            }
            .padding(.horizontal, 12)
            .background(ColorInvoColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(ColorInvoColor.hairline, lineWidth: 1)
                    .allowsHitTesting(false)
            }
        }
    }

    private var showsBarcodeValueBinding: Binding<Bool> {
        Binding(
            get: { model.showsBarcodeValue },
            set: { model.setShowsBarcodeValue($0) }
        )
    }

    private var decorationBinding: Binding<CarrierDecoration> {
        Binding(
            get: { model.decoration },
            set: { model.setDecoration($0) }
        )
    }

    private var scanReadinessStatus: some View {
        let statusColor = model.draftPalette.meetsCommercialGuidance
            ? ColorInvoColor.success
            : ColorInvoColor.warning

        return HStack(spacing: 6) {
            Image(
                systemName: model.draftPalette.meetsCommercialGuidance
                    ? "checkmark.circle.fill"
                    : "exclamationmark.triangle.fill"
            )
            .font(.callout)
            .foregroundStyle(statusColor)

            Text(model.draftPalette.meetsCommercialGuidance ? "適合掃描" : "對比不足")
                .colorInvoText(.secondary)
                .foregroundStyle(statusColor)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(model.draftPalette.standardMessage)
    }

    private var widgetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 8) {
                    Text("主畫面預覽")
                        .colorInvoText(.heading)

                    widgetSaveStatus
                }
            } else {
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text("主畫面預覽")
                        .colorInvoText(.heading)

                    Spacer()

                    widgetSaveStatus
                }
            }

            ZStack {
                WallpaperPreviewBackground(preview: model.wallpaperPreviewImage)

                CarrierWidgetContentView(
                    carrierCode: model.normalizedCode,
                    palette: model.draftPalette,
                    dominantColors: model.wallpaperDominantColors,
                    waveColor: model.selectedWaveColor,
                    showsWave: model.decoration.showsWave,
                    showsBarcodeValue: model.showsBarcodeValue,
                    showsCat: model.decoration.showsCat,
                    emptyStateText: "輸入載具即可預覽"
                )
                .aspectRatio(329 / 155, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: .black.opacity(0.16), radius: 12, x: 0, y: 8)
                .padding(16)
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(.black.opacity(0.10), lineWidth: 1)
            }
        }
    }

    private var widgetSaveStatus: some View {
        let isReady = model.widgetIsReady
        let iconName = model.isSavingSettings
            ? "arrow.triangle.2.circlepath"
            : isReady ? "checkmark.circle.fill" : "exclamationmark.circle"
        let statusColor = isReady ? ColorInvoColor.success : ColorInvoColor.muted

        return Label {
            Text(model.widgetStatusText)
                .colorInvoText(.secondary)
                .foregroundStyle(statusColor)
                .fixedSize(horizontal: false, vertical: true)
        } icon: {
            Image(systemName: iconName)
                .font(.callout)
                .foregroundStyle(statusColor)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct WaveColorDot: View {
    let color: RGBAColor?
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? ColorInvoColor.primarySoft : ColorInvoColor.surface)
                .frame(width: 40, height: 40)

            Circle()
                .fill(color?.color ?? ColorInvoColor.primarySoft)
                .frame(width: 28, height: 28)
                .overlay {
                    Circle()
                        .strokeBorder(ColorInvoColor.hairline, lineWidth: 1)
                        .allowsHitTesting(false)
                }
                .overlay {
                    Circle()
                        .strokeBorder(
                            isSelected ? ColorInvoColor.primary : .clear,
                            lineWidth: 4
                        )
                        .allowsHitTesting(false)
                }
        }
        .overlay(alignment: .topTrailing) {
            if isSelected {
                SelectionCheckmark()
            }
        }
        .frame(width: 44, height: 44)
        .contentShape(Rectangle())
    }
}

private struct PaletteOptionButtonContent: View {
    let palette: BarcodePalette?
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(palette?.backgroundColor.color ?? ColorInvoColor.primarySoft)

                if let palette {
                    Code39BarcodeView(
                        value: "/A1B2",
                        barColor: palette.barColor.color,
                        backgroundColor: palette.backgroundColor.color
                    )
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
                } else {
                    Image(systemName: "barcode")
                        .font(.title2)
                        .foregroundStyle(ColorInvoColor.muted)
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(ColorInvoColor.hairline, lineWidth: 1)
                    .allowsHitTesting(false)
            }

        }
        .padding(4)
        .frame(maxWidth: .infinity, minHeight: 88, alignment: .top)
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
                .allowsHitTesting(false)
        }
        .overlay(alignment: .topTrailing) {
            if isSelected {
                SelectionCheckmark()
                    .padding(8)
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct SelectionCheckmark: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(ColorInvoColor.primary)

            Image(systemName: "checkmark")
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(width: 16, height: 16)
        .accessibilityHidden(true)
    }
}

private struct WallpaperPreviewBackground: View {
    let preview: WallpaperPreviewImage?

    var body: some View {
        ZStack {
            if let preview {
                Image(uiImage: preview.image)
                    .resizable()
                    .scaledToFill()

                Color.white.opacity(0.52)
            } else {
                ColorInvoColor.primarySoft
            }
        }
        .clipped()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
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
    nonisolated func colorInvoText(_ style: ColorInvoTextStyle) -> some View {
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

#Preview {
    ContentView()
}
