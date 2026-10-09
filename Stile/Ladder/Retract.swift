import Foundation

/// Retract peels the last ReviewMark and its frozen SessionNote only while the successor ladder is still empty.
extension LadderDocument {
    mutating func retract(ladderID: UUID) -> FoldResult {
        guard let index = ladders.firstIndex(where: { $0.id == ladderID }) else {
            return .retractRefused
        }
        guard ladders[index].phase == .reviewed, let successorID = ladders[index].successorID else {
            return .retractRefused
        }
        guard let successor = ladders.first(where: { $0.id == successorID }), successor.isEmptySuccessor else {
            return .retractRefused
        }
        guard scaleMarks.contains(where: { $0.ladderID == successorID }) == false else {
            return .retractRefused
        }
        guard let markIndex = reviewMarks.lastIndex(where: { $0.ladderID == ladderID }) else {
            return .retractRefused
        }
        let mark = reviewMarks.remove(at: markIndex)
        sessionNotes.removeAll { $0.id == mark.noteID }
        ladders.removeAll { $0.id == successorID }
        rungs.removeAll { $0.ladderID == successorID }
        bares.removeAll { $0.ladderID == successorID }
        ladders[index].phase = .harvested
        ladders[index].successorID = nil
        selectedLadderID = ladderID
        return .retracted
    }
}
