import Foundation

/// Review after Harvest while Action is empty.
struct HollowMark: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var ladderID: UUID
    var clientID: UUID
    var dayKey: Int
}
