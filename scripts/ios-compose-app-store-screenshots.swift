#!/usr/bin/env swift

import AppKit
import Foundation

private enum Artwork {
    static let panelWidth = 1_284
    static let height = 2_778
    static let panelCount = 3
    static let width = panelWidth * panelCount

    static let background = NSColor(calibratedRed: 0.992, green: 0.996, blue: 1, alpha: 1)
    static let ink = NSColor(calibratedRed: 0.035, green: 0.102, blue: 0.180, alpha: 1)
    static let muted = NSColor(calibratedRed: 0.310, green: 0.365, blue: 0.420, alpha: 1)
    static let cyan = NSColor(calibratedRed: 0, green: 0.494, blue: 0.659, alpha: 1)
    static let hairline = NSColor(calibratedRed: 0.835, green: 0.898, blue: 0.929, alpha: 1)
}

private struct Arguments {
    let mainCapture: String
    let catCapture: String
    let waveCapture: String
    let plainCapture: String
    let catArtwork: String
    let catDetailsArtwork: String
    let outputDirectory: String

    init() throws {
        let values = Array(CommandLine.arguments.dropFirst())
        var parsed: [String: String] = [:]
        var index = 0

        while index < values.count {
            let key = values[index]
            guard key.hasPrefix("--"), values.indices.contains(index + 1) else {
                throw ComposerError.invalidArguments
            }
            parsed[key] = values[index + 1]
            index += 2
        }

        guard
            let mainCapture = parsed["--main"],
            let catCapture = parsed["--cat"],
            let waveCapture = parsed["--wave"],
            let plainCapture = parsed["--plain"],
            let catArtwork = parsed["--cat-artwork"],
            let catDetailsArtwork = parsed["--cat-details-artwork"],
            let outputDirectory = parsed["--output-dir"]
        else {
            throw ComposerError.invalidArguments
        }

        self.mainCapture = mainCapture
        self.catCapture = catCapture
        self.waveCapture = waveCapture
        self.plainCapture = plainCapture
        self.catArtwork = catArtwork
        self.catDetailsArtwork = catDetailsArtwork
        self.outputDirectory = outputDirectory
    }
}

private enum ComposerError: LocalizedError {
    case invalidArguments
    case missingImage(String)
    case imageEncodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidArguments:
            "Usage: ios-compose-app-store-screenshots.swift --main <png> --cat <png> --wave <png> --plain <png> --cat-artwork <png> --cat-details-artwork <png> --output-dir <directory>"
        case let .missingImage(path):
            "Could not load image: \(path)"
        case .imageEncodingFailed:
            "Could not encode App Store screenshot PNG."
        }
    }
}

private struct Composer {
    let mainCapture: NSImage
    let catCapture: NSImage
    let waveCapture: NSImage
    let plainCapture: NSImage
    let catArtwork: NSImage
    let catDetailsArtwork: NSImage

    init(arguments: Arguments) throws {
        mainCapture = try Self.loadImage(arguments.mainCapture)
        catCapture = try Self.loadImage(arguments.catCapture)
        waveCapture = try Self.loadImage(arguments.waveCapture)
        plainCapture = try Self.loadImage(arguments.plainCapture)
        catArtwork = try Self.loadImage(arguments.catArtwork)
        catDetailsArtwork = try Self.loadImage(arguments.catDetailsArtwork)
    }

    func render(to outputDirectory: String) throws {
        guard let representation = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Artwork.width,
            pixelsHigh: Artwork.height,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: Artwork.width * 4,
            bitsPerPixel: 32
        ), let graphics = NSGraphicsContext(bitmapImageRep: representation) else {
            throw ComposerError.imageEncodingFailed
        }

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = graphics
        graphics.imageInterpolation = .high
        graphics.shouldAntialias = true

        Artwork.background.setFill()
        NSBezierPath(rect: NSRect(x: 0, y: 0, width: Artwork.width, height: Artwork.height)).fill()

        drawMessages()
        drawBarcodeRibbon()
        drawCatInRibbon()
        drawPaintDrop()
        drawWallpaperProof()
        drawDecorationProof()
        drawScannerProof()

        NSGraphicsContext.restoreGraphicsState()

        let outputURL = URL(fileURLWithPath: outputDirectory, isDirectory: true)
        try FileManager.default.createDirectory(
            at: outputURL,
            withIntermediateDirectories: true
        )

        for panel in 0..<Artwork.panelCount {
            guard let panelImage = representation.cgImage?.cropping(
                to: CGRect(
                    x: panel * Artwork.panelWidth,
                    y: 0,
                    width: Artwork.panelWidth,
                    height: Artwork.height
                )
            ) else {
                throw ComposerError.imageEncodingFailed
            }

            let panelRepresentation = NSBitmapImageRep(cgImage: panelImage)
            guard let pngData = panelRepresentation.representation(
                using: .png,
                properties: [.compressionFactor: 0.92]
            ) else {
                throw ComposerError.imageEncodingFailed
            }

            let names = [
                "colorinvo-iphone-6-5-01-wallpaper-palette.png",
                "colorinvo-iphone-6-5-02-decorations.png",
                "colorinvo-iphone-6-5-03-scanner-widget.png",
            ]
            try pngData.write(to: outputURL.appendingPathComponent(names[panel]))
        }
    }

    private func drawMessages() {
        let messages = [
            ("從桌布提取配色", "隨時出示，不打亂桌布色調"),
            ("添加額外裝飾", "提供貓貓與顏料水滴兩種樣式"),
            ("好看，也好掃", "配色遵循商業掃描規範，並提供桌面小工具"),
        ]

        for (index, message) in messages.enumerated() {
            let panelX = CGFloat(index * Artwork.panelWidth)
            drawCenteredText(
                message.0,
                x: panelX,
                top: 150,
                width: CGFloat(Artwork.panelWidth),
                font: .systemFont(ofSize: 84, weight: .bold),
                color: Artwork.ink
            )
            drawCenteredText(
                message.1,
                x: panelX + 96,
                top: 278,
                width: CGFloat(Artwork.panelWidth - 192),
                font: .systemFont(ofSize: 38, weight: .medium),
                color: Artwork.muted
            )
        }
    }

    private func drawBarcodeRibbon() {
        let bars = code39Bars(value: "/AB12345")
        let unitWidth: CGFloat = 3.1
        let sequenceWidth = CGFloat(bars.totalUnits) * unitWidth
        var sequenceOrigin: CGFloat = -sequenceWidth * 0.14

        while sequenceOrigin < CGFloat(Artwork.width) {
            for bar in bars.ranges {
                let x = sequenceOrigin + CGFloat(bar.lowerBound) * unitWidth
                let width = CGFloat(bar.count) * unitWidth
                let progress = max(0, min(1, x / CGFloat(Artwork.width)))
                let center = 750
                    + sin(progress * .pi * 3.25 - 0.45) * 92
                    + sin(progress * .pi * 1.2) * 34
                let thickness: CGFloat = 248
                let top = center - thickness / 2

                interpolatedRibbonColor(progress).setFill()
                roundedRect(
                    topRect: CGRect(x: x, y: top, width: max(2, width), height: thickness),
                    radius: min(3, width / 2)
                ).fill()
            }
            sequenceOrigin += sequenceWidth - 32
        }
    }

    private func drawCatInRibbon() {
        let frame = CGRect(x: 320, y: 590, width: 520, height: 307)
        drawTintedImage(catArtwork, color: Artwork.ink, topRect: frame)
        drawTintedImage(catDetailsArtwork, color: Artwork.background, topRect: frame)
    }

    private func drawPaintDrop() {
        let x = CGFloat(Artwork.panelWidth) * 1.52
        let startTop: CGFloat = 805
        let path = NSBezierPath()
        path.move(to: pointFromTop(x: x - 8, y: startTop))
        path.curve(
            to: pointFromTop(x: x, y: 980),
            controlPoint1: pointFromTop(x: x - 10, y: 875),
            controlPoint2: pointFromTop(x: x - 42, y: 938)
        )
        path.curve(
            to: pointFromTop(x: x + 8, y: startTop),
            controlPoint1: pointFromTop(x: x + 42, y: 938),
            controlPoint2: pointFromTop(x: x + 10, y: 875)
        )
        path.close()
        NSColor(calibratedRed: 0.47, green: 0.38, blue: 0.87, alpha: 1).setFill()
        path.fill()
    }

    private func drawWallpaperProof() {
        let panelX: CGFloat = 0
        let destination = CGRect(x: panelX + 88, y: 1_210, width: 1_108, height: 1_290)
        drawScreenshotCard(
            image: mainCapture,
            sourceFromTop: CGRect(x: 28, y: 1_700, width: 1_228, height: 900),
            destinationFromTop: CGRect(
                x: destination.minX,
                y: 1_370,
                width: destination.width,
                height: 812
            ),
            cornerRadius: 44
        )
    }

    private func drawDecorationProof() {
        let panelX = CGFloat(Artwork.panelWidth)
        drawCenteredText(
            "貓貓",
            x: panelX,
            top: 1_132,
            width: CGFloat(Artwork.panelWidth),
            font: .systemFont(ofSize: 38, weight: .semibold),
            color: Artwork.muted
        )
        drawScreenshotCard(
            image: catCapture,
            sourceFromTop: CGRect(x: 40, y: 420, width: 1_204, height: 530),
            destinationFromTop: CGRect(x: panelX + 92, y: 1_250, width: 1_100, height: 484),
            cornerRadius: 40
        )
        drawCenteredText(
            "顏料水滴",
            x: panelX,
            top: 1_812,
            width: CGFloat(Artwork.panelWidth),
            font: .systemFont(ofSize: 38, weight: .semibold),
            color: Artwork.muted
        )
        drawScreenshotCard(
            image: waveCapture,
            sourceFromTop: CGRect(x: 40, y: 420, width: 1_204, height: 530),
            destinationFromTop: CGRect(x: panelX + 92, y: 1_930, width: 1_100, height: 484),
            cornerRadius: 40
        )
    }

    private func drawScannerProof() {
        let panelX = CGFloat(Artwork.panelWidth * 2)
        drawScreenshotCard(
            image: plainCapture,
            sourceFromTop: CGRect(x: 24, y: 95, width: 1_236, height: 1_280),
            destinationFromTop: CGRect(x: panelX + 88, y: 1_210, width: 1_108, height: 1_150),
            cornerRadius: 44
        )

        let statusRect = CGRect(x: panelX + 220, y: 2_420, width: 844, height: 116)
        roundedRect(topRect: statusRect, radius: 58).with {
            NSColor.white.setFill()
            $0.fill()
            Artwork.hairline.setStroke()
            $0.lineWidth = 3
            $0.stroke()
        }
        drawCheckmark(centerFromTop: CGPoint(x: statusRect.minX + 78, y: statusRect.midY))
        drawText(
            "符合商業掃描建議",
            topRect: CGRect(
                x: statusRect.minX + 132,
                y: statusRect.minY + 27,
                width: statusRect.width - 168,
                height: 64
            ),
            font: .systemFont(ofSize: 40, weight: .semibold),
            color: Artwork.muted,
            alignment: .left
        )
    }

    private func drawScreenshotCard(
        image: NSImage,
        sourceFromTop: CGRect,
        destinationFromTop: CGRect,
        cornerRadius: CGFloat
    ) {
        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.09)
        shadow.shadowBlurRadius = 22
        shadow.shadowOffset = NSSize(width: 0, height: -10)

        NSGraphicsContext.saveGraphicsState()
        shadow.set()
        NSColor.white.setFill()
        roundedRect(topRect: destinationFromTop, radius: cornerRadius).fill()
        NSGraphicsContext.restoreGraphicsState()

        NSGraphicsContext.saveGraphicsState()
        roundedRect(topRect: destinationFromTop, radius: cornerRadius).addClip()

        let destination = rectFromTop(destinationFromTop)
        let source = NSRect(
            x: sourceFromTop.minX,
            y: image.size.height - sourceFromTop.maxY,
            width: sourceFromTop.width,
            height: sourceFromTop.height
        )
        image.draw(
            in: destination,
            from: source,
            operation: .sourceOver,
            fraction: 1,
            respectFlipped: false,
            hints: [.interpolation: NSImageInterpolation.high]
        )
        NSGraphicsContext.restoreGraphicsState()

        Artwork.hairline.setStroke()
        let outline = roundedRect(topRect: destinationFromTop, radius: cornerRadius)
        outline.lineWidth = 3
        outline.stroke()
    }

    private func drawCheckmark(centerFromTop: CGPoint) {
        Artwork.cyan.setFill()
        NSBezierPath(
            ovalIn: rectFromTop(
                CGRect(
                    x: centerFromTop.x - 30,
                    y: centerFromTop.y - 30,
                    width: 60,
                    height: 60
                )
            )
        ).fill()

        let path = NSBezierPath()
        path.move(to: pointFromTop(x: centerFromTop.x - 13, y: centerFromTop.y + 1))
        path.line(to: pointFromTop(x: centerFromTop.x - 2, y: centerFromTop.y + 13))
        path.line(to: pointFromTop(x: centerFromTop.x + 17, y: centerFromTop.y - 13))
        path.lineWidth = 6
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        NSColor.white.setStroke()
        path.stroke()
    }

    private func drawCenteredText(
        _ text: String,
        x: CGFloat,
        top: CGFloat,
        width: CGFloat,
        font: NSFont,
        color: NSColor
    ) {
        drawText(
            text,
            topRect: CGRect(x: x, y: top, width: width, height: 120),
            font: font,
            color: color,
            alignment: .center
        )
    }

    private func drawText(
        _ text: String,
        topRect: CGRect,
        font: NSFont,
        color: NSColor,
        alignment: NSTextAlignment
    ) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = alignment
        paragraph.lineBreakMode = .byTruncatingTail
        let attributed = NSAttributedString(
            string: text,
            attributes: [
                .font: font,
                .foregroundColor: color,
                .paragraphStyle: paragraph,
            ]
        )
        attributed.draw(in: rectFromTop(topRect))
    }

    private func drawTintedImage(_ image: NSImage, color: NSColor, topRect: CGRect) {
        let tintedImage = NSImage(size: image.size)
        tintedImage.lockFocus()
        image.draw(
            in: NSRect(origin: .zero, size: image.size),
            from: .zero,
            operation: .sourceOver,
            fraction: 1
        )
        color.setFill()
        NSRect(origin: .zero, size: image.size).fill(using: .sourceAtop)
        tintedImage.unlockFocus()

        NSGraphicsContext.saveGraphicsState()
        tintedImage.draw(in: rectFromTop(topRect))
        NSGraphicsContext.restoreGraphicsState()
    }

    private func roundedRect(topRect: CGRect, radius: CGFloat) -> NSBezierPath {
        NSBezierPath(roundedRect: rectFromTop(topRect), xRadius: radius, yRadius: radius)
    }

    private func rectFromTop(_ rect: CGRect) -> NSRect {
        NSRect(
            x: rect.minX,
            y: CGFloat(Artwork.height) - rect.maxY,
            width: rect.width,
            height: rect.height
        )
    }

    private func pointFromTop(x: CGFloat, y: CGFloat) -> NSPoint {
        NSPoint(x: x, y: CGFloat(Artwork.height) - y)
    }

    private func interpolatedRibbonColor(_ progress: CGFloat) -> NSColor {
        let stops: [(CGFloat, NSColor)] = [
            (0, Artwork.ink),
            (0.42, NSColor(calibratedRed: 0.36, green: 0.30, blue: 0.76, alpha: 1)),
            (0.67, NSColor(calibratedRed: 0.12, green: 0.64, blue: 0.78, alpha: 1)),
            (1, NSColor(calibratedRed: 0.02, green: 0.62, blue: 0.56, alpha: 1)),
        ]

        for pair in zip(stops, stops.dropFirst()) {
            let (start, end) = pair
            guard progress <= end.0 else {
                continue
            }
            let amount = (progress - start.0) / max(0.001, end.0 - start.0)
            return start.1.blended(withFraction: amount, of: end.1) ?? start.1
        }
        return stops.last?.1 ?? Artwork.cyan
    }

    private func code39Bars(value: String) -> (ranges: [Range<Int>], totalUnits: Int) {
        let patterns: [Character: String] = [
            "0": "nnnwwnwnn", "1": "wnnwnnnnw", "2": "nnwwnnnnw",
            "3": "wnwwnnnnn", "4": "nnnwwnnnw", "5": "wnnwwnnnn",
            "6": "nnwwwnnnn", "7": "nnnwnnwnw", "8": "wnnwnnwnn",
            "9": "nnwwnnwnn", "A": "wnnnnwnnw", "B": "nnwnnwnnw",
            "C": "wnwnnwnnn", "D": "nnnnwwnnw", "E": "wnnnwwnnn",
            "F": "nnwnwwnnn", "G": "nnnnnwwnw", "H": "wnnnnwwnn",
            "I": "nnwnnwwnn", "J": "nnnnwwwnn", "K": "wnnnnnnww",
            "L": "nnwnnnnww", "M": "wnwnnnnwn", "N": "nnnnwnnww",
            "O": "wnnnwnnwn", "P": "nnwnwnnwn", "Q": "nnnnnnwww",
            "R": "wnnnnnwwn", "S": "nnwnnnwwn", "T": "nnnnwnwwn",
            "U": "wwnnnnnnw", "V": "nwwnnnnnw", "W": "wwwnnnnnn",
            "X": "nwnnwnnnw", "Y": "wwnnwnnnn", "Z": "nwwnwnnnn",
            "-": "nwnnnnwnw", ".": "wwnnnnwnn", " ": "nwwnnnwnn",
            "$": "nwnwnwnnn", "/": "nwnwnnnwn", "+": "nwnnnwnwn",
            "%": "nnnwnwnwn", "*": "nwnnwnwnn",
        ]

        var cursor = 10
        var ranges: [Range<Int>] = []
        let characters = Array("*\(value)*")

        for (characterIndex, character) in characters.enumerated() {
            guard let pattern = patterns[character] else {
                continue
            }
            for (elementIndex, marker) in pattern.enumerated() {
                let units = marker == "w" ? 3 : 1
                if elementIndex.isMultiple(of: 2) {
                    ranges.append(cursor..<(cursor + units))
                }
                cursor += units
            }
            if characterIndex != characters.indices.last {
                cursor += 1
            }
        }
        return (ranges, cursor + 10)
    }

    private static func loadImage(_ path: String) throws -> NSImage {
        guard let image = NSImage(contentsOfFile: path) else {
            throw ComposerError.missingImage(path)
        }
        if let representation = image.representations.first {
            image.size = NSSize(
                width: representation.pixelsWide,
                height: representation.pixelsHigh
            )
        }
        return image
    }
}

private extension NSBezierPath {
    func with(_ body: (NSBezierPath) -> Void) {
        body(self)
    }
}

do {
    let arguments = try Arguments()
    let composer = try Composer(arguments: arguments)
    try composer.render(to: arguments.outputDirectory)
} catch {
    fputs("\(error.localizedDescription)\n", stderr)
    exit(1)
}
