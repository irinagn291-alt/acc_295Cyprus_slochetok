import Foundation

/// Written by Harvest when Know-how and Action both hold ink. Folds Scaled to Harvested.
struct HarvestMark: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var ladderID: UUID
    var clientID: UUID
    var dayKey: Int
}
