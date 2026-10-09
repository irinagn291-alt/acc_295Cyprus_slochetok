import Foundation

/// Written by Review. Freezes the SessionNote and folds Harvested to Reviewed.
struct ReviewMark: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var ladderID: UUID
    var clientID: UUID
    var dayKey: Int
    var confidence: Int
    var noteID: UUID
}
