import Foundation

/// Presentation seam. Screens call these methods. The fold itself stays on LadderDocument.
@MainActor
extension LadderStore {
    func finishOnboarding() {
        var next = document
        next.onboardingComplete = true
        adopt(next)
        scheduleSave()
    }

    func reopenOnboarding() {
        var next = document
        next.onboardingComplete = false
        adopt(next)
        scheduleSave()
    }

    func passRosterGate() {
        var next = document
        next.rosterGatePassed = true
        adopt(next)
        scheduleSave()
    }

    func showClient(_ id: UUID, today: Date = Date()) {
        var next = document
        next.selectedClientID = id
        let day = DayKey.make(from: today)
        if let current = next.ladders.last(where: { $0.clientID == id && $0.dayKey == day }) {
            next.selectedLadderID = current.id
        } else if let open = next.ladders.last(where: { $0.clientID == id && $0.phase != .reviewed }) {
            next.selectedLadderID = open.id
        } else {
            _ = next.openBareLadder(clientID: id, dayKey: day)
        }
        adopt(next)
        scheduleSave()
    }

    func addClient(name: String, deskCode: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let code = DeskCode.normalize(deskCode) ?? (DeskCode.isValid(deskCode) ? deskCode : nil)
        guard trimmed.isEmpty == false, let code else { return false }
        var next = document
        let client = Client(id: UUID(), name: trimmed, deskCode: code)
        next.clients.append(client)
        adopt(next)
        showClient(client.id)
        return true
    }

    func openDeskCode(_ raw: String) -> Bool {
        guard let code = DeskCode.normalize(raw) else { return false }
        guard let client = document.clients.first(where: { $0.deskCode == code }) else { return false }
        showClient(client.id)
        return true
    }
}

enum LadderPaths {
    static func supportDirectory() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return base.appendingPathComponent("Slochetok", isDirectory: true)
    }
}
