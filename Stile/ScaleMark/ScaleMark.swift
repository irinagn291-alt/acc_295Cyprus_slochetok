import Foundation

/// Written by Set. Folds Open to Scaled and records the chosen 0 through 10 rung.
struct ScaleMark: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var ladderID: UUID
    var clientID: UUID
    var dayKey: Int
    var rung: Int
}
