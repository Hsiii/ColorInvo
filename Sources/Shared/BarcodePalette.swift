import Foundation
import SwiftUI
import UIKit

struct BarcodePalette: Codable, Equatable, Identifiable {
    var name: String
    var barColor: RGBAColor
    var backgroundColor: RGBAColor

    static let symbolContrastStandard = 0.70
    static let minimumBackgroundReflectance = 0.70

    var id: String {
        name
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
        String(
            format: "SC %.0f%% / 標準 %.0f%%",
            scannerSymbolContrast * 100,
            Self.symbolContrastStandard * 100
        )
    }

    var reflectanceSummary: String {
        String(
            format: "Rmin %.0f%% <= Rmax/2 %.0f%%，背景 %.0f%%",
            barScannerReflectance * 100,
            backgroundScannerReflectance * 50,
            backgroundScannerReflectance * 100
        )
    }

    var standardMessage: String {
        if meetsCommercialGuidance {
            return "符合掃描標準"
        }

        if barColor.isReddish {
            return "線條勿用紅系"
        }

        if backgroundScannerReflectance < Self.minimumBackgroundReflectance {
            return "背景與靜區要更亮"
        }

        if barScannerReflectance > backgroundScannerReflectance / 2 {
            return "線條在紅光下要更深"
        }

        return "掃描對比不足"
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

    static let presets: [BarcodePalette] = [
        .classic,
        BarcodePalette(
            name: "櫻粉海軍",
            barColor: RGBAColor(hex: 0x102A56),
            backgroundColor: RGBAColor(hex: 0xFADCE8)
        ),
        BarcodePalette(
            name: "霧紫墨藍",
            barColor: RGBAColor(hex: 0x16213E),
            backgroundColor: RGBAColor(hex: 0xF0ECFF)
        ),
        BarcodePalette(
            name: "薄荷石墨",
            barColor: RGBAColor(hex: 0x1E2E29),
            backgroundColor: RGBAColor(hex: 0xDFF7EC)
        ),
        BarcodePalette(
            name: "奶油深藍",
            barColor: RGBAColor(hex: 0x172554),
            backgroundColor: RGBAColor(hex: 0xFFF4C2)
        ),
        BarcodePalette(
            name: "冰藍松綠",
            barColor: RGBAColor(hex: 0x0F3D2E),
            backgroundColor: RGBAColor(hex: 0xE1F1FF)
        ),
    ]
}

struct RGBAColor: Codable, Equatable {
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

    private func linearized(_ channel: Double) -> Double {
        if channel <= 0.03928 {
            return channel / 12.92
        }

        return pow((channel + 0.055) / 1.055, 2.4)
    }
}
