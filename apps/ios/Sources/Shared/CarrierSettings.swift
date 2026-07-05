import Foundation

struct CarrierSettings: Codable, Equatable, Sendable {
    var carrierCode: String
    var palette: BarcodePalette
    var wallpaperDominantColors: [RGBAColor]
    var waveColor: RGBAColor?
    var showsWave: Bool
    var showsBarcodeValue: Bool
    var showsCat: Bool

    static let empty = CarrierSettings(
        carrierCode: "",
        palette: .classic
    )

    static let showcase = CarrierSettings(
        carrierCode: "/AB12345",
        palette: .showcase,
        wallpaperDominantColors: BarcodePalette.showcaseSourceColors,
        showsWave: false,
        showsBarcodeValue: false,
        showsCat: true
    )

    init(
        carrierCode: String,
        palette: BarcodePalette = .classic,
        wallpaperDominantColors: [RGBAColor] = [],
        waveColor: RGBAColor? = nil,
        showsWave: Bool = true,
        showsBarcodeValue: Bool = true,
        showsCat: Bool = false
    ) {
        self.carrierCode = carrierCode
        self.palette = palette
        self.wallpaperDominantColors = Array(wallpaperDominantColors.prefix(3))
        self.waveColor = waveColor
        self.showsWave = showsWave
        self.showsBarcodeValue = showsBarcodeValue
        self.showsCat = showsCat
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        carrierCode = try container.decode(String.self, forKey: .carrierCode)
        palette = try container.decodeIfPresent(BarcodePalette.self, forKey: .palette)
            ?? .classic
        wallpaperDominantColors = try container
            .decodeIfPresent([RGBAColor].self, forKey: .wallpaperDominantColors)
            ?? []
        waveColor = try container.decodeIfPresent(RGBAColor.self, forKey: .waveColor)
        showsWave = try container.decodeIfPresent(Bool.self, forKey: .showsWave)
            ?? true
        showsBarcodeValue = try container.decodeIfPresent(Bool.self, forKey: .showsBarcodeValue)
            ?? true
        showsCat = try container.decodeIfPresent(Bool.self, forKey: .showsCat)
            ?? false
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
