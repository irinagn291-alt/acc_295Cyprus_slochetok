import XCTest
@testable import Stile

final class StileTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? calendar.timeZone
        return calendar
    }

    func testReviewLaunchReadsScreenArgument() {
        XCTAssertEqual(ReviewLaunch.screen(in: ["Stile", "-ReviewScreen", "today"]), "today")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Stile", "-ReviewScreen", "log"]), "log")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Stile", "-ReviewScreen", "goals"]), "goals")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Stile", "-ReviewScreen", "settings"]), "settings")
        XCTAssertNil(ReviewLaunch.screen(in: ["Stile"]))
        XCTAssertNil(ReviewLaunch.screen(in: ["Stile", "-ReviewScreen"]))
    }

    func testSectionsCountMatchesTitlesAndConfidenceStaysInRange() {
        var document = LadderDocument.empty()
        let client = Client(id: UUID(), name: "Nora Hale", deskCode: "48192037")
        document.clients = [client]
        let bare = document.openBareLadder(clientID: client.id, dayKey: 20261001)
        let ladderID = bare.ladderID
        XCTAssertEqual(document.writeOutcome("A smaller stand-up.", ladderID: ladderID), .harvestWaiting)
        guard case .scaleLocked = document.setTheScale(ladderID: ladderID, rung: 7) else {
            return XCTFail("Set should lock the scale")
        }
        _ = document.writeKnowHow("Name the blocker first.", ladderID: ladderID)
        _ = document.writeAction("Ask before the status round.", ladderID: ladderID)
        XCTAssertEqual(document.harvest(ladderID: ladderID) == .harvestWaiting, false)
        guard case .reviewFiled(let mark) = document.reviewTheLadder(ladderID: ladderID, confidence: 4) else {
            return XCTFail("Review should file")
        }
        let note = document.sessionNotes.first { $0.id == mark.noteID }
        XCTAssertEqual(note?.sections.count, SessionNote.titles.count, "SOAP/GROW/DAP: sections.count must match titles")
        XCTAssertEqual(note?.sections.map(\.title), SessionNote.titles)
        XCTAssertTrue(note?.sectionsMatchTitles == true)
        XCTAssertTrue(note?.confidenceInRange == true)
        XCTAssertEqual(mark.confidence, 4)
        let summary = document.nextSessionSummary(clientID: client.id, today: 20261003, calendar: calendar)
        XCTAssertEqual(summary?.noteID, note?.id)
        XCTAssertEqual(summary?.daysSince, 2, "days since the latest note")
    }

    func testSetEmptyOutcomeInvalidRungAndSecondSet() {
        var document = LadderDocument.empty()
        let client = Client(id: UUID(), name: "Idris Cole", deskCode: "1029384756")
        document.clients = [client]
        let bare = document.openBareLadder(clientID: client.id, dayKey: 20261003)
        let ladderID = bare.ladderID
        guard case .outcomeEmpty = document.setTheScale(ladderID: ladderID, rung: 3) else {
            return XCTFail("Empty Outcome writes VoidMark")
        }
        XCTAssertEqual(document.ladder(ladderID)?.phase, .open)
        XCTAssertEqual(document.rungRefused(ladderID), true)
        _ = document.writeOutcome("Leave with one next step.", ladderID: ladderID)
        guard case .scaleLocked(let mark) = document.setTheScale(ladderID: ladderID, rung: 5) else {
            return XCTFail("Ink lets Set lock")
        }
        XCTAssertEqual(mark.rung, 5)
        XCTAssertEqual(document.ladder(ladderID)?.phase, .scaled)
        XCTAssertEqual(document.setTheScale(ladderID: ladderID, rung: 8), .setRefused)
        XCTAssertEqual(document.scaleMarks.count, 1)
    }

    func testScaleThenHarvestRefusalsAndRetract() {
        var document = LadderDocument.empty()
        let client = Client(id: UUID(), name: "Mina Voss", deskCode: "564738291047")
        document.clients = [client]
        let bare = document.openBareLadder(clientID: client.id, dayKey: 20261002)
        let ladderID = bare.ladderID
        guard case .laneRushed = document.writeKnowHow("Too soon.", ladderID: ladderID) else {
            return XCTFail("Know-how before Scaled writes RushMark")
        }
        XCTAssertFalse(document.ladder(ladderID)?.knowHow.holdsInk == true)
        _ = document.writeOutcome("One change this hour.", ladderID: ladderID)
        guard case .reviewUnripe = document.reviewTheLadder(ladderID: ladderID, confidence: 2) else {
            return XCTFail("Review before Harvest writes UnripeMark")
        }
        _ = document.setTheScale(ladderID: ladderID, rung: 4)
        _ = document.writeKnowHow("They already name the step.", ladderID: ladderID)
        _ = document.writeAction("", ladderID: ladderID)
        XCTAssertEqual(document.harvest(ladderID: ladderID), .harvestWaiting)
        _ = document.writeAction("Write the step in their words.", ladderID: ladderID)
        guard case .harvestSeated = document.harvest(ladderID: ladderID) else {
            return XCTFail("Harvest seats both lanes")
        }
        XCTAssertEqual(document.ladder(ladderID)?.phase, .harvested)
        _ = document.writeAction("   ", ladderID: ladderID)
        guard case .reviewHollow = document.reviewTheLadder(ladderID: ladderID, confidence: 5) else {
            return XCTFail("Empty Action on Review writes HollowMark")
        }
        XCTAssertEqual(document.reviewTheLadder(ladderID: ladderID, confidence: 0), .confidenceRefused)
        _ = document.writeAction("Write the step in their words.", ladderID: ladderID)
        guard case .reviewFiled = document.reviewTheLadder(ladderID: ladderID, confidence: 5) else {
            return XCTFail("Review folds to Reviewed")
        }
        XCTAssertEqual(document.ladder(ladderID)?.phase, .reviewed)
        let successor = document.ladder(ladderID)?.successorID
        XCTAssertEqual(document.ladder(successor ?? UUID())?.phase, .open)
        XCTAssertEqual(document.retract(ladderID: ladderID), .retracted)
        XCTAssertEqual(document.ladder(ladderID)?.phase, .harvested)
        XCTAssertTrue(document.sessionNotes.isEmpty)
        guard case .reviewFiled = document.reviewTheLadder(ladderID: ladderID, confidence: 2) else {
            return XCTFail("Review can file again after Retract")
        }
        let nextID = document.ladder(ladderID)?.successorID
        _ = document.writeOutcome("Do not peel this.", ladderID: nextID ?? UUID())
        XCTAssertEqual(document.retract(ladderID: ladderID), .retractRefused)
    }

    func testFoldWalksOpenScaledHarvestedReviewed() {
        var document = LadderDocument.empty()
        let client = Client(id: UUID(), name: "Pavel Orth", deskCode: "91827364550123")
        document.clients = [client]
        let ladderID = document.openBareLadder(clientID: client.id, dayKey: 20260115).ladderID
        XCTAssertEqual(document.ladder(ladderID)?.phase, .open)
        XCTAssertFalse(document.bares.isEmpty)
        _ = document.writeOutcome("Outcome ink.", ladderID: ladderID)
        _ = document.setTheScale(ladderID: ladderID, rung: 0)
        XCTAssertEqual(document.ladder(ladderID)?.phase, .scaled)
        _ = document.writeKnowHow("Know-how ink.", ladderID: ladderID)
        _ = document.writeAction("Action ink.", ladderID: ladderID)
        _ = document.harvest(ladderID: ladderID)
        XCTAssertEqual(document.ladder(ladderID)?.phase, .harvested)
        _ = document.reviewTheLadder(ladderID: ladderID, confidence: 1)
        XCTAssertEqual(document.ladder(ladderID)?.phase, .reviewed)
        XCTAssertEqual(document.sessionNotes.count, 1)
    }

    @MainActor
    func testPersistenceRoundTripAndCorruptBackup() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let suite = "stile.tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        let store = LadderStore(defaults: defaults, directory: directory)
        await store.load()
        let client = Client(id: UUID(), name: "Nora Hale", deskCode: "48192037")
        var seeded = store.document
        seeded.clients = [client]
        let ladderID = seeded.openBareLadder(clientID: client.id, dayKey: 20261003).ladderID
        _ = seeded.writeOutcome("Outcome already inked.", ladderID: ladderID)
        store.adopt(seeded)
        await store.flush()
        await store.flush()
        let reloaded = LadderStore(defaults: defaults, directory: directory)
        await reloaded.load()
        let reloadedNames = reloaded.document.clients.map(\.name)
        let reloadedInk = reloaded.document.ladder(ladderID)?.outcome.ink
        XCTAssertEqual(reloadedNames, ["Nora Hale"])
        XCTAssertEqual(reloadedInk, "Outcome already inked.")
        let fileURL = directory.appendingPathComponent("ladder.root.json")
        try Data("not-json".utf8).write(to: fileURL, options: .atomic)
        let restored = LadderStore(defaults: defaults, directory: directory)
        await restored.load()
        let restoredPhase = restored.document.ladder(ladderID)?.phase
        let restoredStatus = restored.statusLine
        XCTAssertEqual(restoredPhase, .open)
        XCTAssertFalse(restoredStatus.isEmpty)
        await store.resetAllData()
        let cleared = store.document.isBare
        let stored = defaults.data(forKey: LadderStore.rootKey)
        XCTAssertTrue(cleared)
        XCTAssertNil(stored)
    }

    func testDemoSeedInksOutcomeAndFilesTwoNotes() {
        let today = DayKey.date(from: 20261003, calendar: calendar) ?? Date()
        let document = DemoSeed.document(today: today, calendar: calendar)
        XCTAssertEqual(document.clients.count, 4)
        XCTAssertTrue(document.clients.allSatisfy(\.deskCodeIsValid))
        XCTAssertEqual(document.sessionNotes.count, 2)
        XCTAssertTrue(document.onboardingComplete)
        let ladderID = document.selectedLadderID
        XCTAssertEqual(document.ladder(ladderID ?? UUID())?.phase, .open)
        XCTAssertTrue(document.ladder(ladderID ?? UUID())?.outcome.holdsInk == true)
    }

    func testDeskCodePadsTwelveDigits() {
        XCTAssertEqual(DeskCode.normalize("code 123456789012 extra"), "0123456789012")
        XCTAssertNil(DeskCode.normalize("1234"))
        XCTAssertTrue(DeskCode.isValid("48192037"))
    }
}

private extension LadderDocument {
    func rungRefused(_ ladderID: UUID) -> Bool {
        let high = setCopy(ladderID: ladderID, rung: 11)
        let low = setCopy(ladderID: ladderID, rung: -1)
        return high == .rungRefused && low == .rungRefused
    }

    private func setCopy(ladderID: UUID, rung: Int) -> FoldResult {
        var copy = self
        return copy.setTheScale(ladderID: ladderID, rung: rung)
    }
}
