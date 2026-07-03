import Foundation
import PhotosUI
import SwiftUI
import UIKit
import WidgetKit

@MainActor
final class CarrierEditorModel: ObservableObject {
    @Published private(set) var draftCode = ""
    @Published private(set) var draftPalette: BarcodePalette = .classic
    @Published private(set) var savedSettings: CarrierSettings = .empty
    @Published var wallpaperPickerItem: PhotosPickerItem?
    @Published private(set) var wallpaperPreviewImage: WallpaperPreviewImage?
    @Published private(set) var wallpaperPalettes: [BarcodePalette] = []
    @Published private(set) var wallpaperDominantColors: [RGBAColor] = []
    @Published private(set) var wallpaperStatusText: String?
    @Published private(set) var isAnalyzingWallpaper = false

    private static let autosaveDelayNanoseconds: UInt64 = 300_000_000

    private let pipeline: CarrierAppPipeline
    private var autosaveTask: Task<Void, Never>?
    private var wallpaperTask: Task<Void, Never>?
    private var wallpaperRequestID = UUID()
    private var hasLoadedInitialState = false
    private var isLoadingInitialState = false
    private var paletteRevision = 0
    private var widgetNeedsReload = false

    init(pipeline: CarrierAppPipeline = CarrierAppPipeline()) {
        self.pipeline = pipeline
    }

    deinit {
        autosaveTask?.cancel()
        wallpaperTask?.cancel()
    }

    var normalizedCode: String {
        CarrierCode.normalize(draftCode)
    }

    var isValid: Bool {
        CarrierCode.isValid(normalizedCode)
    }

    var canAutoSave: Bool {
        isValid && draftPalette.meetsCommercialGuidance
    }

    var draftSettings: CarrierSettings? {
        guard canAutoSave, let carrierCode = CarrierCode(normalizedCode) else {
            return nil
        }

        return CarrierSettings(
            carrierCode: carrierCode.value,
            palette: draftPalette,
            wallpaperDominantColors: wallpaperDominantColors
        )
    }

    var widgetIsReady: Bool {
        draftSettings == savedSettings
    }

    var widgetStatusText: String {
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

    var carrierSuffix: String {
        let code = CarrierCode.normalize(draftCode)
        guard code.hasPrefix("/") else {
            return code
        }

        return String(code.dropFirst())
    }

    var validationText: String {
        if isValid {
            return "格式符合"
        }

        return carrierSuffix.isEmpty ? "未填" : "格式不符"
    }

    func start() async {
        guard !hasLoadedInitialState, !isLoadingInitialState else {
            return
        }

        isLoadingInitialState = true
        defer {
            isLoadingInitialState = false
        }

        let snapshot = await pipeline.loadInitialSnapshot()
        guard !Task.isCancelled else {
            return
        }

        apply(snapshot)
        hasLoadedInitialState = true
    }

    func updateCarrierSuffix(_ newValue: String) {
        let suffix = CarrierCode.normalize(newValue)
            .replacingOccurrences(of: "/", with: "")
        let nextCode = suffix.isEmpty ? "" : "/\(suffix)"
        guard draftCode != nextCode else {
            return
        }

        draftCode = nextCode
        scheduleAutosave()
    }

    func selectPalette(_ palette: BarcodePalette) {
        guard draftPalette != palette else {
            return
        }

        draftPalette = palette
        paletteRevision += 1
        scheduleAutosave()
    }

    func updateBackgroundColor(_ color: Color) {
        updatePalette(draftPalette.replacing(backgroundColor: RGBAColor(color: color)))
    }

    func updateBarColor(_ color: Color) {
        updatePalette(draftPalette.replacing(barColor: RGBAColor(color: color)))
    }

    func loadWallpaperPalettes(from item: PhotosPickerItem?) {
        wallpaperTask?.cancel()
        wallpaperRequestID = UUID()
        let requestID = wallpaperRequestID
        let paletteRevisionAtStart = paletteRevision

        guard let item else {
            isAnalyzingWallpaper = false
            return
        }

        isAnalyzingWallpaper = true
        wallpaperStatusText = nil

        wallpaperTask = Task { [weak self, pipeline] in
            do {
                guard
                    let data = try await item.loadTransferable(type: Data.self)
                else {
                    await self?.showWallpaperFailure(requestID: requestID)
                    return
                }

                guard !Task.isCancelled else {
                    return
                }

                guard let result = await pipeline.processWallpaperData(data) else {
                    await self?.showWallpaperFailure(requestID: requestID)
                    return
                }

                guard !Task.isCancelled else {
                    return
                }

                await self?.applyWallpaperResult(
                    result,
                    requestID: requestID,
                    paletteRevisionAtStart: paletteRevisionAtStart
                )
            } catch is CancellationError {
                return
            } catch {
                await self?.showWallpaperFailure(requestID: requestID)
            }
        }
    }

    func reloadWidgetIfNeeded() {
        guard widgetNeedsReload else {
            return
        }

        widgetNeedsReload = false
        Task { [pipeline] in
            await pipeline.reloadWidgetTimeline()
        }
    }

    private func apply(_ snapshot: CarrierEditorSnapshot) {
        autosaveTask?.cancel()
        savedSettings = snapshot.settings
        draftCode = snapshot.settings.carrierCode
        draftPalette = snapshot.settings.palette
        paletteRevision = 0
        wallpaperDominantColors = snapshot.settings.wallpaperDominantColors
        wallpaperPreviewImage = snapshot.previewImage
        wallpaperPalettes = snapshot.wallpaperPalettes
        wallpaperStatusText = nil
        isAnalyzingWallpaper = false
        widgetNeedsReload = false
    }

    private func updatePalette(_ palette: BarcodePalette) {
        guard draftPalette != palette else {
            return
        }

        draftPalette = palette
        paletteRevision += 1
        scheduleAutosave()
    }

    private func scheduleAutosave() {
        autosaveTask?.cancel()

        guard let settings = draftSettings, settings != savedSettings else {
            return
        }

        autosaveTask = Task { [weak self, pipeline] in
            do {
                try await Task.sleep(nanoseconds: Self.autosaveDelayNanoseconds)
            } catch {
                return
            }

            await pipeline.save(settings)

            guard !Task.isCancelled else {
                return
            }

            await self?.finishAutosave(settings)
        }
    }

    private func finishAutosave(_ settings: CarrierSettings) {
        guard draftSettings == settings else {
            return
        }

        savedSettings = settings
        widgetNeedsReload = true
    }

    private func applyWallpaperResult(
        _ result: WallpaperPipelineResult,
        requestID: UUID,
        paletteRevisionAtStart: Int
    ) {
        guard wallpaperRequestID == requestID else {
            return
        }

        wallpaperPreviewImage = result.previewImage
        wallpaperDominantColors = result.sourceColors
        wallpaperPalettes = result.palettes
        wallpaperStatusText = nil
        isAnalyzingWallpaper = false

        if paletteRevision == paletteRevisionAtStart, let firstPalette = result.palettes.first {
            draftPalette = firstPalette
        }

        scheduleAutosave()
    }

    private func showWallpaperFailure(requestID: UUID) {
        guard wallpaperRequestID == requestID else {
            return
        }

        wallpaperPalettes = []
        wallpaperStatusText = "無法讀取圖片"
        isAnalyzingWallpaper = false
    }
}

struct CarrierEditorSnapshot: Sendable {
    let settings: CarrierSettings
    let previewImage: WallpaperPreviewImage?
    let wallpaperPalettes: [BarcodePalette]
}

struct WallpaperPipelineResult: Sendable {
    let previewImage: WallpaperPreviewImage?
    let sourceColors: [RGBAColor]
    let palettes: [BarcodePalette]
}

actor CarrierAppPipeline {
    func loadInitialSnapshot() -> CarrierEditorSnapshot {
        let usesShowcaseData = ColorInvoRuntime.showcaseDataEnabled
        let settings = usesShowcaseData ? CarrierSettings.showcase : CarrierStore.load()
        let previewImage = usesShowcaseData
            ? WallpaperPreviewStore.showcaseImage()
            : WallpaperPreviewStore.load()
        let palettes = usesShowcaseData ? BarcodePalette.showcaseOptions : []

        return CarrierEditorSnapshot(
            settings: settings,
            previewImage: previewImage,
            wallpaperPalettes: palettes
        )
    }

    func processWallpaperData(_ data: Data) -> WallpaperPipelineResult? {
        guard let analysis = WallpaperImageAnalyzer.analyze(data) else {
            return nil
        }

        return WallpaperPipelineResult(
            previewImage: WallpaperPreviewStore.savePreviewData(analysis.previewData),
            sourceColors: analysis.sourceColors,
            palettes: analysis.palettes
        )
    }

    func save(_ settings: CarrierSettings) {
        CarrierStore.save(settings)
    }

    func reloadWidgetTimeline() {
        WidgetCenter.shared.reloadTimelines(ofKind: CarrierWidgetKind.colorInvo)
    }
}
