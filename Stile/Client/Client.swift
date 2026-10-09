import Foundation

/// A person on the roster. Face ID gates the sheet; the desk code is how a cover QR finds this client.
struct Client: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var name: String
    /// 8 to 14 digits. A 12-digit scan is stored with one leading zero.
    var deskCode: String

    var deskCodeIsValid: Bool {
        DeskCode.isValid(deskCode)
    }
}

enum DeskCode {
    static func isValid(_ code: String) -> Bool {
        (8...14).contains(code.count) && code.allSatisfy(\.isNumber)
    }

    /// Pulls a digit run and pads a 12-digit code with a leading zero.
    static func normalize(_ raw: String) -> String? {
        let digits = raw.filter(\.isNumber)
        guard digits.isEmpty == false else { return nil }
        let padded = digits.count == 12 ? "0" + digits : digits
        guard isValid(padded) else { return nil }
        return padded
    }
}
