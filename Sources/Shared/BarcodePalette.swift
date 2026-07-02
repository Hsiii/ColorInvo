import Foundation
import SwiftUI
import UIKit

struct BarcodePalette: Codable, Equatable, Identifiable {
    var name: String
    var barColor: RGBAColor
    var backgroundColor: RGBAColor

    var id: String {
        name
    }

    var meetsCommercialGuidance: Bool {
        barColor.relativeLuminance <= 0.18
            && backgroundColor.relativeLuminance >= 0.72
            && contrastRatio >= 4.5
            && !barColor.isReddish
    }

    var contrastRatio: Double {
        let lighter = max(barColor.relativeLuminance, backgroundColor.relativeLuminance)
        let darker = min(barColor.relativeLuminance, backgroundColor.relativeLuminance)

        return (lighter + 0.05) / (darker + 0.05)
    }

    var standardMessage: String {
        if meetsCommercialGuidance {
            return "符合條碼配色：深色條、淺色底"
        }

        if barColor.isReddish {
            return "條碼線條請避免紅色或偏紅色"
        }

        if barColor.relativeLuminance > 0.18 {
            return "條碼線條需要更深"
        }

        if backgroundColor.relativeLuminance < 0.72 {
            return "背景需要更淺"
        }

        return "條碼與背景需要更高對比"
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
