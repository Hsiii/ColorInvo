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

    static func validationMessage(for rawValue: String) -> String {
        let normalizedValue = normalize(rawValue)

        if normalizedValue.isEmpty {
            return "請輸入手機條碼載具號碼"
        }

        if normalizedValue.count != 8 {
            return "格式需為 8 碼：/ 加上 7 碼英數或 + - ."
        }

        if !normalizedValue.hasPrefix("/") {
            return "第一碼必須是 /"
        }

        return "僅可使用大寫英文、數字，以及 + - ."
    }
}
