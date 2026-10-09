import Foundation
import SwiftUI

/// Seam between the OSKAR fold and storage. Views talk to this type only.
/// The in-memory document wins. UserDefaults key stl.ladder.root and the Application Support file are projections.
@MainActor
final class LadderStore: ObservableObject {
    nonisolated static let rootKey = "stl.ladder.root"
    nonisolated static let saveDelayNanoseconds: UInt64 = 300_000_000

    @Published private(set) var document: LadderDocument
    @Published private(set) var statusLine: String

    private let defaults: UserDefaults
    private let vault: LadderVault
    private var pendingSave: Task<Void, Never>?
    private var hasLoaded = false

    init(defaults: UserDefaults = .standard, directory: URL) {
        self.defaults = defaults
        self.vault = LadderVault(directory: directory)
        self.document = .empty()
        self.statusLine = ""
    }

    func load() async {
        let snapshot = await vault.load(defaultsData: defaults.data(forKey: Self.rootKey))
        applyLoad(snapshot)
        hasLoaded = true
    }

    func setTheScale(rung: Int) -> FoldResult {
        guard let ladderID = document.selectedLadderID else { return .setRefused }
        return mutate { $0.setTheScale(ladderID: ladderID, rung: rung) }
    }

    func writeOutcome(_ ink: String) -> FoldResult {
        guard let ladderID = document.selectedLadderID else { return .laneLocked }
        return mutate { $0.writeOutcome(ink, ladderID: ladderID) }
    }

    func writeKnowHow(_ ink: String) -> FoldResult {
        guard let ladderID = document.selectedLadderID else { return .laneLocked }
        return mutate { $0.writeKnowHow(ink, ladderID: ladderID) }
    }

    func writeAction(_ ink: String) -> FoldResult {
        guard let ladderID = document.selectedLadderID else { return .laneLocked }
        return mutate { $0.writeAction(ink, ladderID: ladderID) }
    }

    func harvest() -> FoldResult {
        guard let ladderID = document.selectedLadderID else { return .harvestWaiting }
        return mutate { $0.harvest(ladderID: ladderID) }
    }

    func reviewTheLadder(confidence: Int) -> FoldResult {
        guard let ladderID = document.selectedLadderID else {
            return .confidenceRefused
        }
        return mutate { $0.reviewTheLadder(ladderID: ladderID, confidence: confidence) }
    }

    func retract() async -> FoldResult {
        let target = document.ladders.first {
            $0.phase == .reviewed && $0.successorID == document.selectedLadderID
        }?.id ?? document.selectedLadderID
        guard let ladderID = target else { return .retractRefused }
        var next = document
        let result = next.retract(ladderID: ladderID)
        document = next
        if result == .retracted {
            await flush()
        }
        return result
    }

    func noteScenePhase(_ phase: ScenePhase) async {
        if phase == .inactive || phase == .background {
            await flush()
        }
    }

    func scheduleSave() {
        pendingSave?.cancel()
        pendingSave = Task { [weak self] in
            try? await Task.sleep(nanoseconds: Self.saveDelayNanoseconds)
            guard Task.isCancelled == false else { return }
            await self?.flush()
        }
    }

    func flush() async {
        pendingSave?.cancel()
        pendingSave = nil
        guard let data = document.encoded() else {
            statusLine = "The ladder could not be saved. Stay here and try the mark again."
            return
        }
        do {
            try await vault.write(data)
        } catch {
            statusLine = "The ladder is still on screen. Saving to disk failed. Try again before leaving."
            return
        }
        defaults.set(data, forKey: Self.rootKey)
    }

    func exportJSON() -> Data? {
        document.encoded()
    }

    func resetAllData() async {
        pendingSave?.cancel()
        pendingSave = nil
        document = .empty()
        statusLine = "Ladder cleared. Add a client to start again."
        defaults.removeObject(forKey: Self.rootKey)
        defaults.removeObject(forKey: DemoSeed.key)
        do {
            try await vault.removeAll()
        } catch {
            statusLine = "The ladder on screen is clear. A file could not be removed. Reset again from Settings."
        }
    }

    /// Simulator only. Writes four clients, inks today's Outcome, and files two earlier notes.
    func installDemoIfNeeded(today: Date = Date(), calendar: Calendar = .current) async {
        #if targetEnvironment(simulator)
        guard defaults.bool(forKey: DemoSeed.key) == false else { return }
        document = DemoSeed.document(today: today, calendar: calendar)
        defaults.set(true, forKey: DemoSeed.key)
        await flush()
        #else
        _ = today
        _ = calendar
        #endif
    }

    func adopt(_ next: LadderDocument) {
        document = next
    }

    private func apply(_ result: FoldResult) -> FoldResult {
        switch result {
        case .scaleLocked, .harvestSeated, .reviewFiled, .outcomeEmpty, .laneRushed, .reviewHollow, .reviewUnripe, .bareOpened, .harvestWaiting:
            scheduleSave()
        case .setRefused, .rungRefused, .laneLocked, .confidenceRefused, .retracted, .retractRefused:
            break
        }
        return result
    }

    private func mutate(_ change: (inout LadderDocument) -> FoldResult) -> FoldResult {
        var next = document
        let result = change(&next)
        document = next
        return apply(result)
    }

    private func applyLoad(_ snapshot: LadderLoad) {
        switch snapshot {
        case .file(let loaded), .defaults(let loaded):
            document = loaded
            statusLine = ""
        case .backup(let loaded):
            document = loaded
            statusLine = "The latest save could not be read. The previous ladder is back. You can keep working."
        case .keptMemory:
            if hasLoaded {
                statusLine = "The saved ladder could not be read. The ladder on screen is unchanged. Reset from Settings if you need a blank start."
            }
        case .fresh:
            document = .empty()
            statusLine = ""
        case .empty:
            if hasLoaded && document.isBare == false {
                statusLine = "The saved ladder could not be read. The ladder on screen is unchanged. Reset from Settings if you need a blank start."
            } else {
                document = .empty()
                statusLine = "The saved ladder could not be read. Start again with a blank ladder. Reset from Settings if a file is still in the way."
            }
        }
    }
}

enum DemoSeed {
    static let key = "stl.demo.v1"

    static func document(today: Date, calendar: Calendar = .current) -> LadderDocument {
        var document = LadderDocument.empty()
        let names = ["Nora Hale", "Idris Cole", "Mina Voss", "Pavel Orth"]
        let codes = ["48192037", "1029384756", "564738291047", "9182736455012"]
        var clients: [Client] = []
        for pair in zip(names, codes) {
            let client = Client(id: UUID(), name: pair.0, deskCode: pair.1)
            clients.append(client)
            document.clients.append(client)
        }
        let lead = clients[0]
        let todayKey = DayKey.make(from: today, calendar: calendar)
        filePastVisit(
            &document,
            clientID: lead.id,
            dayKey: shift(todayKey, days: -2, calendar: calendar),
            outcome: "Want the morning stand-up to stay under twenty minutes.",
            knowHow: "The team already names one blocker on the board.",
            action: "Ask for the blocker before the status round.",
            confidence: 4
        )
        filePastVisit(
            &document,
            clientID: lead.id,
            dayKey: shift(todayKey, days: -1, calendar: calendar),
            outcome: "Leave the room with one next step the client chose.",
            knowHow: "They describe the step more clearly when they write it.",
            action: "Hand them the pen for the action line.",
            confidence: 3
        )
        _ = document.openBareLadder(clientID: lead.id, dayKey: todayKey)
        if let ladderID = document.selectedLadderID {
            _ = document.writeOutcome(
                "Name one change you want from this hour. Keep it small enough to try before you leave.",
                ladderID: ladderID
            )
        }
        document.selectedClientID = lead.id
        document.onboardingComplete = true
        document.rosterGatePassed = true
        return document
    }

    private static func shift(_ dayKey: Int, days: Int, calendar: Calendar) -> Int {
        guard let date = DayKey.date(from: dayKey, calendar: calendar),
              let moved = calendar.date(byAdding: .day, value: days, to: date) else {
            return dayKey
        }
        return DayKey.make(from: moved, calendar: calendar)
    }

    private static func filePastVisit(
        _ document: inout LadderDocument,
        clientID: UUID,
        dayKey: Int,
        outcome: String,
        knowHow: String,
        action: String,
        confidence: Int
    ) {
        _ = document.openBareLadder(clientID: clientID, dayKey: dayKey)
        guard let ladderID = document.selectedLadderID else { return }
        _ = document.writeOutcome(outcome, ladderID: ladderID)
        _ = document.setTheScale(ladderID: ladderID, rung: 6)
        _ = document.writeKnowHow(knowHow, ladderID: ladderID)
        _ = document.writeAction(action, ladderID: ladderID)
        _ = document.harvest(ladderID: ladderID)
        _ = document.reviewTheLadder(ladderID: ladderID, confidence: confidence)
    }
}

private enum LadderLoad: Sendable {
    case file(LadderDocument)
    case backup(LadderDocument)
    case defaults(LadderDocument)
    case keptMemory
    case fresh
    case empty
}

/// File IO off the main actor. Writes are atomic and the previous good file is kept as a backup.
private actor LadderVault {
    private let folder: URL
    private let fileURL: URL
    private let backupURL: URL
    private let cacheURL: URL

    init(directory: URL) {
        folder = directory
        fileURL = directory.appendingPathComponent("ladder.root.json")
        backupURL = directory.appendingPathComponent("ladder.root.json.backup")
        cacheURL = directory.appendingPathComponent("Caches", isDirectory: true)
    }

    func load(defaultsData: Data?) -> LadderLoad {
        let fileData = read(fileURL)
        if let fileData, let document = LadderDocument.decode(fileData) {
            return .file(document)
        }
        if let data = read(backupURL), let document = LadderDocument.decode(data) {
            return .backup(document)
        }
        if let defaultsData, let document = LadderDocument.decode(defaultsData) {
            return .defaults(document)
        }
        if fileData != nil || read(backupURL) != nil || defaultsData != nil {
            return .empty
        }
        return .fresh
    }

    func write(_ data: Data) throws {
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try prepareCache()
        if let existing = read(fileURL), LadderDocument.decode(existing) != nil {
            if FileManager.default.fileExists(atPath: backupURL.path) {
                try FileManager.default.removeItem(at: backupURL)
            }
            try FileManager.default.copyItem(at: fileURL, to: backupURL)
        }
        let temporary = folder.appendingPathComponent("ladder-\(UUID().uuidString).tmp")
        try data.write(to: temporary, options: .atomic)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            _ = try FileManager.default.replaceItemAt(fileURL, withItemAt: temporary)
        } else {
            try FileManager.default.moveItem(at: temporary, to: fileURL)
        }
    }

    func removeAll() throws {
        for url in [fileURL, backupURL] where FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }

    private func read(_ url: URL) -> Data? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        do {
            return try Data(contentsOf: url)
        } catch {
            return nil
        }
    }

    private func prepareCache() throws {
        try FileManager.default.createDirectory(at: cacheURL, withIntermediateDirectories: true)
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        var url = cacheURL
        try url.setResourceValues(values)
    }
}
