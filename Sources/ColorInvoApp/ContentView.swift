import PhotosUI
import SwiftUI
import UIKit
import WidgetKit

struct ContentView: View {
    @State private var draftCode: String
    @State private var draftPalette: BarcodePalette
    @State private var didSave = false
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

    private var canSave: Bool {
        isValid && draftPalette.meetsCommercialGuidance
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
                didSave = false
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
        VStack(alignment: .leading, spacing: 14) {
            Text("條碼顏色")
                .font(.title2.weight(.semibold))
                .foregroundStyle(ColorInvoColor.text)

            wallpaperColorSection

            ColorChoiceSeparator()

            customColorSection

            contrastStatus
        }
    }

    private var wallpaperColorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text("從桌布")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(ColorInvoColor.secondary)

                Spacer()

                PhotosPicker(
                    selection: $wallpaperPickerItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Label(
                        wallpaperPalettes.isEmpty ? "選擇圖片" : "重新選擇",
                        systemImage: "photo.on.rectangle"
                    )
                    .font(.callout.weight(.semibold))
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
                    .font(.callout.weight(.medium))
                    .foregroundStyle(ColorInvoColor.muted)
                    .frame(minHeight: 40, alignment: .leading)
            } else if !wallpaperPalettes.isEmpty {
                paletteButtonGrid(wallpaperPalettes)
            } else if let wallpaperStatusText {
                Text(wallpaperStatusText)
                    .font(.callout)
                    .foregroundStyle(ColorInvoColor.muted)
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
                    didSave = false
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
        VStack(alignment: .leading, spacing: 8) {
            Text("自訂")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(ColorInvoColor.secondary)

            HStack(spacing: 8) {
                compactColorPicker(
                    title: "條碼",
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

                compactColorPicker(
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
        }
    }

    private func compactColorPicker(title: String, color: Binding<Color>) -> some View {
        ColorPicker(title, selection: color, supportsOpacity: false)
            .font(.callout.weight(.semibold))
            .foregroundStyle(ColorInvoColor.text)
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
                        barcodeHeight: 104,
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
                let image = UIImage(data: data),
                let dominantColor = WallpaperPaletteGenerator.dominantColor(from: image)
            else {
                wallpaperPalettes = []
                wallpaperStatusText = "無法讀取圖片"
                return
            }

            let generatedPalettes = WallpaperPaletteGenerator.palettes(from: dominantColor)
            wallpaperPalettes = generatedPalettes

            if let firstPalette = generatedPalettes.first {
                draftPalette = firstPalette
                didSave = false
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

                HStack(spacing: 4) {
                    ForEach(0..<7) { index in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(palette.barColor.color)
                            .frame(width: index.isMultiple(of: 3) ? 12 : 4)
                    }
                }
                .frame(height: 48)
            }
            .frame(width: 64, height: 64)
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(
                        isSelected ? ColorInvoColor.primary : ColorInvoColor.hairline,
                        lineWidth: isSelected ? 4 : 1
                    )
            }

            Text(palette.name)
                .font(.caption.weight(.semibold))
                .foregroundStyle(ColorInvoColor.text)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, minHeight: 88, alignment: .top)
        .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct ColorChoiceSeparator: View {
    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(ColorInvoColor.hairline)
                .frame(height: 1)

            Text("或")
                .font(.caption.weight(.semibold))
                .foregroundStyle(ColorInvoColor.muted)

            Rectangle()
                .fill(ColorInvoColor.hairline)
                .frame(height: 1)
        }
        .padding(.vertical, 2)
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
                Text("了解")
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
