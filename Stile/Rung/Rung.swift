import Foundation

/// One step on the 0 through 10 scale. The bead sits on the rung Set locks.
struct Rung: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var ladderID: UUID
    var index: Int
    var holdsBead: Bool
}
