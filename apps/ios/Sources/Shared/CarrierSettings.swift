import Foundation

enum CarrierDecoration: String, CaseIterable, Codable, Equatable, Sendable {
    case none
    case wave
    case cat

    var showsWave: Bool {
        self == .wave
    }

    var showsCat: Bool {
        self == .cat
    }
}

struct CarrierSettings: Codable, Equatable, Sendable {
    var carrierCode: String
    var palette: BarcodePalette
    var wallpaperBasePalette: BarcodePalette?
    var wallpaperDominantColors: [RGBAColor]
    var waveColor: RGBAColor?
    var decoration: CarrierDecoration
    var showsBarcodeValue: Bool

    static let empty = CarrierSettings(
        carrierCode: "",
        palette: .classic
    )

    static let showcase = CarrierSettings(
        carrierCode: "/AB12345",
        palette: .showcase,
        wallpaperBasePalette: .showcase,
        wallpaperDominantColors: BarcodePalette.showcaseSourceColors,
        decoration: .cat,
        showsBarcodeValue: false,
    )

    init(
        carrierCode: String,
        palette: BarcodePalette = .classic,
        wallpaperBasePalette: BarcodePalette? = nil,
        wallpaperDominantColors: [RGBAColor] = [],
        waveColor: RGBAColor? = nil,
        decoration: CarrierDecoration = .wave,
        showsBarcodeValue: Bool = true
    ) {
        self.carrierCode = carrierCode
        self.palette = palette
        self.wallpaperBasePalette = wallpaperBasePalette
        self.wallpaperDominantColors = Array(wallpaperDominantColors.prefix(3))
        self.waveColor = waveColor
        self.decoration = decoration
        self.showsBarcodeValue = showsBarcodeValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StoredCodingKeys.self)

        carrierCode = try container.decode(String.self, forKey: .carrierCode)
        palette = try container.decodeIfPresent(BarcodePalette.self, forKey: .palette)
            ?? .classic
        wallpaperBasePalette = try container.decodeIfPresent(
            BarcodePalette.self,
            forKey: .wallpaperBasePalette
        )
        wallpaperDominantColors = try container
            .decodeIfPresent([RGBAColor].self, forKey: .wallpaperDominantColors)
            ?? []
        waveColor = try container.decodeIfPresent(RGBAColor.self, forKey: .waveColor)
        if let savedDecoration = try container.decodeIfPresent(
            CarrierDecoration.self,
            forKey: .decoration
        ) {
            decoration = savedDecoration
        } else if try container.decodeIfPresent(Bool.self, forKey: .showsCat) == true {
            decoration = .cat
        } else if try container.decodeIfPresent(Bool.self, forKey: .showsWave) == false {
            decoration = .none
        } else {
            decoration = .wave
        }
        showsBarcodeValue = try container.decodeIfPresent(Bool.self, forKey: .showsBarcodeValue)
            ?? true
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StoredCodingKeys.self)

        try container.encode(carrierCode, forKey: .carrierCode)
        try container.encode(palette, forKey: .palette)
        try container.encodeIfPresent(wallpaperBasePalette, forKey: .wallpaperBasePalette)
        try container.encode(wallpaperDominantColors, forKey: .wallpaperDominantColors)
        try container.encodeIfPresent(waveColor, forKey: .waveColor)
        try container.encode(decoration, forKey: .decoration)
        try container.encode(showsBarcodeValue, forKey: .showsBarcodeValue)
    }

    private enum StoredCodingKeys: String, CodingKey {
        case carrierCode
        case decoration
        case palette
        case showsBarcodeValue
        case showsCat
        case showsWave
        case wallpaperBasePalette
        case wallpaperDominantColors
        case waveColor
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
