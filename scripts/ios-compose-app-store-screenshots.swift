#!/usr/bin/env swift

import AppKit
import Foundation

private enum Artwork {
    static let panelWidth = 1_284
    static let height = 2_778
    static let panelCount = 3
    static let width = panelWidth * panelCount
    static let padding: CGFloat = 96

    static let background = NSColor(calibratedRed: 0.992, green: 0.996, blue: 1, alpha: 1)
    static let ink = NSColor(calibratedRed: 0.035, green: 0.102, blue: 0.180, alpha: 1)
    static let muted = NSColor(calibratedRed: 0.310, green: 0.365, blue: 0.420, alpha: 1)
}

private struct Arguments {
    let catCapture: String
    let waveCapture: String
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
            let catCapture = parsed["--cat"],
            let waveCapture = parsed["--wave"],
            let outputDirectory = parsed["--output-dir"]
        else {
            throw ComposerError.invalidArguments
        }

        self.catCapture = catCapture
        self.waveCapture = waveCapture
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
            "Usage: ios-compose-app-store-screenshots.swift --cat <png> --wave <png> --output-dir <directory>"
        case let .missingImage(path):
            "Could not load image: \(path)"
        case .imageEncodingFailed:
            "Could not encode App Store screenshot PNG."
        }
    }
}

private struct Composer {
    let catCapture: NSImage
    let waveCapture: NSImage

    init(arguments: Arguments) throws {
        catCapture = try Self.loadImage(arguments.catCapture)
        waveCapture = try Self.loadImage(arguments.waveCapture)
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

        let widgetWidth: CGFloat = 2_100
        let widgetHeight: CGFloat = 990
        drawWidget(
            image: catCapture,
            destinationFromTop: CGRect(
                x: Artwork.padding,
                y: 560,
                width: widgetWidth,
                height: widgetHeight
            )
        )
        drawWidget(
            image: waveCapture,
            destinationFromTop: CGRect(
                x: CGFloat(Artwork.width) - Artwork.padding - widgetWidth,
                y: CGFloat(Artwork.height) - Artwork.padding - widgetHeight,
                width: widgetWidth,
                height: widgetHeight
            )
        )

        NSGraphicsContext.restoreGraphicsState()

        let outputURL = URL(fileURLWithPath: outputDirectory, isDirectory: true)
        try FileManager.default.createDirectory(
            at: outputURL,
            withIntermediateDirectories: true
        )

        let names = [
            "colorinvo-iphone-6-5-01-wallpaper-palette.png",
            "colorinvo-iphone-6-5-02-decorations.png",
            "colorinvo-iphone-6-5-03-scanner-widget.png",
        ]

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
            try pngData.write(to: outputURL.appendingPathComponent(names[panel]))
        }
    }

    private func drawMessages() {
        let messages = [
            ("從桌布提取配色", "載具融入桌布色調，出示不突兀"),
            ("貓貓或顏料水滴", "兩種裝飾，都保留完整條碼"),
            ("好看，也好掃", "配色遵循商業掃描規範，桌面直接出示"),
        ]

        for (index, message) in messages.enumerated() {
            let panelX = CGFloat(index * Artwork.panelWidth) + Artwork.padding
            let textWidth = CGFloat(Artwork.panelWidth) - Artwork.padding * 2
            drawText(
                message.0,
                topRect: CGRect(x: panelX, y: Artwork.padding, width: textWidth, height: 104),
                font: .systemFont(ofSize: 72, weight: .bold),
                color: Artwork.ink
            )
            drawText(
                message.1,
                topRect: CGRect(x: panelX, y: 220, width: textWidth, height: 64),
                font: .systemFont(ofSize: 36, weight: .medium),
                color: Artwork.muted
            )
        }
    }

    private func drawWidget(image: NSImage, destinationFromTop: CGRect) {
        let cornerRadius = destinationFromTop.height * 24 / 155
        let sourceFromTop = CGRect(x: 120, y: 490, width: 1_044, height: 492)
        let shape = roundedRect(topRect: destinationFromTop, radius: cornerRadius)

        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.13)
        shadow.shadowBlurRadius = 40
        shadow.shadowOffset = NSSize(width: 0, height: -18)

        NSGraphicsContext.saveGraphicsState()
        shadow.set()
        NSColor.white.setFill()
        shape.fill()
        NSGraphicsContext.restoreGraphicsState()

        NSGraphicsContext.saveGraphicsState()
        shape.addClip()
        image.draw(
            in: rectFromTop(destinationFromTop),
            from: NSRect(
                x: sourceFromTop.minX,
                y: image.size.height - sourceFromTop.maxY,
                width: sourceFromTop.width,
                height: sourceFromTop.height
            ),
            operation: .sourceOver,
            fraction: 1,
            respectFlipped: false,
            hints: [.interpolation: NSImageInterpolation.high]
        )
        NSGraphicsContext.restoreGraphicsState()
    }

    private func drawText(
        _ text: String,
        topRect: CGRect,
        font: NSFont,
        color: NSColor
    ) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
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

do {
    let arguments = try Arguments()
    let composer = try Composer(arguments: arguments)
    try composer.render(to: arguments.outputDirectory)
} catch {
    fputs("\(error.localizedDescription)\n", stderr)
    exit(1)
}
