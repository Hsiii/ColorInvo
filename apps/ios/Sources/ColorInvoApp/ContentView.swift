import PhotosUI
import SwiftUI
import UIKit
import WidgetKit

struct ContentView: View {
    @State private var draftCode: String
    @State private var draftPalette: BarcodePalette
    @State private var savedSettings: CarrierSettings
    @State private var wallpaperPickerItem: PhotosPickerItem?
    @State private var wallpaperPreviewImage: UIImage?
    @State private var wallpaperPalettes: [BarcodePalette] = []
    @State private var wallpaperDominantColors: [RGBAColor]
    @State private var wallpaperStatusText: String?
    @State private var isAnalyzingWallpaper = false
    @FocusState private var carrierFieldFocused: Bool

    private var normalizedCode: String {
        CarrierCode.normalize(draftCode)
    }

    private var isValid: Bool {
        CarrierCode.isValid(normalizedCode)
    }

    private var hasCarrierInput: Bool {
        !carrierSuffix.isEmpty
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
            palette: draftPalette,
            wallpaperDominantColors: wallpaperDominantColors
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
            return "填入載具以產生小工具"
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
        _wallpaperDominantColors = State(initialValue: settings.wallpaperDominantColors)
        _wallpaperPreviewImage = State(
            initialValue: usesShowcaseData
                ? WallpaperPreviewStore.showcaseImage()
                : WallpaperPreviewStore.load()
        )
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
        .onChange(of: normalizedCode) { _, _ in
            persistCarrierIfReady()
        }
        .onChange(of: draftPalette) { _, _ in
            persistCarrierIfReady()
        }
        .onChange(of: wallpaperDominantColors) { _, _ in
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
        VStack(alignment: .leading, spacing: 12) {
            wallpaperColorSection
            wallpaperPaletteChoices
            customColorSection
        }
        .disabled(!hasCarrierInput)
        .opacity(hasCarrierInput ? 1 : 0.48)
    }

    private var wallpaperColorSection: some View {
        PhotosPicker(
            selection: $wallpaperPickerItem,
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
        .disabled(isAnalyzingWallpaper)
        .onChange(of: wallpaperPickerItem) { _, item in
            Task {
                await loadWallpaperPalettes(from: item)
            }
        }
    }

    @ViewBuilder
    private var wallpaperPaletteChoices: some View {
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
        }
    }

    private func compactColorPicker(title: String, color: Binding<Color>) -> some View {
        ColorPicker(title, selection: color, supportsOpacity: false)
            .colorInvoText(.control)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(ColorInvoColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(ColorInvoColor.hairline, lineWidth: 1)
            }
    }

    private var widgetSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("主畫面預覽")
                .colorInvoText(.heading)

            ZStack {
                WallpaperPreviewBackground(image: wallpaperPreviewImage)

                VStack(alignment: .leading, spacing: 12) {
                    Group {
                        if isValid {
                            CarrierBarcodePanel(
                                value: normalizedCode,
                                palette: draftPalette,
                                showsValue: true,
                                barcodeHeight: 108,
                                horizontalPadding: 12,
                                verticalPadding: 8,
                                fillsAvailableSpace: false,
                                dominantColors: wallpaperDominantColors
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
                    .frame(height: 132)
                    .shadow(color: .black.opacity(0.10), radius: 8, x: 0, y: 4)

                    Text(widgetStatusText)
                        .colorInvoText(.secondary)
                        .foregroundStyle(widgetIsReady ? ColorInvoColor.success : ColorInvoColor.muted)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 12)
                        .frame(minHeight: 40, alignment: .leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
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

            wallpaperPreviewImage = WallpaperPreviewStore.save(image)
            wallpaperDominantColors = sourceColors
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
                .padding(.horizontal, 4)
                .padding(.vertical, 8)
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(ColorInvoColor.hairline, lineWidth: 1)
            }

            Text(palette.name)
                .colorInvoText(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
                .frame(maxWidth: .infinity)
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
        }
        .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct WallpaperPreviewBackground: View {
    let image: UIImage?

    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()

                Color.white.opacity(0.52)
            } else {
                ColorInvoColor.primarySoft
            }
        }
    }
}

private enum WallpaperPreviewStore {
    private static let fileName = "wallpaper-preview.jpg"
    private static let maximumPixelLength: CGFloat = 900

    static func load() -> UIImage? {
        guard
            let fileURL,
            let data = try? Data(contentsOf: fileURL)
        else {
            return nil
        }

        return UIImage(data: data)
    }

    static func save(_ image: UIImage) -> UIImage? {
        guard let previewImage = previewImage(from: image) else {
            return nil
        }

        if
            let fileURL,
            let data = previewImage.jpegData(compressionQuality: 0.76)
        {
            try? data.write(to: fileURL, options: .atomic)
        }

        return previewImage
    }

    static func showcaseImage() -> UIImage {
        let size = CGSize(width: 900, height: 1600)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true

        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            UIColor(red: 232 / 255, green: 248 / 255, blue: 252 / 255, alpha: 1).setFill()
            context.fill(CGRect(origin: .zero, size: size))

            UIColor(red: 89 / 255, green: 186 / 255, blue: 201 / 255, alpha: 1).setFill()
            diagonalBand(
                from: CGPoint(x: -120, y: 240),
                to: CGPoint(x: size.width + 160, y: 40),
                thickness: 260
            ).fill()

            UIColor(red: 255 / 255, green: 184 / 255, blue: 118 / 255, alpha: 1).setFill()
            diagonalBand(
                from: CGPoint(x: -180, y: 980),
                to: CGPoint(x: size.width + 180, y: 620),
                thickness: 320
            ).fill()

            UIColor(red: 57 / 255, green: 103 / 255, blue: 145 / 255, alpha: 1).setFill()
            diagonalBand(
                from: CGPoint(x: -120, y: 1500),
                to: CGPoint(x: size.width + 120, y: 1160),
                thickness: 220
            ).fill()
        }
    }

    private static var fileURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: AppGroup.identifier)?
            .appendingPathComponent(fileName)
    }

    private static func previewImage(from image: UIImage) -> UIImage? {
        let sourceSize = image.size
        guard sourceSize.width > 0, sourceSize.height > 0 else {
            return nil
        }

        let scale = min(
            1,
            maximumPixelLength / max(sourceSize.width, sourceSize.height)
        )
        let targetSize = CGSize(
            width: max(1, floor(sourceSize.width * scale)),
            height: max(1, floor(sourceSize.height * scale))
        )
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true

        return UIGraphicsImageRenderer(size: targetSize, format: format).image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: targetSize))
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    private static func diagonalBand(
        from startPoint: CGPoint,
        to endPoint: CGPoint,
        thickness: CGFloat
    ) -> UIBezierPath {
        let deltaX = endPoint.x - startPoint.x
        let deltaY = endPoint.y - startPoint.y
        let length = max(1, hypot(deltaX, deltaY))
        let offsetX = -deltaY / length * thickness / 2
        let offsetY = deltaX / length * thickness / 2
        let path = UIBezierPath()

        path.move(to: CGPoint(x: startPoint.x + offsetX, y: startPoint.y + offsetY))
        path.addLine(to: CGPoint(x: endPoint.x + offsetX, y: endPoint.y + offsetY))
        path.addLine(to: CGPoint(x: endPoint.x - offsetX, y: endPoint.y - offsetY))
        path.addLine(to: CGPoint(x: startPoint.x - offsetX, y: startPoint.y - offsetY))
        path.close()

        return path
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
    static let background = Color.white
    static let surface = Color.white
    static let primarySoft = Color(red: 234 / 255, green: 248 / 255, blue: 255 / 255)
    static let hairline = Color(red: 216 / 255, green: 230 / 255, blue: 238 / 255)
    static let text = Color(red: 17 / 255, green: 24 / 255, blue: 39 / 255)
    static let muted = Color(red: 82 / 255, green: 96 / 255, blue: 106 / 255)
    static let success = primary
}

private enum ColorInvoRuntime {
    static var showcaseDataEnabled: Bool {
        ProcessInfo.processInfo.environment["COLORINVO_SHOWCASE_DATA"] == "1"
            || ProcessInfo.processInfo.arguments.contains("--showcase-data")
    }
}

#Preview {
    ContentView()
}
