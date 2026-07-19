import SwiftUI

struct Code39BarcodeView: View {
    @Environment(\.displayScale) private var displayScale

    let value: String
    var barColor: Color = .black
    var backgroundColor: Color = .white
    var showsCatDamage = false

    var body: some View {
        Canvas { context, size in
            let elements = Code39Encoder.elements(for: value)
            guard !elements.isEmpty else {
                return
            }

            let barRects = Code39BarcodeGeometry.barRects(
                for: elements,
                size: size,
                displayScale: displayScale
            )
            let spaceRects = Code39BarcodeGeometry.spaceRects(
                for: elements,
                size: size,
                displayScale: displayScale
            )

            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(backgroundColor))

            if showsCatDamage {
                BarcodeCatDamageRenderer.drawBarcode(
                    context: &context,
                    barRects: barRects,
                    spaceRects: spaceRects,
                    value: value,
                    size: size,
                    displayScale: displayScale,
                    barColor: barColor,
                    backgroundColor: backgroundColor
                )
            } else {
                for rect in barRects {
                    context.fill(Path(rect), with: .color(barColor))
                }
            }
        }
        .accessibilityLabel("手機條碼 \(value)")
    }
}

struct CarrierBarcodePanel: View {
    let value: String
    let palette: BarcodePalette
    var showsWave = false
    var showsValue = false
    var barcodeHeight: CGFloat = 96
    var horizontalPadding: CGFloat = 18
    var verticalPadding: CGFloat = 16
    var fillsAvailableSpace = false
    var dominantColors: [RGBAColor] = []
    var waveColor: RGBAColor?
    var showsCat = false

    var body: some View {
        Group {
            if showsWave || showsValue {
                decoratedPanel
            } else {
                plainPanel
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var plainPanel: some View {
        barcodeArtwork
        .frame(height: fillsAvailableSpace ? nil : barcodeHeight)
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, fillsAvailableSpace ? 0 : verticalPadding)
        .frame(
            maxWidth: .infinity,
            maxHeight: fillsAvailableSpace ? .infinity : nil
        )
        .background(palette.backgroundColor.color)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var decoratedPanel: some View {
        ZStack(alignment: .bottom) {
            palette.backgroundColor.color

            barcodeArtwork
            .frame(height: fillsAvailableSpace ? nil : barcodeHeight)
            .padding(.horizontal, horizontalPadding)
            .frame(
                maxWidth: .infinity,
                maxHeight: fillsAvailableSpace ? .infinity : nil,
                alignment: .top
            )

            if showsWave && !showsCat {
                CarrierBarcodeWaveShape()
                    .fill(waveFillColor)
                    .frame(height: waveHeight)
                    .scaleEffect(y: -1)
                    .frame(maxHeight: .infinity, alignment: .top)
            }

            if showsValue {
                CarrierBarcodeValueOverlay(
                    value: value,
                    palette: palette,
                    horizontalPadding: horizontalPadding
                )
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: fillsAvailableSpace ? .infinity : nil
        )
        .background(palette.backgroundColor.color)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var barcodeArtwork: some View {
        ZStack {
            Code39BarcodeView(
                value: value,
                barColor: palette.barColor.color,
                backgroundColor: palette.backgroundColor.color,
                showsCatDamage: showsCat
            )

            if showsCat {
                BarcodeCatOverlay(
                    barColor: palette.barColor.color,
                    backgroundColor: palette.backgroundColor.color
                )
            }
        }
    }

    private var waveHeight: CGFloat {
        barcodeHeight >= 120 ? 76 : 60
    }

    private var waveFillColor: Color {
        waveColor?.color
            ?? dominantColors.first?.color
            ?? RGBAColor(hex: 0x0066FF).color
    }
}

struct CarrierWidgetContentView: View {
    let carrierCode: String
    let palette: BarcodePalette
    let dominantColors: [RGBAColor]
    var waveColor: RGBAColor?
    var showsWave = true
    var showsBarcodeValue = true
    var showsCat = false
    var emptyStateText = "開啟 App 儲存載具"

    var body: some View {
        ZStack {
            palette.backgroundColor.color

            if CarrierCode.isValid(carrierCode) {
                CarrierBarcodePanel(
                    value: carrierCode,
                    palette: palette,
                    showsWave: showsWave,
                    showsValue: showsBarcodeValue,
                    barcodeHeight: 132,
                    horizontalPadding: 0,
                    verticalPadding: 8,
                    fillsAvailableSpace: true,
                    dominantColors: dominantColors,
                    waveColor: waveColor,
                    showsCat: showsCat
                )
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "barcode.viewfinder")
                        .font(.title2)
                    Text(emptyStateText)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                }
                .foregroundStyle(.secondary)
            }
        }
    }
}

private struct Code39BarcodeGeometry {
    static func barRects(
        for elements: [Code39Encoder.Element],
        size: CGSize,
        displayScale: CGFloat
    ) -> [CGRect] {
        elementRects(
            for: elements,
            size: size,
            displayScale: displayScale,
            matchingBars: true
        )
    }

    static func spaceRects(
        for elements: [Code39Encoder.Element],
        size: CGSize,
        displayScale: CGFloat
    ) -> [CGRect] {
        elementRects(
            for: elements,
            size: size,
            displayScale: displayScale,
            matchingBars: false
        )
    }

    private static func elementRects(
        for elements: [Code39Encoder.Element],
        size: CGSize,
        displayScale: CGFloat,
        matchingBars: Bool
    ) -> [CGRect] {
        let totalUnits = elements.reduce(0) { $0 + $1.units }
        guard totalUnits > 0 else {
            return []
        }

        let totalPixels = max(1, floor(size.width * displayScale))
        let pixelsPerUnit = totalPixels / CGFloat(totalUnits)
        var unitOffset = 0
        var rects: [CGRect] = []

        for element in elements {
            let startPixel = (CGFloat(unitOffset) * pixelsPerUnit).rounded()
            unitOffset += element.units
            let endPixel = (CGFloat(unitOffset) * pixelsPerUnit).rounded()

            guard element.isBar == matchingBars else {
                continue
            }

            rects.append(
                CGRect(
                    x: startPixel / displayScale,
                    y: 0,
                    width: max(1 / displayScale, (endPixel - startPixel) / displayScale),
                    height: size.height
                )
            )
        }

        return rects
    }
}

private struct BarcodeCatOverlay: View {
    let barColor: Color
    let backgroundColor: Color

    var body: some View {
        GeometryReader { proxy in
            let catFrame = BarcodeCatDecorationLayout.catFrame(in: proxy.size)
            let outline = max(1, catFrame.height * 0.012)

            ZStack {
                Image("CatBarcode")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(barColor)
                    .frame(width: catFrame.width, height: catFrame.height)
                    .shadow(color: backgroundColor, radius: 0, x: -outline, y: 0)
                    .shadow(color: backgroundColor, radius: 0, x: outline, y: 0)
                    .shadow(color: backgroundColor, radius: 0, x: 0, y: -outline)
                    .shadow(color: backgroundColor, radius: 0, x: 0, y: outline)
                    .position(x: catFrame.midX, y: catFrame.midY)

                Image("CatBarcodeDetails")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(backgroundColor)
                    .frame(width: catFrame.width, height: catFrame.height)
                    .position(x: catFrame.midX, y: catFrame.midY)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private enum BarcodeCatDecorationLayout {
    static let safeBarcodeHeightRatio: CGFloat = 0.39

    static func catFrame(in size: CGSize) -> CGRect {
        let imageAspectRatio = CGFloat(1106) / CGFloat(654)
        let height = min(
            size.height * 0.58,
            size.width * 0.46 / imageAspectRatio
        )
        let width = height * imageAspectRatio
        let bottomInset = max(1, size.height * 0.015)
        let centerX = size.width * 0.52
        let origin = CGPoint(
            x: centerX - width / 2,
            y: size.height - bottomInset - height
        )

        return CGRect(origin: origin, size: CGSize(width: width, height: height))
    }

    static func safeBarcodeY(in size: CGSize) -> CGFloat {
        size.height * safeBarcodeHeightRatio
    }

    static func groundY(in size: CGSize) -> CGFloat {
        catVisibleFrame(in: size).maxY
    }

    static func collisionY(for x: CGFloat, in size: CGSize) -> CGFloat {
        let visibleFrame = catVisibleFrame(in: size)
        let groundY = groundY(in: size)
        guard x >= visibleFrame.minX, x <= visibleFrame.maxX else {
            return groundY
        }

        let u = (x - visibleFrame.minX) / max(1, visibleFrame.width)
        let base: CGFloat = 0.76
        let lift = max(
            tent(u, center: 0.12, radius: 0.12) * 0.24,
            tent(u, center: 0.28, radius: 0.055) * 0.60,
            tent(u, center: 0.43, radius: 0.09) * 0.26,
            tent(u, center: 0.52, radius: 0.32) * 0.24,
            tent(u, center: 0.67, radius: 0.09) * 0.66,
            tent(u, center: 0.86, radius: 0.08) * 0.28
        )
        let topRatio = max(0.04, min(0.76, base - lift))

        return min(groundY, visibleFrame.minY + visibleFrame.height * topRatio)
    }

    static func interactionPressure(for x: CGFloat, in size: CGSize) -> CGFloat {
        let visibleFrame = catVisibleFrame(in: size)
        let paddedMinX = visibleFrame.minX - visibleFrame.width * 0.18
        let paddedMaxX = visibleFrame.maxX + visibleFrame.width * 0.18
        guard x >= paddedMinX, x <= paddedMaxX else {
            return 0
        }

        let distanceFromCenter = abs(x - visibleFrame.midX)
        let radius = visibleFrame.width * 0.68
        return max(0, 1 - distanceFromCenter / max(1, radius))
    }

    static func pawScratchPressure(for x: CGFloat, in size: CGSize) -> CGFloat {
        let visibleFrame = catVisibleFrame(in: size)
        guard x >= visibleFrame.minX, x <= visibleFrame.maxX else {
            return 0
        }

        let u = (x - visibleFrame.minX) / max(1, visibleFrame.width)
        return max(
            tent(u, center: 0.46, radius: 0.085),
            tent(u, center: 0.66, radius: 0.095)
        )
    }

    static func pawScratchDeflection(
        for x: CGFloat,
        in size: CGSize,
        fallbackDirection: CGFloat
    ) -> CGFloat {
        let visibleFrame = catVisibleFrame(in: size)
        guard x >= visibleFrame.minX, x <= visibleFrame.maxX else {
            return 0
        }

        let u = (x - visibleFrame.minX) / max(1, visibleFrame.width)
        let leftPaw = tent(u, center: 0.46, radius: 0.085)
        let rightPaw = tent(u, center: 0.66, radius: 0.095)
        let leftDirection: CGFloat = u < 0.46 ? -1 : 1
        let rightDirection: CGFloat = u < 0.66 ? -1 : 1
        let force = leftPaw * leftDirection + rightPaw * rightDirection

        if abs(force) < 0.04 {
            return fallbackDirection * max(leftPaw, rightPaw) * 0.30
        }

        return max(-1, min(1, force))
    }

    private static func catVisibleFrame(in size: CGSize) -> CGRect {
        let frame = catFrame(in: size)
        let minXRatio = CGFloat(0.122)
        let minYRatio = CGFloat(0.203)
        let maxXRatio = CGFloat(0.853)
        let maxYRatio = CGFloat(0.830)

        return CGRect(
            x: frame.minX + frame.width * minXRatio,
            y: frame.minY + frame.height * minYRatio,
            width: frame.width * (maxXRatio - minXRatio),
            height: frame.height * (maxYRatio - minYRatio)
        )
    }

    private static func tent(
        _ value: CGFloat,
        center: CGFloat,
        radius: CGFloat
    ) -> CGFloat {
        max(0, 1 - abs(value - center) / radius)
    }
}

private enum BarcodeCatDamageRenderer {
    static func drawBarcode(
        context: inout GraphicsContext,
        barRects: [CGRect],
        spaceRects: [CGRect],
        value: String,
        size: CGSize,
        displayScale: CGFloat,
        barColor: Color,
        backgroundColor: Color
    ) {
        let safeY = BarcodeCatDecorationLayout.safeBarcodeY(in: size)
        let pixel = 1 / displayScale
        let seed = BarcodeCatDamageSeed(value: value)

        for (index, rect) in barRects.enumerated() {
            let safeRect = CGRect(
                x: rect.minX,
                y: 0,
                width: rect.width,
                height: min(size.height, safeY + pixel)
            )
            context.fill(Path(safeRect), with: .color(barColor))

            guard safeY < size.height else {
                continue
            }

            let damagedPath = warpedLowerBarPath(
                rect: rect,
                index: index,
                seed: seed,
                size: size,
                safeY: safeY,
                displayScale: displayScale
            )
            context.fill(damagedPath, with: .color(barColor))
        }

        for (index, rect) in barRects.enumerated() {
            let stripPath = tornStripPath(
                rect: rect,
                index: index,
                seed: seed,
                size: size,
                safeY: safeY,
                displayScale: displayScale
            )
            context.fill(stripPath, with: .color(barColor))
        }

        for (index, rect) in collisionSpaceRects(from: spaceRects, size: size, pixel: pixel) {
            let pulledPath = pulledSpacePath(
                rect: rect,
                index: index,
                seed: seed,
                size: size,
                safeY: safeY,
                displayScale: displayScale
            )
            context.fill(pulledPath, with: .color(backgroundColor))
        }
    }

    private static func warpedLowerBarPath(
        rect: CGRect,
        index: Int,
        seed: BarcodeCatDamageSeed,
        size: CGSize,
        safeY: CGFloat,
        displayScale: CGFloat
    ) -> Path {
        let tear = barTearProfile(
            rect: rect,
            index: index,
            seed: seed,
            size: size,
            safeY: safeY,
            displayScale: displayScale
        )
        let steps = 7
        let pixel = 1 / displayScale
        let minimumWidth = max(pixel, rect.width * 0.62)
        var leftPoints: [CGPoint] = []
        var rightPoints: [CGPoint] = []

        for step in 0...steps {
            let t = CGFloat(step) / CGFloat(steps)
            let leftY = safeY + max(0, tear.leftStopY - safeY) * t
            let rightY = safeY + max(0, tear.rightStopY - safeY) * t
            let offset = lowerOffset(
                rect: rect,
                index: index,
                t: t,
                seed: seed,
                size: size
            )
            let widthPulse = seed.signed(UInt64(700 + index)) * rect.width * 0.08 * t
            let leftX = rect.minX + offset - widthPulse
            let rightX = max(leftX + minimumWidth, rect.maxX + offset + widthPulse)

            leftPoints.append(CGPoint(x: leftX, y: leftY))
            rightPoints.append(CGPoint(x: rightX, y: rightY))
        }

        var path = Path()
        guard let firstPoint = leftPoints.first else {
            return path
        }

        path.move(to: firstPoint)
        for point in leftPoints.dropFirst() {
            path.addLine(to: point)
        }

        for point in rightPoints.reversed() {
            path.addLine(to: point)
        }

        path.closeSubpath()
        return path
    }

    private static func tornStripPath(
        rect: CGRect,
        index: Int,
        seed: BarcodeCatDamageSeed,
        size: CGSize,
        safeY: CGFloat,
        displayScale: CGFloat
    ) -> Path {
        let tear = barTearProfile(
            rect: rect,
            index: index,
            seed: seed,
            size: size,
            safeY: safeY,
            displayScale: displayScale
        )
        guard tear.drawStrip else {
            return Path()
        }

        let steps = 4
        let pixel = 1 / displayScale
        let width = max(pixel, rect.width * tear.stripWidthRatio)
        var leftPoints: [CGPoint] = []
        var rightPoints: [CGPoint] = []

        for step in 0...steps {
            let t = CGFloat(step) / CGFloat(steps)
            let y = tear.stripStartY + max(0, tear.stripEndY - tear.stripStartY) * t
            let offset = lowerOffset(
                rect: rect,
                index: index,
                t: 1,
                seed: seed,
                size: size
            )
            let flapDrift = seed.signed(UInt64(1_520 + index + step)) * rect.width * 0.12 * t
            let centerX = rect.midX
                + offset
                + rect.width * tear.stripHorizontalBias * t
                + flapDrift

            leftPoints.append(CGPoint(x: centerX - width / 2, y: y))
            rightPoints.append(CGPoint(x: centerX + width / 2, y: y))
        }

        var path = Path()
        guard let firstPoint = leftPoints.first else {
            return path
        }

        path.move(to: firstPoint)
        for point in leftPoints.dropFirst() {
            path.addLine(to: point)
        }

        for point in rightPoints.reversed() {
            path.addLine(to: point)
        }

        path.closeSubpath()
        return path
    }

    private static func pulledSpacePath(
        rect: CGRect,
        index: Int,
        seed: BarcodeCatDamageSeed,
        size: CGSize,
        safeY: CGFloat,
        displayScale: CGFloat
    ) -> Path {
        let stopY = scratchContactY(
            for: rect.midX,
            in: size,
            safeY: safeY,
            displayScale: displayScale
        )
        let lowerHeight = max(0, stopY - safeY)
        let steps = 7
        let pixel = 1 / displayScale
        let stripeWidth = max(pixel, rect.width)
        var leftPoints: [CGPoint] = []
        var rightPoints: [CGPoint] = []

        for step in 0...steps {
            let t = CGFloat(step) / CGFloat(steps)
            let y = safeY + lowerHeight * t
            let offset = lowerOffset(
                rect: rect,
                index: index,
                t: t,
                seed: seed,
                size: size
            )
            let centerX = rect.midX + offset

            leftPoints.append(CGPoint(x: centerX - stripeWidth / 2, y: y))
            rightPoints.append(CGPoint(x: centerX + stripeWidth / 2, y: y))
        }

        var path = Path()
        guard let firstPoint = leftPoints.first else {
            return path
        }

        path.move(to: firstPoint)
        for point in leftPoints.dropFirst() {
            path.addLine(to: point)
        }

        for point in rightPoints.reversed() {
            path.addLine(to: point)
        }

        path.closeSubpath()
        return path
    }

    private static func collisionSpaceRects(
        from rects: [CGRect],
        size: CGSize,
        pixel: CGFloat
    ) -> [(Int, CGRect)] {
        let catFrame = BarcodeCatDecorationLayout.catFrame(in: size)
        let interactionMinX = catFrame.minX - catFrame.width * 0.08
        let interactionMaxX = catFrame.maxX + catFrame.width * 0.08
        let maximumInternalSpaceWidth = size.width * 0.05

        return rects.enumerated().filter { _, rect in
            rect.width >= pixel
                && rect.width <= maximumInternalSpaceWidth
                && rect.midX >= interactionMinX
                && rect.midX <= interactionMaxX
        }
    }

    private static func lowerOffset(
        rect: CGRect,
        index: Int,
        t: CGFloat,
        seed: BarcodeCatDamageSeed,
        size: CGSize
    ) -> CGFloat {
        let catFrame = BarcodeCatDecorationLayout.catFrame(in: size)
        let normalizedDistance = (rect.midX - catFrame.midX) / max(1, catFrame.width * 0.72)
        let pressure = max(0, 1 - min(1, abs(normalizedDistance)))
        let direction: CGFloat = normalizedDistance < 0 ? -1 : 1
        let bend = t * t * (3 - 2 * t)
        let shove = direction
            * pressure
            * size.width
            * 0.011
            * (sin(.pi * t) * 0.45 + bend * 0.55)
        let pawShove = BarcodeCatDecorationLayout.pawScratchDeflection(
            for: rect.midX,
            in: size,
            fallbackDirection: seed.signed(UInt64(760 + index)) < 0 ? -1 : 1
        )
            * size.width
            * 0.010
            * bend

        let phase = seed.unit(UInt64(720 + index)) * .pi * 2
        let wave = sin((t * 2.4 + 0.2) * .pi + phase)
            * size.width
            * (0.003 + seed.unit(UInt64(740 + index)) * 0.004)
            * t

        return shove + pawShove + wave
    }

    private static func scratchContactY(
        for x: CGFloat,
        in size: CGSize,
        safeY: CGFloat,
        displayScale: CGFloat
    ) -> CGFloat {
        let pixel = 1 / displayScale
        let collisionY = BarcodeCatDecorationLayout.collisionY(for: x, in: size)
        let pawPressure = BarcodeCatDecorationLayout.pawScratchPressure(for: x, in: size)

        return max(
            safeY + pixel,
            collisionY - size.height * (0.010 + pawPressure * 0.060)
        )
    }

    private static func barTearProfile(
        rect: CGRect,
        index: Int,
        seed: BarcodeCatDamageSeed,
        size: CGSize,
        safeY: CGFloat,
        displayScale: CGFloat
    ) -> BarTearProfile {
        let pixel = 1 / displayScale
        let pressure = BarcodeCatDecorationLayout.interactionPressure(for: rect.midX, in: size)
        let pawPressure = BarcodeCatDecorationLayout.pawScratchPressure(for: rect.midX, in: size)
        let contactY = scratchContactY(
            for: rect.midX,
            in: size,
            safeY: safeY,
            displayScale: displayScale
        )
        let tearChance = seed.unit(UInt64(1_000 + index))
        let shouldBreakEarly = pressure > 0.16 && (tearChance > 0.42 || pawPressure > 0.55)
        let maximumLift = size.height * (0.05 + pressure * 0.13 + pawPressure * 0.075)
        let lift = shouldBreakEarly
            ? maximumLift * (0.35 + seed.unit(UInt64(1_040 + index)) * 0.65)
            : 0
        let baseStopY = max(safeY + size.height * 0.05, contactY - lift)
        let raggedness = shouldBreakEarly
            ? size.height * (0.012 + seed.unit(UInt64(1_080 + index)) * 0.035) * max(pressure, pawPressure)
            : size.height * 0.004 * max(pressure, pawPressure)
        let leftStopY = max(
            safeY + pixel,
            min(contactY - pixel, baseStopY + seed.signed(UInt64(1_120 + index)) * raggedness)
        )
        let rightStopY = max(
            safeY + pixel,
            min(contactY - pixel, baseStopY + seed.signed(UInt64(1_160 + index)) * raggedness)
        )
        let stripStartY = min(leftStopY, rightStopY) - pixel
        let stripLength = min(
            contactY - stripStartY - pixel,
            size.height * (0.026 + seed.unit(UInt64(1_240 + index)) * 0.070) * max(pressure, pawPressure)
        )
        let drawStrip = shouldBreakEarly
            && rect.width > pixel * 1.5
            && stripLength > pixel * 3
            && seed.unit(UInt64(1_280 + index)) > 0.38

        return BarTearProfile(
            leftStopY: leftStopY,
            rightStopY: rightStopY,
            stripStartY: stripStartY,
            stripEndY: stripStartY + max(0, stripLength),
            stripWidthRatio: 0.34 + seed.unit(UInt64(1_320 + index)) * 0.34,
            stripHorizontalBias: seed.signed(UInt64(1_360 + index)) * 0.20,
            drawStrip: drawStrip
        )
    }

    private struct BarTearProfile {
        let leftStopY: CGFloat
        let rightStopY: CGFloat
        let stripStartY: CGFloat
        let stripEndY: CGFloat
        let stripWidthRatio: CGFloat
        let stripHorizontalBias: CGFloat
        let drawStrip: Bool
    }

}

private struct BarcodeCatDamageSeed {
    private let value: UInt64

    init(value text: String) {
        var hash: UInt64 = 1_469_598_103_934_665_603
        for byte in "cat-barcode-v1|\(text)".utf8 {
            hash ^= UInt64(byte)
            hash &*= 1_099_511_628_211
        }
        value = hash
    }

    func unit(_ salt: UInt64) -> CGFloat {
        var number = value &+ salt &* 0x9E37_79B9_7F4A_7C15
        number = (number ^ (number >> 30)) &* 0xBF58_476D_1CE4_E5B9
        number = (number ^ (number >> 27)) &* 0x94D0_49BB_1331_11EB
        number ^= number >> 31

        return CGFloat(Double(number >> 11) / 9_007_199_254_740_992)
    }

    func signed(_ salt: UInt64) -> CGFloat {
        unit(salt) * 2 - 1
    }
}

private struct CarrierBarcodeValueOverlay: View {
    let value: String
    let palette: BarcodePalette
    let horizontalPadding: CGFloat

    private var edgeInset: CGFloat {
        max(8, horizontalPadding + 8)
    }

    var body: some View {
        Text(value)
            .font(.system(.caption, design: .monospaced, weight: .bold))
            .fontWidth(.condensed)
            .foregroundStyle(palette.backgroundColor.color)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .padding(.horizontal, 8)
            .frame(height: 20)
            .background {
                Capsule(style: .continuous)
                    .fill(palette.barColor.color)
            }
            .padding(.trailing, edgeInset)
            .padding(.bottom, edgeInset)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
    }
}

private struct CarrierBarcodeWaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        // Path coordinates are normalized from the downloaded Wave.svg reference.
        let baseY: CGFloat = 259.571
        let spanY: CGFloat = 341.429

        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(
                x: rect.minX + rect.width * x / 900,
                y: rect.minY + rect.height * (y - baseY) / spanY
            )
        }

        var path = Path()
        path.move(to: point(0, 601))
        path.addLine(to: point(0, 435.3))
        path.addCurve(
            to: point(107.8, 313.2),
            control1: point(8.5, 397.7),
            control2: point(42, 313.274)
        )
        path.addCurve(
            to: point(275.2, 519.5),
            control1: point(193.926, 313.103),
            control2: point(189.338, 516.203)
        )
        path.addCurve(
            to: point(450, 380),
            control1: point(365.968, 522.985),
            control2: point(378.1, 381)
        )
        path.addCurve(
            to: point(629.8, 457.5),
            control1: point(523.814, 378.973),
            control2: point(569.117, 460.46)
        )
        path.addCurve(
            to: point(807.394, 259.571),
            control1: point(702.511, 453.953),
            control2: point(704.125, 259.815)
        )
        path.addCurve(
            to: point(900, 381),
            control1: point(887.814, 259.381),
            control2: point(900, 381)
        )
        path.addLine(to: point(900, 601))
        path.addLine(to: point(0, 601))
        path.closeSubpath()
        return path
    }
}

enum Code39Encoder {
    struct Element: Equatable {
        let isBar: Bool
        let units: Int
    }

    private static let narrow = 1
    private static let wide = 3
    private static let quietZone = 10
    private static let interCharacterGap = 1

    private static let patterns: [Character: String] = [
        "0": "nnnwwnwnn",
        "1": "wnnwnnnnw",
        "2": "nnwwnnnnw",
        "3": "wnwwnnnnn",
        "4": "nnnwwnnnw",
        "5": "wnnwwnnnn",
        "6": "nnwwwnnnn",
        "7": "nnnwnnwnw",
        "8": "wnnwnnwnn",
        "9": "nnwwnnwnn",
        "A": "wnnnnwnnw",
        "B": "nnwnnwnnw",
        "C": "wnwnnwnnn",
        "D": "nnnnwwnnw",
        "E": "wnnnwwnnn",
        "F": "nnwnwwnnn",
        "G": "nnnnnwwnw",
        "H": "wnnnnwwnn",
        "I": "nnwnnwwnn",
        "J": "nnnnwwwnn",
        "K": "wnnnnnnww",
        "L": "nnwnnnnww",
        "M": "wnwnnnnwn",
        "N": "nnnnwnnww",
        "O": "wnnnwnnwn",
        "P": "nnwnwnnwn",
        "Q": "nnnnnnwww",
        "R": "wnnnnnwwn",
        "S": "nnwnnnwwn",
        "T": "nnnnwnwwn",
        "U": "wwnnnnnnw",
        "V": "nwwnnnnnw",
        "W": "wwwnnnnnn",
        "X": "nwnnwnnnw",
        "Y": "wwnnwnnnn",
        "Z": "nwwnwnnnn",
        "-": "nwnnnnwnw",
        ".": "wwnnnnwnn",
        " ": "nwwnnnwnn",
        "$": "nwnwnwnnn",
        "/": "nwnwnnnwn",
        "+": "nwnnnwnwn",
        "%": "nnnwnwnwn",
        "*": "nwnnwnwnn",
    ]

    static func elements(for value: String) -> [Element] {
        let characters = Array("*\(value)*")
        guard characters.allSatisfy({ patterns[$0] != nil }) else {
            return []
        }

        var elements = [Element(isBar: false, units: quietZone)]

        for (characterIndex, character) in characters.enumerated() {
            guard let pattern = patterns[character] else {
                return []
            }

            for (elementIndex, marker) in pattern.enumerated() {
                elements.append(
                    Element(
                        isBar: elementIndex.isMultiple(of: 2),
                        units: marker == "w" ? wide : narrow
                    )
                )
            }

            if characterIndex != characters.indices.last {
                elements.append(Element(isBar: false, units: interCharacterGap))
            }
        }

        elements.append(Element(isBar: false, units: quietZone))

        return elements
    }

    static func visibleBarcodeInset(for value: String, width: CGFloat) -> CGFloat {
        let totalUnits = elements(for: value).reduce(0) { $0 + $1.units }
        guard totalUnits > 0 else {
            return 0
        }

        return width * CGFloat(quietZone) / CGFloat(totalUnits)
    }
}
