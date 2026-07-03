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
        Group {
            if showsValue {
                decoratedPanel
            } else {
                plainPanel
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var plainPanel: some View {
        Code39BarcodeView(
            value: value,
            barColor: palette.barColor.color,
            backgroundColor: palette.backgroundColor.color
        )
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

            Code39BarcodeView(
                value: value,
                barColor: palette.barColor.color,
                backgroundColor: palette.backgroundColor.color
            )
            .frame(height: fillsAvailableSpace ? nil : barcodeHeight)
            .padding(.horizontal, horizontalPadding)
            .frame(
                maxWidth: .infinity,
                maxHeight: fillsAvailableSpace ? .infinity : nil,
                alignment: .top
            )

            CarrierBarcodeWaveShape()
                .fill(waveColor)
                .frame(height: waveHeight)
                .frame(maxHeight: .infinity, alignment: .bottom)

            CarrierBarcodeValueOverlay(
                value: value,
                palette: palette,
                horizontalPadding: horizontalPadding
            )
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: fillsAvailableSpace ? .infinity : nil
        )
        .background(palette.backgroundColor.color)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var waveHeight: CGFloat {
        barcodeHeight >= 120 ? 76 : 60
    }

    private var waveColor: Color {
        dominantColors.first?.color ?? Color(red: 0 / 255, green: 102 / 255, blue: 255 / 255)
    }
}

struct CarrierWidgetContentView: View {
    let carrierCode: String
    let palette: BarcodePalette
    let dominantColors: [RGBAColor]

    var body: some View {
        ZStack {
            palette.backgroundColor.color

            if CarrierCode.isValid(carrierCode) {
                CarrierBarcodePanel(
                    value: carrierCode,
                    palette: palette,
                    showsValue: true,
                    barcodeHeight: 132,
                    horizontalPadding: 0,
                    verticalPadding: 8,
                    fillsAvailableSpace: true,
                    dominantColors: dominantColors
                )
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "barcode.viewfinder")
                        .font(.title2)
                    Text("開啟 App 儲存載具")
                        .font(.headline)
                }
                .foregroundStyle(.secondary)
            }
        }
    }
}

private struct CarrierBarcodeValueOverlay: View {
    let value: String
    let palette: BarcodePalette
    let horizontalPadding: CGFloat

    var body: some View {
        Text(value)
            .font(.system(.subheadline, design: .monospaced, weight: .bold))
            .fontWidth(.condensed)
            .foregroundStyle(palette.backgroundColor.color)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .padding(.horizontal, 12)
            .frame(height: 28)
            .background {
                Capsule(style: .continuous)
                    .fill(palette.barColor.color)
            }
            .padding(.leading, horizontalPadding + 12)
            .padding(.trailing, max(12, horizontalPadding + 12))
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
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
