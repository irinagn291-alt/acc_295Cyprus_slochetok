import Foundation

/// The action lane. Harvest needs this ink together with Know-how. Empty action on Review writes HollowMark.
struct Action: Codable, Equatable, Sendable {
    var ink: String

    var holdsInk: Bool {
        ink.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }
}
