import SwiftUI

struct Code39BarcodeView: View {
    @Environment(\.displayScale) private var displayScale

    let value: String
    var barColor: Color = .black
    var backgroundColor: Color = .white

    var body: some View {
        Canvas { context, size in
            let elements = Code39Encoder.elements(for: value)
            guard !elements.isEmpty else {
                return
            }

            let totalUnits = elements.reduce(0) { $0 + $1.units }
            let totalPixels = max(1, floor(size.width * displayScale))
            let pixelsPerUnit = totalPixels / CGFloat(totalUnits)
            var unitOffset = 0

            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(backgroundColor))

            for element in elements {
                let startPixel = (CGFloat(unitOffset) * pixelsPerUnit).rounded()
                unitOffset += element.units
                let endPixel = (CGFloat(unitOffset) * pixelsPerUnit).rounded()

                if element.isBar {
                    let rect = CGRect(
                        x: startPixel / displayScale,
                        y: 0,
                        width: max(1 / displayScale, (endPixel - startPixel) / displayScale),
                        height: size.height
                    )
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
    var showsValue = false
    var barcodeHeight: CGFloat = 96
    var horizontalPadding: CGFloat = 18
    var verticalPadding: CGFloat = 16
    var fillsAvailableSpace = false
    var dominantColors: [RGBAColor] = []

    var body: some View {
        VStack(spacing: showsValue ? 6 : 0) {
            Code39BarcodeView(
                value: value,
                barColor: palette.barColor.color,
                backgroundColor: palette.backgroundColor.color
            )
            .frame(height: barcodeHeight)

            if showsValue {
                HStack(spacing: 8) {
                    Text(value)
                        .font(.system(.subheadline, design: .monospaced, weight: .semibold))
                        .foregroundStyle(palette.barColor.color)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Spacer(minLength: 8)

                    WallpaperDominantColorDots(colors: dominantColors)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .frame(
            maxWidth: .infinity,
            maxHeight: fillsAvailableSpace ? .infinity : nil
        )
        .background(palette.backgroundColor.color)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

private struct WallpaperDominantColorDots: View {
    let colors: [RGBAColor]

    private var displayColors: [RGBAColor] {
        Array(colors.prefix(3))
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(displayColors.enumerated()), id: \.offset) { _, color in
                Circle()
                    .fill(color.color)
                    .frame(width: 12, height: 12)
                    .overlay {
                        Circle()
                            .stroke(.black.opacity(0.16), lineWidth: 1)
                    }
            }
        }
        .accessibilityHidden(displayColors.isEmpty)
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
}
