import Foundation

/// Frozen on Review. Section count matches the titled lanes Outcome, KnowHow, Action, and Review.
struct NoteSection: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var title: String
    var ink: String
}

struct SessionNote: Codable, Equatable, Sendable, Identifiable {
    static let titles = ["Outcome", "KnowHow", "Action", "Review"]

    var id: UUID
    var ladderID: UUID
    var clientID: UUID
    var dayKey: Int
    /// Confidence stamp, 1 through 5. Not a mood score stored twice.
    var confidence: Int
    var sections: [NoteSection]

    var sectionsMatchTitles: Bool {
        sections.map(\.title) == Self.titles && sections.count == Self.titles.count
    }

    var confidenceInRange: Bool {
        (1...5).contains(confidence)
    }
}

/// Latest filed note plus the count of days since its day key. The day count is computed, never stored.
struct NextSessionSummary: Equatable, Sendable {
    var noteID: UUID
    var dayKey: Int
    var daysSince: Int
    var headline: String
}
