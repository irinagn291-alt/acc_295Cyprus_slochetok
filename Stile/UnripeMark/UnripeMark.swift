import Foundation

/// Review before a HarvestMark exists.
struct UnripeMark: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var ladderID: UUID
    var clientID: UUID
    var dayKey: Int
}
