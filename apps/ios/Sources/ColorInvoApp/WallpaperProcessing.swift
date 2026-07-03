import ImageIO
import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct WallpaperImageAnalysis: Sendable {
    let previewData: Data
    let sourceColors: [RGBAColor]
    let palettes: [BarcodePalette]
}

enum WallpaperImageAnalyzer {
    static func analyze(_ data: Data) -> WallpaperImageAnalysis? {
        guard
            let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
            let previewImage = downsampledImage(from: imageSource),
            let previewData = jpegData(from: previewImage)
        else {
            return nil
        }

        let sourceColors = WallpaperPaletteGenerator.representativeColors(from: previewImage)
        let palettes = WallpaperPaletteGenerator.palettes(from: sourceColors)
        guard !palettes.isEmpty else {
            return nil
        }

        return WallpaperImageAnalysis(
            previewData: previewData,
            sourceColors: sourceColors,
            palettes: palettes
        )
    }

    private static func downsampledImage(from imageSource: CGImageSource) -> CGImage? {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: 900,
        ]

        return CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary)
    }

    private static func jpegData(from image: CGImage) -> Data? {
        let data = NSMutableData()
        guard
            let destination = CGImageDestinationCreateWithData(
                data,
                UTType.jpeg.identifier as CFString,
                1,
                nil
            )
        else {
            return nil
        }

        let options: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: 0.76,
        ]
        CGImageDestinationAddImage(destination, image, options as CFDictionary)
        guard CGImageDestinationFinalize(destination) else {
            return nil
        }

        return data as Data
    }
}

enum WallpaperPreviewStore {
    private static let fileName = "wallpaper-preview.jpg"
    private static let maximumPixelLength: CGFloat = 900

    static func load() -> UIImage? {
        guard
            let fileURL,
            let data = try? Data(contentsOf: fileURL)
        else {
            return nil
        }

        return UIImage(data: data)
    }

    static func save(_ image: UIImage) -> UIImage? {
        guard let previewImage = previewImage(from: image) else {
            return nil
        }

        if
            let fileURL,
            let data = previewImage.jpegData(compressionQuality: 0.76)
        {
            try? data.write(to: fileURL, options: .atomic)
        }

        return previewImage
    }

    static func savePreviewData(_ data: Data) -> UIImage? {
        guard let previewImage = UIImage(data: data) else {
            return nil
        }

        if let fileURL {
            try? data.write(to: fileURL, options: .atomic)
        }

        return previewImage
    }

    static func showcaseImage() -> UIImage {
        let size = CGSize(width: 900, height: 1600)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true

        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            UIColor(red: 232 / 255, green: 248 / 255, blue: 252 / 255, alpha: 1).setFill()
            context.fill(CGRect(origin: .zero, size: size))

            UIColor(red: 89 / 255, green: 186 / 255, blue: 201 / 255, alpha: 1).setFill()
            diagonalBand(
                from: CGPoint(x: -120, y: 240),
                to: CGPoint(x: size.width + 160, y: 40),
                thickness: 260
            ).fill()

            UIColor(red: 255 / 255, green: 184 / 255, blue: 118 / 255, alpha: 1).setFill()
            diagonalBand(
                from: CGPoint(x: -180, y: 980),
                to: CGPoint(x: size.width + 180, y: 620),
                thickness: 320
            ).fill()

            UIColor(red: 57 / 255, green: 103 / 255, blue: 145 / 255, alpha: 1).setFill()
            diagonalBand(
                from: CGPoint(x: -120, y: 1500),
                to: CGPoint(x: size.width + 120, y: 1160),
                thickness: 220
            ).fill()
        }
    }

    private static var fileURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: AppGroup.identifier)?
            .appendingPathComponent(fileName)
    }

    private static func previewImage(from image: UIImage) -> UIImage? {
        let sourceSize = image.size
        guard sourceSize.width > 0, sourceSize.height > 0 else {
            return nil
        }

        let scale = min(
            1,
            maximumPixelLength / max(sourceSize.width, sourceSize.height)
        )
        let targetSize = CGSize(
            width: max(1, floor(sourceSize.width * scale)),
            height: max(1, floor(sourceSize.height * scale))
        )
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true

        return UIGraphicsImageRenderer(size: targetSize, format: format).image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: targetSize))
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    private static func diagonalBand(
        from startPoint: CGPoint,
        to endPoint: CGPoint,
        thickness: CGFloat
    ) -> UIBezierPath {
        let deltaX = endPoint.x - startPoint.x
        let deltaY = endPoint.y - startPoint.y
        let length = max(1, hypot(deltaX, deltaY))
        let offsetX = -deltaY / length * thickness / 2
        let offsetY = deltaX / length * thickness / 2
        let path = UIBezierPath()

        path.move(to: CGPoint(x: startPoint.x + offsetX, y: startPoint.y + offsetY))
        path.addLine(to: CGPoint(x: endPoint.x + offsetX, y: endPoint.y + offsetY))
        path.addLine(to: CGPoint(x: endPoint.x - offsetX, y: endPoint.y - offsetY))
        path.addLine(to: CGPoint(x: startPoint.x - offsetX, y: startPoint.y - offsetY))
        path.close()

        return path
    }
}

enum ColorInvoRuntime {
    static var showcaseDataEnabled: Bool {
        ProcessInfo.processInfo.environment["COLORINVO_SHOWCASE_DATA"] == "1"
            || ProcessInfo.processInfo.arguments.contains("--showcase-data")
    }
}
