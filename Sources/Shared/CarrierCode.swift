import Foundation

struct CarrierCode: Equatable {
    let value: String

    init?(_ rawValue: String) {
        let normalizedValue = CarrierCode.normalize(rawValue)

        guard CarrierCode.isValid(normalizedValue) else {
            return nil
        }

        value = normalizedValue
    }

    static func normalize(_ rawValue: String) -> String {
        rawValue
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
    }

    static func isValid(_ value: String) -> Bool {
        value.range(
            of: #"^/[0-9A-Z+\-.]{7}$"#,
            options: .regularExpression
        ) != nil
    }

}
