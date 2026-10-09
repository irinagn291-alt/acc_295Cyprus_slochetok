import Foundation

/// Know-how stays dim until the ladder is Scaled. Ink before that writes RushMark.
struct KnowHow: Codable, Equatable, Sendable {
    var ink: String

    var holdsInk: Bool {
        ink.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }
}
