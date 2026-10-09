import Foundation

/// The top rung. Set is refused with VoidMark until this lane holds ink.
struct Outcome: Codable, Equatable, Sendable {
    var ink: String

    var holdsInk: Bool {
        ink.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }
}
