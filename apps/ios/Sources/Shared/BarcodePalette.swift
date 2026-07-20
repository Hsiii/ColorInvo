import Foundation
import SwiftUI
import UIKit

struct BarcodePalette: Codable, Equatable, Identifiable, Sendable {
    var name: String
    var barColor: RGBAColor
    var backgroundColor: RGBAColor

    static let symbolContrastStandard = 0.70
    static let minimumBackgroundReflectance = 0.70

    var id: String {
        "\(name)-\(barColor.identity)-\(backgroundColor.identity)"
    }

    var meetsCommercialGuidance: Bool {
        backgroundScannerReflectance >= Self.minimumBackgroundReflectance
            && barScannerReflectance <= backgroundScannerReflectance / 2
            && scannerSymbolContrast >= Self.symbolContrastStandard
            && !barColor.isReddish
    }

    var barScannerReflectance: Double {
        barColor.scannerReflectance
    }

    var backgroundScannerReflectance: Double {
        backgroundColor.scannerReflectance
    }

    var scannerSymbolContrast: Double {
        max(0, backgroundScannerReflectance - barScannerReflectance)
    }

    var contrastSummary: String {
        let comparisonOperator = scannerSymbolContrast >= Self.symbolContrastStandard
            ? "≥"
            : "<"

        return String(
            format: "符號反差 %.0f%% %@ %.0f%%",
            scannerSymbolContrast * 100,
            comparisonOperator,
            Self.symbolContrastStandard * 100
        )
    }

    var standardMessage: String {
        if meetsCommercialGuidance {
            return "可掃描配色"
        }

        if barColor.isReddish {
            return "條碼勿用紅系"
        }

        if backgroundScannerReflectance < Self.minimumBackgroundReflectance {
            return "背景與靜區要更亮"
        }

        if barScannerReflectance > backgroundScannerReflectance / 2 {
            return "條碼在紅光下要更深"
        }

        return "符號反差不足"
    }

    func replacing(
        barColor: RGBAColor? = nil,
        backgroundColor: RGBAColor? = nil
    ) -> BarcodePalette {
        BarcodePalette(
            name: "自訂",
            barColor: barColor ?? self.barColor,
            backgroundColor: backgroundColor ?? self.backgroundColor
        )
    }

    static let classic = BarcodePalette(
        name: "經典黑白",
        barColor: RGBAColor(hex: 0x000000),
        backgroundColor: RGBAColor(hex: 0xFFFFFF)
    )

    static let showcase = BarcodePalette(
        name: "桌布清亮",
        barColor: RGBAColor(hex: 0x063F52),
        backgroundColor: RGBAColor(hex: 0xEAF8FF)
    )

    static let showcaseLogoBlue = BarcodePalette(
        name: "標誌藍",
        barColor: RGBAColor(hex: 0x003F52),
        backgroundColor: RGBAColor(hex: 0xBFEAFF)
    )

    static let showcaseLogoYellow = BarcodePalette(
        name: "標誌黃",
        barColor: RGBAColor(hex: 0x063F52),
        backgroundColor: RGBAColor(hex: 0xFFF3D1)
    )

    static let showcaseOptions = [
        BarcodePalette(
            name: "桌布對比",
            barColor: RGBAColor(hex: 0x073B4C),
            backgroundColor: RGBAColor(hex: 0xECFBF5)
        ),
        BarcodePalette(
            name: "桌布柔光",
            barColor: RGBAColor(hex: 0x102F5A),
            backgroundColor: RGBAColor(hex: 0xF1F6FF)
        ),
        showcase
    ]

    static let showcaseSourceColors = [
        RGBAColor(hex: 0x59BAC9),
        RGBAColor(hex: 0xFFB876),
        RGBAColor(hex: 0x396791),
    ]

    static let logoBlue = RGBAColor(hex: 0x70D6FF)
    static let logoDarkYellow = RGBAColor(hex: 0xD09A00)
}

struct RGBAColor: Codable, Equatable, Sendable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double

    init(red: Double, green: Double, blue: Double, alpha: Double = 1) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    init(hex: UInt32) {
        red = Double((hex >> 16) & 0xFF) / 255
        green = Double((hex >> 8) & 0xFF) / 255
        blue = Double(hex & 0xFF) / 255
        alpha = 1
    }

    init(color: Color) {
        var redValue: CGFloat = 0
        var greenValue: CGFloat = 0
        var blueValue: CGFloat = 0
        var alphaValue: CGFloat = 0

        if UIColor(color).getRed(
            &redValue,
            green: &greenValue,
            blue: &blueValue,
            alpha: &alphaValue
        ) {
            self.init(
                red: Double(redValue),
                green: Double(greenValue),
                blue: Double(blueValue),
                alpha: Double(alphaValue)
            )
        } else {
            self.init(hex: 0x000000)
        }
    }

    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }

    var relativeLuminance: Double {
        let linearRed = linearized(red)
        let linearGreen = linearized(green)
        let linearBlue = linearized(blue)

        return 0.2126 * linearRed
            + 0.7152 * linearGreen
            + 0.0722 * linearBlue
    }

    var scannerReflectance: Double {
        // Approximate red-light scanner reflectance for color-picking guidance.
        red
    }

    var isReddish: Bool {
        let maximum = max(red, green, blue)
        let minimum = min(red, green, blue)
        let chroma = maximum - minimum

        guard chroma > 0.12, maximum > 0.18 else {
            return false
        }

        let hue: Double
        if maximum == red {
            hue = 60 * ((green - blue) / chroma).truncatingRemainder(dividingBy: 6)
        } else if maximum == green {
            hue = 60 * (((blue - red) / chroma) + 2)
        } else {
            hue = 60 * (((red - green) / chroma) + 4)
        }

        let normalizedHue = hue < 0 ? hue + 360 : hue

        return normalizedHue <= 40 || normalizedHue >= 340
    }

    var identity: String {
        [
            red,
            green,
            blue,
            alpha,
        ]
        .map { String(Int(($0 * 10_000).rounded())) }
        .joined(separator: ",")
    }

    private func linearized(_ channel: Double) -> Double {
        if channel <= 0.03928 {
            return channel / 12.92
        }

        return pow((channel + 0.055) / 1.055, 2.4)
    }
}

enum WallpaperPaletteGenerator {
    private static let symbolContrastCushion = 0.02

    static func dominantColor(from image: UIImage) -> RGBAColor? {
        representativeColors(from: image).first
    }

    static func representativeColors(from image: UIImage) -> [RGBAColor] {
        let sampleWidth = 40
        let sampleHeight = 40
        let sampleSize = CGSize(width: sampleWidth, height: sampleHeight)
        let rendererFormat = UIGraphicsImageRendererFormat()
        rendererFormat.scale = 1

        let thumbnail = UIGraphicsImageRenderer(
            size: sampleSize,
            format: rendererFormat
        ).image { _ in
            image.draw(in: CGRect(origin: .zero, size: sampleSize))
        }

        guard let thumbnailImage = thumbnail.cgImage else {
            return []
        }

        return representativeColors(from: thumbnailImage)
    }

    static func representativeColors(from image: CGImage) -> [RGBAColor] {
        let sampleWidth = 40
        let sampleHeight = 40
        let sampleSize = CGSize(width: sampleWidth, height: sampleHeight)
        var pixels = [UInt8](repeating: 0, count: sampleWidth * sampleHeight * 4)
        guard let context = CGContext(
            data: &pixels,
            width: sampleWidth,
            height: sampleHeight,
            bitsPerComponent: 8,
            bytesPerRow: sampleWidth * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return []
        }

        context.interpolationQuality = .low
        context.draw(image, in: CGRect(origin: .zero, size: sampleSize))

        var buckets: [Int: ColorBucket] = [:]

        for offset in stride(from: 0, to: pixels.count, by: 4) {
            let alpha = Double(pixels[offset + 3]) / 255
            guard alpha > 0.5 else {
                continue
            }

            let red = Double(pixels[offset]) / 255
            let green = Double(pixels[offset + 1]) / 255
            let blue = Double(pixels[offset + 2]) / 255
            let saturation = saturation(red: red, green: green, blue: blue)
            let key = quantizedKey(red: red, green: green, blue: blue)
            let weight = 1 + saturation * 0.35
            var bucket = buckets[key] ?? ColorBucket()

            bucket.weight += weight
            bucket.red += red * weight
            bucket.green += green * weight
            bucket.blue += blue * weight
            buckets[key] = bucket
        }

        let candidates = buckets.values
            .compactMap { bucket -> PaletteSource? in
                guard bucket.weight > 0 else {
                    return nil
                }

                let color = RGBAColor(
                    red: bucket.red / bucket.weight,
                    green: bucket.green / bucket.weight,
                    blue: bucket.blue / bucket.weight
                )
                let hsb = color.hueSaturationBrightness
                let score = bucket.weight * (0.72 + hsb.saturation * 0.56)

                return PaletteSource(color: color, score: score)
            }
            .sorted { $0.score > $1.score }

        var selected: [RGBAColor] = []

        for minimumDistance in [0.28, 0.18, 0.10] {
            for candidate in candidates where selected.count < 3 {
                guard selected.allSatisfy({
                    candidate.color.perceptualDistance(to: $0) >= minimumDistance
                }) else {
                    continue
                }

                selected.append(candidate.color)
            }
        }

        return selected
    }

    static func palettes(from sourceColors: [RGBAColor]) -> [BarcodePalette] {
        guard let firstSourceColor = sourceColors.first else {
            return []
        }

        let names = ["桌布主色", "桌布副色", "桌布點綴"]
        let hueOffsets = [0.50, 0.34, 0.66]
        let fallbackSourceHueOffsets = [0.00, 0.08, 0.92]
        let backgroundMixAmounts = [0.76, 0.84, 0.90]
        let barBrightness = [0.15, 0.18, 0.13]

        return names.indices.map { index in
            let sourceColor = sourceColors.indices.contains(index)
                ? sourceColors[index]
                : fallbackColor(from: firstSourceColor, hueOffset: fallbackSourceHueOffsets[index])
            let hsb = sourceColor.hueSaturationBrightness
            let backgroundColor = scannerSafeBackground(
                from: sourceColor,
                whiteMixAmount: backgroundMixAmounts[index]
            )
            let hue = scannerSafeHue(hsb.hue + hueOffsets[index])
            let barColor = scannerSafeBarColor(
                RGBAColor(
                    hue: hue,
                    saturation: max(0.48, min(0.76, hsb.saturation + 0.24)),
                    brightness: barBrightness[index]
                ),
                backgroundColor: backgroundColor
            )

            return scannerValidatedPalette(
                name: names[index],
                barColor: barColor,
                backgroundColor: backgroundColor
            )
        }
    }

    private static func scannerSafeBackground(
        from color: RGBAColor,
        whiteMixAmount: Double
    ) -> RGBAColor {
        let targetReflectance = BarcodePalette.minimumBackgroundReflectance + 0.04
        let requiredMix: Double
        if color.red >= targetReflectance {
            requiredMix = whiteMixAmount
        } else {
            requiredMix = max(
                whiteMixAmount,
                (targetReflectance - color.red) / max(0.01, 1 - color.red)
            )
        }

        return color.mixed(
            with: RGBAColor(hex: 0xFFFFFF),
            amount: min(0.96, requiredMix)
        )
    }

    private static func scannerSafeBarColor(
        _ color: RGBAColor,
        backgroundColor: RGBAColor
    ) -> RGBAColor {
        var safeColor = color

        if safeColor.isReddish {
            safeColor = RGBAColor(hue: 210 / 360, saturation: 0.68, brightness: 0.16)
        }

        let maximumRed = max(
            0,
            min(
                backgroundColor.red / 2,
                backgroundColor.red
                    - BarcodePalette.symbolContrastStandard
                    - symbolContrastCushion
            )
        )
        if safeColor.red > maximumRed {
            guard maximumRed > 0 else {
                return RGBAColor(hex: 0x000000)
            }

            let scale = maximumRed / safeColor.red
            safeColor = RGBAColor(
                red: safeColor.red * scale,
                green: safeColor.green * scale,
                blue: safeColor.blue * scale
            )
        }

        return safeColor
    }

    private static func scannerValidatedPalette(
        name: String,
        barColor: RGBAColor,
        backgroundColor: RGBAColor
    ) -> BarcodePalette {
        let palette = BarcodePalette(
            name: name,
            barColor: barColor,
            backgroundColor: backgroundColor
        )
        guard !palette.meetsCommercialGuidance else {
            return palette
        }

        let fallbackBackground = backgroundColor.scannerReflectance
            >= BarcodePalette.minimumBackgroundReflectance
            ? backgroundColor
            : RGBAColor(hex: 0xFFFFFF)

        return BarcodePalette(
            name: name,
            barColor: RGBAColor(hex: 0x000000),
            backgroundColor: fallbackBackground
        )
    }

    private static func fallbackColor(
        from color: RGBAColor,
        hueOffset: Double
    ) -> RGBAColor {
        let hsb = color.hueSaturationBrightness

        return RGBAColor(
            hue: hsb.hue + hueOffset,
            saturation: max(0.32, min(0.76, hsb.saturation + 0.12)),
            brightness: max(0.44, hsb.brightness)
        )
    }

    private static func scannerSafeHue(_ hue: Double) -> Double {
        let normalizedHue = hue - floor(hue)
        let degrees = normalizedHue * 360

        if degrees <= 40 || degrees >= 340 {
            return 210 / 360
        }

        return normalizedHue
    }

    private static func quantizedKey(red: Double, green: Double, blue: Double) -> Int {
        let redBucket = Int(red * 255) / 32
        let greenBucket = Int(green * 255) / 32
        let blueBucket = Int(blue * 255) / 32

        return redBucket << 8 | greenBucket << 4 | blueBucket
    }

    private static func saturation(red: Double, green: Double, blue: Double) -> Double {
        let maximum = max(red, green, blue)
        let minimum = min(red, green, blue)

        guard maximum > 0 else {
            return 0
        }

        return (maximum - minimum) / maximum
    }
}

private struct ColorBucket {
    var weight = 0.0
    var red = 0.0
    var green = 0.0
    var blue = 0.0
}

private struct PaletteSource {
    let color: RGBAColor
    let score: Double
}

private extension RGBAColor {
    init(hue: Double, saturation: Double, brightness: Double) {
        let normalizedHue = hue - floor(hue)
        let chroma = brightness * saturation
        let hueSegment = normalizedHue * 6
        let secondLargestComponent = chroma * (1 - abs(hueSegment.truncatingRemainder(dividingBy: 2) - 1))
        let match = brightness - chroma

        let components: (red: Double, green: Double, blue: Double)
        switch hueSegment {
        case 0..<1:
            components = (chroma, secondLargestComponent, 0)
        case 1..<2:
            components = (secondLargestComponent, chroma, 0)
        case 2..<3:
            components = (0, chroma, secondLargestComponent)
        case 3..<4:
            components = (0, secondLargestComponent, chroma)
        case 4..<5:
            components = (secondLargestComponent, 0, chroma)
        default:
            components = (chroma, 0, secondLargestComponent)
        }

        self.init(
            red: components.red + match,
            green: components.green + match,
            blue: components.blue + match
        )
    }

    var hueSaturationBrightness: (hue: Double, saturation: Double, brightness: Double) {
        let maximum = max(red, green, blue)
        let minimum = min(red, green, blue)
        let chroma = maximum - minimum

        let hue: Double
        if chroma == 0 {
            hue = 0
        } else if maximum == red {
            hue = (((green - blue) / chroma).truncatingRemainder(dividingBy: 6)) / 6
        } else if maximum == green {
            hue = (((blue - red) / chroma) + 2) / 6
        } else {
            hue = (((red - green) / chroma) + 4) / 6
        }

        let saturation = maximum == 0 ? 0 : chroma / maximum

        return (
            hue: hue < 0 ? hue + 1 : hue,
            saturation: saturation,
            brightness: maximum
        )
    }

    func mixed(with color: RGBAColor, amount: Double) -> RGBAColor {
        let clampedAmount = max(0, min(1, amount))
        let retainedAmount = 1 - clampedAmount

        return RGBAColor(
            red: red * retainedAmount + color.red * clampedAmount,
            green: green * retainedAmount + color.green * clampedAmount,
            blue: blue * retainedAmount + color.blue * clampedAmount,
            alpha: alpha * retainedAmount + color.alpha * clampedAmount
        )
    }

    func perceptualDistance(to color: RGBAColor) -> Double {
        let redDelta = (red - color.red) * 0.30
        let greenDelta = (green - color.green) * 0.59
        let blueDelta = (blue - color.blue) * 0.11
        let hueDelta = hueDistance(to: color) * 0.40

        return sqrt(
            redDelta * redDelta
                + greenDelta * greenDelta
                + blueDelta * blueDelta
                + hueDelta * hueDelta
        )
    }

    private func hueDistance(to color: RGBAColor) -> Double {
        let hue = hueSaturationBrightness.hue
        let otherHue = color.hueSaturationBrightness.hue
        let difference = abs(hue - otherHue)

        return min(difference, 1 - difference)
    }
}
