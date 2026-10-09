import Foundation

/// Know-how or Action edited before Scaled. The lane stays dim and the ink is not kept.
struct RushMark: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var ladderID: UUID
    var clientID: UUID
    var dayKey: Int
    var lane: String
}
