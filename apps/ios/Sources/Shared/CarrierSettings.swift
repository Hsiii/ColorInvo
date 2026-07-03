import Foundation

struct CarrierSettings: Codable, Equatable, Sendable {
    var carrierCode: String
    var palette: BarcodePalette
    var wallpaperDominantColors: [RGBAColor]
    var showsWave: Bool
    var showsBarcodeValue: Bool

    static let empty = CarrierSettings(
        carrierCode: "",
        palette: .classic
    )

    static let showcase = CarrierSettings(
        carrierCode: "/AB12345",
        palette: .showcase,
        wallpaperDominantColors: BarcodePalette.showcaseSourceColors
    )

    init(
        carrierCode: String,
        palette: BarcodePalette = .classic,
        wallpaperDominantColors: [RGBAColor] = [],
        showsWave: Bool = true,
        showsBarcodeValue: Bool = true
    ) {
        self.carrierCode = carrierCode
        self.palette = palette
        self.wallpaperDominantColors = Array(wallpaperDominantColors.prefix(3))
        self.showsWave = showsWave
        self.showsBarcodeValue = showsBarcodeValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        carrierCode = try container.decode(String.self, forKey: .carrierCode)
        palette = try container.decodeIfPresent(BarcodePalette.self, forKey: .palette)
            ?? .classic
        wallpaperDominantColors = try container
            .decodeIfPresent([RGBAColor].self, forKey: .wallpaperDominantColors)
            ?? []
        showsWave = try container.decodeIfPresent(Bool.self, forKey: .showsWave)
            ?? true
        showsBarcodeValue = try container.decodeIfPresent(Bool.self, forKey: .showsBarcodeValue)
            ?? true
    }
}

enum CarrierStore {
    private static let settingsKey = "carrier-settings"

    static func load() -> CarrierSettings {
        guard
            let data = defaults.data(forKey: settingsKey),
            let settings = try? JSONDecoder().decode(CarrierSettings.self, from: data)
        else {
            return .empty
        }

        return settings
    }

    static func save(_ settings: CarrierSettings) {
        guard let data = try? JSONEncoder().encode(settings) else {
            return
        }

        defaults.set(data, forKey: settingsKey)
    }

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: AppGroup.identifier) ?? .standard
    }
}
