import PhotosUI
import SwiftUI
import UIKit

struct ContentView: View {
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
        carrierSection
        colorSection
        displayOptionsSection
        widgetSection
            .id(Self.widgetScreenshotSectionID)
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
        } icon: {
            Image(systemName: model.isValid ? "checkmark.circle.fill" : "exclamationmark.circle")
                .font(.callout)
                .foregroundStyle(statusColor)
        }
    }

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Text("條碼顏色")
                    .colorInvoText(.heading)

                Spacer()

                contrastStatus
            }

            wallpaperColorSection
            wallpaperPaletteChoices
            customColorSection
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
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 12)
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

    @ViewBuilder
    private var wallpaperPaletteChoices: some View {
        if model.isAnalyzingWallpaper {
            Label("分析中", systemImage: "sparkles")
                .colorInvoText(.secondary)
                .frame(minHeight: 40, alignment: .leading)
        } else if !model.wallpaperPalettes.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("桌布配色")
                    .colorInvoText(.secondary)

                paletteButtonGrid(model.wallpaperPalettes)
            }
        } else if let wallpaperStatusText = model.wallpaperStatusText {
            Text(wallpaperStatusText)
                .colorInvoText(.secondary)
                .frame(minHeight: 40, alignment: .leading)
        }
    }

    private func paletteButtonGrid(_ palettes: [BarcodePalette]) -> some View {
        HStack(spacing: 8) {
            ForEach(Array(palettes.prefix(3).indices), id: \.self) { index in
                let palette = palettes[index]

                Button {
                    model.selectPalette(palette)
                } label: {
                    PaletteOptionButtonContent(
                        palette: palette,
                        isSelected: palette == model.draftPalette
                    )
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .accessibilityLabel("桌布配色 \(index + 1)")
                .accessibilityValue(palette == model.draftPalette ? "selected" : "not selected")
                .accessibilityIdentifier("wallpaperPaletteOption.\(index)")
            }
        }
        .frame(height: 88)
    }

    private var customColorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                compactColorPicker(
                    title: "背景",
                    color: Binding(
                        get: { model.draftPalette.backgroundColor.color },
                        set: { color in
                            model.updateBackgroundColor(color)
                        }
                    )
                )

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

            wallpaperWaveColorChoices
        }
    }

    @ViewBuilder
    private var wallpaperWaveColorChoices: some View {
        let colors = Array(model.wallpaperDominantColors.prefix(3))

        if !model.isAnalyzingWallpaper, !colors.isEmpty {
            let selectedIndex = colors.firstIndex { $0 == model.selectedWaveColor } ?? -1

            HStack(spacing: 12) {
                Text("波浪")
                    .colorInvoText(.secondary)
                    .accessibilityIdentifier("selectedWaveColorIndex")
                    .accessibilityValue("\(selectedIndex)")

                Spacer()

                HStack(spacing: 8) {
                    ForEach(colors.indices, id: \.self) { index in
                        let color = colors[index]
                        let isSelected = color == model.selectedWaveColor

                        Button {
                            model.updateWaveColor(color)
                        } label: {
                            WaveColorDot(color: color, isSelected: isSelected)
                        }
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                        .buttonStyle(.plain)
                        .accessibilityLabel("波浪色彩 \(index + 1)")
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
    }

    private func compactColorPicker(
        title: String,
        color: Binding<Color>
    ) -> some View {
        let identifier = title == "背景" ? "backgroundColorPicker" : "barColorPicker"

        return ColorPicker(title, selection: color, supportsOpacity: false)
            .colorInvoText(.control)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
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
            Text("顯示項目")
                .colorInvoText(.heading)

            HStack(spacing: 8) {
                checkboxButton(
                    title: "波浪",
                    isChecked: model.showsWave
                ) {
                    model.setShowsWave(!model.showsWave)
                }

                checkboxButton(
                    title: "載具文字",
                    isChecked: model.showsBarcodeValue
                ) {
                    model.setShowsBarcodeValue(!model.showsBarcodeValue)
                }
            }
        }
    }

    private func checkboxButton(
        title: String,
        isChecked: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label {
                Text(title)
                    .colorInvoText(.control)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            } icon: {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundStyle(isChecked ? ColorInvoColor.primary : ColorInvoColor.muted)
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .padding(.horizontal, 12)
            .background(ColorInvoColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(
                        isChecked ? ColorInvoColor.primary : ColorInvoColor.hairline,
                        lineWidth: 1
                    )
                    .allowsHitTesting(false)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isChecked ? .isSelected : [])
    }

    private var contrastStatus: some View {
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

            Text(model.draftPalette.contrastSummary)
                .colorInvoText(.secondary)
                .foregroundStyle(statusColor)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(model.draftPalette.standardMessage)
    }

    private var widgetSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("主畫面預覽")
                .colorInvoText(.heading)

            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    WallpaperPreviewBackground(preview: model.wallpaperPreviewImage)

                    CarrierWidgetContentView(
                        carrierCode: model.normalizedCode,
                        palette: model.draftPalette,
                        dominantColors: model.wallpaperDominantColors,
                        waveColor: model.selectedWaveColor,
                        showsWave: model.showsWave,
                        showsBarcodeValue: model.showsBarcodeValue
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

                Text(model.widgetStatusText)
                    .colorInvoText(.secondary)
                    .foregroundStyle(model.widgetIsReady ? ColorInvoColor.success : ColorInvoColor.muted)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(minHeight: 40, alignment: .leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

private struct WaveColorDot: View {
    let color: RGBAColor
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? ColorInvoColor.primarySoft : ColorInvoColor.surface)
                .frame(width: 40, height: 40)

            Circle()
                .fill(color.color)
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
        .frame(width: 44, height: 44)
        .contentShape(Rectangle())
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
                .padding(.horizontal, 4)
                .padding(.vertical, 8)
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
        .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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
