import Foundation

/// OSKAR fold. A ladder is Open, Scaled, Harvested, or Reviewed over one client's rungs for one day key.
/// Set, Harvest, and Review are the only folds. Refusal marks leave the phase where it was.
enum LadderPhase: String, Codable, Equatable, Sendable {
    case open
    case scaled
    case harvested
    case reviewed
}

/// Empty ladder record written when a blank visit is opened.
struct Bare: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var ladderID: UUID
    var clientID: UUID
    var dayKey: Int
}

/// One visit. The in-memory board is the source of truth; the file is a projection.
struct Ladder: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var clientID: UUID
    var dayKey: Int
    var phase: LadderPhase
    var outcome: Outcome
    var knowHow: KnowHow
    var action: Action
    var successorID: UUID?

    var isEmptySuccessor: Bool {
        phase == .open && outcome.holdsInk == false && knowHow.holdsInk == false && action.holdsInk == false
    }
}

enum DayKey {
    static func make(from date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.year, .month, .day], from: start)
        let year = parts.year ?? 0
        let month = parts.month ?? 0
        let day = parts.day ?? 0
        return year * 10000 + month * 100 + day
    }

    static func date(from dayKey: Int, calendar: Calendar = .current) -> Date? {
        var parts = DateComponents()
        parts.year = dayKey / 10000
        parts.month = (dayKey / 100) % 100
        parts.day = dayKey % 100
        guard let raw = calendar.date(from: parts) else { return nil }
        return calendar.startOfDay(for: raw)
    }

    static func daysSince(_ earlier: Int, until later: Int, calendar: Calendar = .current) -> Int? {
        guard let start = date(from: earlier, calendar: calendar),
              let end = date(from: later, calendar: calendar) else {
            return nil
        }
        return calendar.dateComponents([.day], from: start, to: end).day
    }
}

enum FoldResult: Equatable, Sendable {
    case scaleLocked(ScaleMark)
    case outcomeEmpty(VoidMark)
    case setRefused
    case rungRefused
    case harvestSeated(HarvestMark)
    case harvestWaiting
    case laneRushed(RushMark)
    case laneLocked
    case reviewFiled(ReviewMark)
    case reviewHollow(HollowMark)
    case reviewUnripe(UnripeMark)
    case confidenceRefused
    case retracted
    case retractRefused
    case bareOpened(Bare)
}

/// Codable root, schemaVersion 1. Holds clients, rungs, notes, and every mark.
struct LadderDocument: Codable, Equatable, Sendable {
    var schemaVersion: Int
    var clients: [Client]
    var ladders: [Ladder]
    var rungs: [Rung]
    var sessionNotes: [SessionNote]
    var scaleMarks: [ScaleMark]
    var harvestMarks: [HarvestMark]
    var reviewMarks: [ReviewMark]
    var voidMarks: [VoidMark]
    var rushMarks: [RushMark]
    var hollowMarks: [HollowMark]
    var unripeMarks: [UnripeMark]
    var bares: [Bare]
    var selectedClientID: UUID?
    var selectedLadderID: UUID?
    var onboardingComplete: Bool
    var rosterGatePassed: Bool

    static let currentSchema = 1

    static func empty() -> LadderDocument {
        LadderDocument(
            schemaVersion: currentSchema,
            clients: [],
            ladders: [],
            rungs: [],
            sessionNotes: [],
            scaleMarks: [],
            harvestMarks: [],
            reviewMarks: [],
            voidMarks: [],
            rushMarks: [],
            hollowMarks: [],
            unripeMarks: [],
            bares: [],
            selectedClientID: nil,
            selectedLadderID: nil,
            onboardingComplete: false,
            rosterGatePassed: false
        )
    }

    var isBare: Bool {
        clients.isEmpty && ladders.isEmpty && sessionNotes.isEmpty
    }

    enum CodingKeys: String, CodingKey {
        case schemaVersion
        case clients
        case ladders
        case rungs
        case sessionNotes
        case scaleMarks
        case harvestMarks
        case reviewMarks
        case voidMarks
        case rushMarks
        case hollowMarks
        case unripeMarks
        case bares
        case selectedClientID
        case selectedLadderID
        case onboardingComplete
        case rosterGatePassed
    }

    init(
        schemaVersion: Int,
        clients: [Client],
        ladders: [Ladder],
        rungs: [Rung],
        sessionNotes: [SessionNote],
        scaleMarks: [ScaleMark],
        harvestMarks: [HarvestMark],
        reviewMarks: [ReviewMark],
        voidMarks: [VoidMark],
        rushMarks: [RushMark],
        hollowMarks: [HollowMark],
        unripeMarks: [UnripeMark],
        bares: [Bare],
        selectedClientID: UUID?,
        selectedLadderID: UUID?,
        onboardingComplete: Bool,
        rosterGatePassed: Bool
    ) {
        self.schemaVersion = schemaVersion
        self.clients = clients
        self.ladders = ladders
        self.rungs = rungs
        self.sessionNotes = sessionNotes
        self.scaleMarks = scaleMarks
        self.harvestMarks = harvestMarks
        self.reviewMarks = reviewMarks
        self.voidMarks = voidMarks
        self.rushMarks = rushMarks
        self.hollowMarks = hollowMarks
        self.unripeMarks = unripeMarks
        self.bares = bares
        self.selectedClientID = selectedClientID
        self.selectedLadderID = selectedLadderID
        self.onboardingComplete = onboardingComplete
        self.rosterGatePassed = rosterGatePassed
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let version = try container.decode(Int.self, forKey: .schemaVersion)
        switch version {
        case 1:
            self.init(
                schemaVersion: version,
                clients: try container.decode([Client].self, forKey: .clients),
                ladders: try container.decode([Ladder].self, forKey: .ladders),
                rungs: try container.decode([Rung].self, forKey: .rungs),
                sessionNotes: try container.decode([SessionNote].self, forKey: .sessionNotes),
                scaleMarks: try container.decode([ScaleMark].self, forKey: .scaleMarks),
                harvestMarks: try container.decode([HarvestMark].self, forKey: .harvestMarks),
                reviewMarks: try container.decode([ReviewMark].self, forKey: .reviewMarks),
                voidMarks: try container.decode([VoidMark].self, forKey: .voidMarks),
                rushMarks: try container.decode([RushMark].self, forKey: .rushMarks),
                hollowMarks: try container.decode([HollowMark].self, forKey: .hollowMarks),
                unripeMarks: try container.decode([UnripeMark].self, forKey: .unripeMarks),
                bares: try container.decode([Bare].self, forKey: .bares),
                selectedClientID: try container.decodeIfPresent(UUID.self, forKey: .selectedClientID),
                selectedLadderID: try container.decodeIfPresent(UUID.self, forKey: .selectedLadderID),
                onboardingComplete: try container.decode(Bool.self, forKey: .onboardingComplete),
                rosterGatePassed: try container.decode(Bool.self, forKey: .rosterGatePassed)
            )
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion,
                in: container,
                debugDescription: "Unsupported ladder schema \(version)."
            )
        }
    }

    static func decode(_ data: Data) -> LadderDocument? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        do {
            return try decoder.decode(LadderDocument.self, from: data)
        } catch {
            return nil
        }
    }

    func encoded() -> Data? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .useDefaultKeys
        encoder.outputFormatting = [.sortedKeys]
        do {
            return try encoder.encode(self)
        } catch {
            return nil
        }
    }

    func ladder(_ id: UUID) -> Ladder? {
        ladders.first { $0.id == id }
    }

    mutating func openBareLadder(clientID: UUID, dayKey: Int) -> Bare {
        let ladderID = UUID()
        let ladder = Ladder(
            id: ladderID,
            clientID: clientID,
            dayKey: dayKey,
            phase: .open,
            outcome: Outcome(ink: ""),
            knowHow: KnowHow(ink: ""),
            action: Action(ink: ""),
            successorID: nil
        )
        ladders.append(ladder)
        for index in 0...10 {
            rungs.append(Rung(id: UUID(), ladderID: ladderID, index: index, holdsBead: false))
        }
        let bare = Bare(id: UUID(), ladderID: ladderID, clientID: clientID, dayKey: dayKey)
        bares.append(bare)
        selectedClientID = clientID
        selectedLadderID = ladderID
        return bare
    }

    mutating func setTheScale(ladderID: UUID, rung: Int) -> FoldResult {
        guard let index = ladders.firstIndex(where: { $0.id == ladderID }) else {
            return .setRefused
        }
        if (0...10).contains(rung) == false {
            return .rungRefused
        }
        if ladders[index].phase != .open {
            return .setRefused
        }
        if ladders[index].outcome.holdsInk == false {
            let mark = VoidMark(
                id: UUID(),
                ladderID: ladderID,
                clientID: ladders[index].clientID,
                dayKey: ladders[index].dayKey
            )
            voidMarks.append(mark)
            return .outcomeEmpty(mark)
        }
        let mark = ScaleMark(
            id: UUID(),
            ladderID: ladderID,
            clientID: ladders[index].clientID,
            dayKey: ladders[index].dayKey,
            rung: rung
        )
        scaleMarks.append(mark)
        ladders[index].phase = .scaled
        for rungIndex in rungs.indices where rungs[rungIndex].ladderID == ladderID {
            rungs[rungIndex].holdsBead = rungs[rungIndex].index == rung
        }
        return .scaleLocked(mark)
    }

    mutating func writeKnowHow(_ ink: String, ladderID: UUID) -> FoldResult {
        writeLane(ink, ladderID: ladderID, lane: "KnowHow", apply: { ladder, text in
            ladder.knowHow.ink = text
        })
    }

    mutating func writeAction(_ ink: String, ladderID: UUID) -> FoldResult {
        writeLane(ink, ladderID: ladderID, lane: "Action", apply: { ladder, text in
            ladder.action.ink = text
        })
    }

    mutating func writeOutcome(_ ink: String, ladderID: UUID) -> FoldResult {
        guard let index = ladders.firstIndex(where: { $0.id == ladderID }) else {
            return .laneLocked
        }
        if ladders[index].phase != .open {
            return .laneLocked
        }
        ladders[index].outcome.ink = ink
        return .harvestWaiting
    }

    private mutating func writeLane(
        _ ink: String,
        ladderID: UUID,
        lane: String,
        apply: (inout Ladder, String) -> Void
    ) -> FoldResult {
        guard let index = ladders.firstIndex(where: { $0.id == ladderID }) else {
            return .laneLocked
        }
        switch ladders[index].phase {
        case .open:
            let mark = RushMark(
                id: UUID(),
                ladderID: ladderID,
                clientID: ladders[index].clientID,
                dayKey: ladders[index].dayKey,
                lane: lane
            )
            rushMarks.append(mark)
            return .laneRushed(mark)
        case .scaled, .harvested:
            apply(&ladders[index], ink)
            return .harvestWaiting
        case .reviewed:
            return .laneLocked
        }
    }

    mutating func harvest(ladderID: UUID) -> FoldResult {
        guard let index = ladders.firstIndex(where: { $0.id == ladderID }) else {
            return .harvestWaiting
        }
        guard ladders[index].phase == .scaled else {
            return .harvestWaiting
        }
        guard ladders[index].knowHow.holdsInk && ladders[index].action.holdsInk else {
            return .harvestWaiting
        }
        let mark = HarvestMark(
            id: UUID(),
            ladderID: ladderID,
            clientID: ladders[index].clientID,
            dayKey: ladders[index].dayKey
        )
        harvestMarks.append(mark)
        ladders[index].phase = .harvested
        return .harvestSeated(mark)
    }

    mutating func reviewTheLadder(ladderID: UUID, confidence: Int) -> FoldResult {
        guard (1...5).contains(confidence) else {
            return .confidenceRefused
        }
        guard let index = ladders.firstIndex(where: { $0.id == ladderID }) else {
            return .reviewUnripe(UnripeMark(id: UUID(), ladderID: ladderID, clientID: UUID(), dayKey: 0))
        }
        let visit = ladders[index]
        let harvested = harvestMarks.contains { $0.ladderID == ladderID }
        if visit.phase != .harvested || harvested == false {
            let mark = UnripeMark(id: UUID(), ladderID: ladderID, clientID: visit.clientID, dayKey: visit.dayKey)
            unripeMarks.append(mark)
            return .reviewUnripe(mark)
        }
        if visit.action.holdsInk == false {
            let mark = HollowMark(id: UUID(), ladderID: ladderID, clientID: visit.clientID, dayKey: visit.dayKey)
            hollowMarks.append(mark)
            return .reviewHollow(mark)
        }
        let note = SessionNote(
            id: UUID(),
            ladderID: ladderID,
            clientID: visit.clientID,
            dayKey: visit.dayKey,
            confidence: confidence,
            sections: [
                NoteSection(id: UUID(), title: "Outcome", ink: visit.outcome.ink),
                NoteSection(id: UUID(), title: "KnowHow", ink: visit.knowHow.ink),
                NoteSection(id: UUID(), title: "Action", ink: visit.action.ink),
                NoteSection(id: UUID(), title: "Review", ink: "Confidence filed.")
            ]
        )
        sessionNotes.append(note)
        let mark = ReviewMark(
            id: UUID(),
            ladderID: ladderID,
            clientID: visit.clientID,
            dayKey: visit.dayKey,
            confidence: confidence,
            noteID: note.id
        )
        reviewMarks.append(mark)
        ladders[index].phase = .reviewed
        let bare = openBareLadder(clientID: visit.clientID, dayKey: visit.dayKey)
        if let successor = ladders.firstIndex(where: { $0.id == ladderID }) {
            ladders[successor].successorID = bare.ladderID
        }
        return .reviewFiled(mark)
    }

    /// Latest SessionNote for the client, plus days from its day key to `today`.
    func nextSessionSummary(clientID: UUID, today: Int, calendar: Calendar = .current) -> NextSessionSummary? {
        guard let note = sessionNotes.last(where: { $0.clientID == clientID }) else {
            return nil
        }
        let days = DayKey.daysSince(note.dayKey, until: today, calendar: calendar) ?? 0
        return NextSessionSummary(
            noteID: note.id,
            dayKey: note.dayKey,
            daysSince: days,
            headline: "Latest note, \(days) days since."
        )
    }
}
