import Foundation

/// Set with an empty Outcome. The ladder stays Open.
struct VoidMark: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var ladderID: UUID
    var clientID: UUID
    var dayKey: Int
}
