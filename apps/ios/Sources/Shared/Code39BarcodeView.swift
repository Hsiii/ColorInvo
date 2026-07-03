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
        .frame(height: barcodeHeight)
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
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
            .frame(height: barcodeHeight)
            .padding(.horizontal, horizontalPadding)
            .padding(.top, verticalPadding)
            .frame(
                maxWidth: .infinity,
                maxHeight: fillsAvailableSpace ? .infinity : nil,
                alignment: .top
            )

            CarrierBarcodeWaveStack(colors: waveColors)
                .frame(height: waveHeight)
                .frame(maxHeight: .infinity, alignment: .bottom)

            CarrierBarcodeValueOverlay(
                value: value,
                palette: palette,
                horizontalPadding: horizontalPadding,
                dominantColors: dominantColors
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

    private var waveColors: [Color] {
        let sourceColors = Array(dominantColors.prefix(3))
        let fallbackColors = [
            RGBAColor(hex: 0x0066FF),
            palette.barColor,
            palette.backgroundColor,
        ]
        let colors = sourceColors.isEmpty ? fallbackColors : sourceColors

        return colors.map(\.color)
    }
}

private struct CarrierBarcodeValueOverlay: View {
    let value: String
    let palette: BarcodePalette
    let horizontalPadding: CGFloat
    let dominantColors: [RGBAColor]

    var body: some View {
        GeometryReader { proxy in
            let barcodeWidth = max(1, proxy.size.width - horizontalPadding * 2)
            let leadingInset = horizontalPadding
                + Code39Encoder.visibleBarcodeInset(for: value, width: barcodeWidth)

            HStack(alignment: .bottom, spacing: 12) {
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

                Spacer(minLength: 8)

                WallpaperDropletCluster(colors: dominantColors)
            }
            .padding(.leading, leadingInset)
            .padding(.trailing, max(12, horizontalPadding + 12))
            .padding(.bottom, 8)
            .frame(
                width: proxy.size.width,
                height: proxy.size.height,
                alignment: .bottomLeading
            )
        }
    }
}

private struct WallpaperDropletCluster: View {
    let colors: [RGBAColor]

    private var displayColors: [RGBAColor] {
        Array(colors.prefix(3))
    }

    var body: some View {
        ZStack {
            ForEach(Array(displayColors.enumerated()), id: \.offset) { index, color in
                Circle()
                    .fill(color.color)
                    .overlay {
                        Circle()
                            .strokeBorder(.white.opacity(0.64), lineWidth: 1)
                    }
                    .frame(width: dropletSize(for: index), height: dropletSize(for: index))
                    .offset(offset(for: index))
            }
        }
        .frame(width: 52, height: 40)
        .accessibilityHidden(true)
        .opacity(displayColors.isEmpty ? 0 : 1)
    }

    private func dropletSize(for index: Int) -> CGFloat {
        [20, 16, 12][index]
    }

    private func offset(for index: Int) -> CGSize {
        [
            CGSize(width: -12, height: 4),
            CGSize(width: 8, height: -8),
            CGSize(width: 20, height: 8),
        ][index]
    }
}

private struct CarrierBarcodeWaveStack: View {
    let colors: [Color]

    var body: some View {
        ZStack(alignment: .bottom) {
            CarrierBarcodeWaveShape(variant: .secondary)
                .fill(color(at: 1).opacity(0.64))
                .offset(y: -8)

            CarrierBarcodeWaveShape(variant: .primary)
                .fill(color(at: 0))

            CarrierBarcodeWaveShape(variant: .secondary)
                .fill(color(at: 2).opacity(0.32))
                .offset(y: 16)
        }
    }

    private func color(at index: Int) -> Color {
        guard colors.indices.contains(index) else {
            return Color(red: 0 / 255, green: 102 / 255, blue: 255 / 255)
        }

        return colors[index]
    }
}

private struct CarrierBarcodeWaveShape: Shape {
    enum Variant {
        case primary
        case secondary
    }

    let variant: Variant

    func path(in rect: CGRect) -> Path {
        switch variant {
        case .primary:
            primaryPath(in: rect)
        case .secondary:
            secondaryPath(in: rect)
        }
    }

    private func primaryPath(in rect: CGRect) -> Path {
        // Path coordinates are normalized from the downloaded Haikei wave SVG reference.
        let baseY: CGFloat = 326
        let spanY: CGFloat = 275

        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(
                x: rect.minX + rect.width * x / 900,
                y: rect.minY + rect.height * (y - baseY) / spanY
            )
        }

        var path = Path()
        path.move(to: point(0, 408))
        path.addLine(to: point(21.5, 390.3))
        path.addCurve(
            to: point(128.8, 352.2),
            control1: point(43, 372.7),
            control2: point(86, 337.3)
        )
        path.addCurve(
            to: point(257.2, 450.5),
            control1: point(171.7, 367),
            control2: point(214.3, 432)
        )
        path.addCurve(
            to: point(385.8, 416.5),
            control1: point(300, 469),
            control2: point(343, 441)
        )
        path.addCurve(
            to: point(514.2, 391),
            control1: point(428.7, 392),
            control2: point(471.3, 371)
        )
        path.addCurve(
            to: point(642.8, 473.5),
            control1: point(557, 411),
            control2: point(600, 472)
        )
        path.addCurve(
            to: point(771.2, 382.5),
            control1: point(685.7, 475),
            control2: point(728.3, 417)
        )
        path.addCurve(
            to: point(878.5, 331.5),
            control1: point(814, 348),
            control2: point(857, 337)
        )
        path.addLine(to: point(900, 326))
        path.addLine(to: point(900, 601))
        path.addLine(to: point(0, 601))
        path.closeSubpath()
        return path
    }

    private func secondaryPath(in rect: CGRect) -> Path {
        let baseY: CGFloat = 355
        let spanY: CGFloat = 246

        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(
                x: rect.minX + rect.width * x / 900,
                y: rect.minY + rect.height * (y - baseY) / spanY
            )
        }

        var path = Path()
        path.move(to: point(0, 376))
        path.addLine(to: point(18.8, 378.3))
        path.addCurve(
            to: point(112.8, 402.5),
            control1: point(37.7, 380.7),
            control2: point(75.3, 385.3)
        )
        path.addCurve(
            to: point(225.2, 475.2),
            control1: point(150.3, 419.7),
            control2: point(187.7, 449.3)
        )
        path.addCurve(
            to: point(337.8, 515.2),
            control1: point(262.7, 501),
            control2: point(300.3, 523)
        )
        path.addCurve(
            to: point(450.2, 434.7),
            control1: point(375.3, 507.3),
            control2: point(412.7, 469.7)
        )
        path.addCurve(
            to: point(562.8, 355.5),
            control1: point(487.7, 399.7),
            control2: point(525.3, 367.3)
        )
        path.addCurve(
            to: point(675.2, 387.2),
            control1: point(600.3, 343.7),
            control2: point(637.7, 352.3)
        )
        path.addCurve(
            to: point(787.8, 495.3),
            control1: point(712.7, 422),
            control2: point(750.3, 483)
        )
        path.addCurve(
            to: point(881.3, 453.2),
            control1: point(825.3, 507.7),
            control2: point(862.7, 471.3)
        )
        path.addLine(to: point(900, 435))
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
