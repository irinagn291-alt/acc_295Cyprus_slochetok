import SwiftUI
import UIKit

private enum LaneFocus: Hashable {
    case outcome
    case know
    case action
}

/// Home is the OSKAR ladder. Set, Harvest, and Review fuse on this surface.
struct LadderView: View {
    @EnvironmentObject private var store: LadderStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding var cover: LadderCover?
    @State private var bead = 6
    @State private var outcomeDraft = ""
    @State private var knowDraft = ""
    @State private var actionDraft = ""
    @State private var confidence = 3
    @State private var banner = ""
    @State private var snap = 0
    @State private var busy = false
    @State private var confirmRetract = false
    @FocusState private var focus: LaneFocus?
    @ScaledMetric(relativeTo: .largeTitle) private var display: CGFloat = 28
    @ScaledMetric(relativeTo: .body) private var bodySize: CGFloat = 17
    @ScaledMetric(relativeTo: .caption) private var caption: CGFloat = 13

    private var ladder: Ladder? {
        guard let id = store.document.selectedLadderID else { return nil }
        return store.document.ladder(id)
    }

    private var client: Client? {
        store.document.clients.first { $0.id == store.document.selectedClientID }
    }

    var body: some View {
        GeometryReader { proxy in
            let hero = min(max(proxy.size.height * 0.36, StileSpace.steps(40)), StileSpace.steps(72))
            VStack(alignment: .leading, spacing: 0) {
                creamBand
                if let ladder {
                    visit(ladder, hero: hero)
                } else if store.statusLine.isEmpty == false {
                    emptyBody
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
        }
        .background(DesignTokens.bg.ignoresSafeArea())
        .onAppear { syncDrafts() }
        .onChange(of: store.document.selectedLadderID) { _, _ in syncDrafts() }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focus = nil }
            }
        }
        .confirmationDialog(
            "Retract this review?",
            isPresented: $confirmRetract,
            titleVisibility: .visible
        ) {
            Button("Retract", role: .destructive) {
                Task { await peel() }
            }
            Button("Keep it", role: .cancel) {}
        } message: {
            Text("The filed note comes off and this visit returns to harvested.")
        }
    }

    private var creamBand: some View {
        VStack(alignment: .leading, spacing: StileSpace.steps(2)) {
            Text(client?.name ?? "Today")
                .font(StileFont.display(display))
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
            Text(jobLine)
                .font(StileFont.caption(caption))
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture { focus = nil }
            HStack(spacing: StileSpace.steps(2)) {
                bandButton("Clients", system: "person.2") { cover = .clients }
                bandButton("Progress", system: "chart.bar") { cover = .progress }
                bandButton("Settings", system: "gearshape") { cover = .settings }
                bandButton("Scan", system: "qrcode.viewfinder") { cover = .scan }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(StileSpace.steps(4))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignTokens.surface)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(DesignTokens.accent)
                .frame(height: StileSpace.steps(2))
        }
        .stileShadow()
    }

    private var jobLine: String {
        guard let ladder else { return "Open the roster, then tap Set." }
        switch ladder.phase {
        case .open:
            return "Open. Drag the bead, then tap Set."
        case .scaled:
            return "Scaled. Know-how and the next lane can take ink."
        case .harvested:
            return "Harvested. Tap Review and stamp confidence."
        case .reviewed:
            return "Reviewed. The next visit is open."
        }
    }

    private func bandButton(_ title: String, system: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: system)
                .frame(minWidth: StileSpace.steps(11), minHeight: StileSpace.steps(11))
                .contentShape(Rectangle())
        }
        .buttonStyle(MarkButtonStyle(role: .quiet, loading: false, compact: true))
        .accessibilityLabel(title)
    }

    private func visit(_ ladder: Ladder, hero: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: StileSpace.steps(3)) {
            SetScale(
                bead: $bead,
                locked: ladder.phase != .open,
                snap: snap,
                allowsMotion: reduceMotion == false,
                display: display
            )
            .frame(height: hero)
            .padding(.horizontal, StileSpace.steps(4))
            .padding(.top, StileSpace.steps(3))
            ScrollView {
                VStack(alignment: .leading, spacing: StileSpace.steps(4)) {
                    if store.statusLine.isEmpty == false {
                        statusBanner(store.statusLine, retry: true)
                    }
                    if banner.isEmpty == false {
                        statusBanner(banner, retry: false)
                    }
                    outcomeLane(ladder)
                    HarvestLanes(
                        knowDraft: $knowDraft,
                        actionDraft: $actionDraft,
                        dim: ladder.phase == .open,
                        bodySize: bodySize,
                        caption: caption,
                        focus: $focus,
                        onKnow: { text in
                            guard text != ladder.knowHow.ink else { return }
                            let result = store.writeKnowHow(text)
                            if case .laneRushed = result {
                                knowDraft = ""
                            }
                            show(result, quietWhenWaiting: true)
                        },
                        onAction: { text in
                            guard text != ladder.action.ink else { return }
                            let result = store.writeAction(text)
                            if case .laneRushed = result {
                                actionDraft = ""
                            }
                            show(result, quietWhenWaiting: true)
                        }
                    )
                    confidenceRow
                    if let note = latestNote {
                        recentNote(note)
                    }
                }
                .padding(.horizontal, StileSpace.steps(4))
                .padding(.bottom, StileSpace.steps(2))
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollDismissesKeyboard(.interactively)
            fused(ladder)
                .padding(.horizontal, StileSpace.steps(4))
                .padding(.bottom, StileSpace.steps(3))
        }
    }

    private func statusBanner(_ line: String, retry: Bool) -> some View {
        VStack(alignment: .leading, spacing: StileSpace.steps(2)) {
            Text(line)
                .font(StileFont.caption(caption))
                .foregroundStyle(DesignTokens.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
            if retry {
                Button("Try again") {
                    Task { await store.load() }
                }
                .buttonStyle(MarkButtonStyle(role: .primary, loading: false))
            }
        }
        .padding(StileSpace.steps(3))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: StileRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: StileRadius.card, style: .continuous)
                .stroke(DesignTokens.ink, lineWidth: 2)
        )
        .stileShadow()
    }

    private func outcomeLane(_ ladder: Ladder) -> some View {
        VStack(alignment: .leading, spacing: StileSpace.steps(1)) {
            Text(outcomeHeading(written: ladder.outcome.holdsInk))
                .font(StileFont.caption(caption))
                .foregroundStyle(DesignTokens.muted)
            Text(ladder.outcome.holdsInk ? "Edit it if the change is wrong." : "Write the change this visit is for.")
                .font(StileFont.caption(caption))
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            TextField("Write the outcome", text: $outcomeDraft, axis: .vertical)
                .font(StileFont.body(bodySize))
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(3...6)
                .focused($focus, equals: .outcome)
                .padding(StileSpace.steps(3))
                .background(DesignTokens.bg)
                .clipShape(RoundedRectangle(cornerRadius: StileRadius.chip, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: StileRadius.chip, style: .continuous)
                        .stroke(DesignTokens.ink, lineWidth: 2)
                )
                .onChange(of: outcomeDraft) { _, value in
                    guard value != ladder.outcome.ink else { return }
                    show(store.writeOutcome(value), quietWhenWaiting: true)
                }
        }
    }

    private var outcomeTitle: String { "Outcome" }

    private func outcomeHeading(written: Bool) -> String {
        written ? "Outcome, written" : outcomeTitle
    }

    private var confidenceRow: some View {
        VStack(alignment: .leading, spacing: StileSpace.steps(2)) {
            Text("Confidence")
                .font(StileFont.caption(caption))
                .foregroundStyle(DesignTokens.muted)
            HStack(spacing: StileSpace.steps(2)) {
                ForEach(1...5, id: \.self) { value in
                    Button {
                        confidence = value
                    } label: {
                        Text(StileFormat.integer(value))
                            .font(StileFont.headline(StileSpace.steps(4)))
                            .foregroundStyle(confidence == value ? DesignTokens.bg : DesignTokens.ink)
                            .frame(maxWidth: .infinity, minHeight: StileSpace.steps(11))
                            .background(confidence == value ? DesignTokens.accent : DesignTokens.surface)
                            .clipShape(RoundedRectangle(cornerRadius: StileRadius.chip, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: StileRadius.chip, style: .continuous)
                                    .stroke(DesignTokens.ink, lineWidth: 2)
                            )
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(confidenceName(value))
                    .accessibilityAddTraits(confidence == value ? .isSelected : [])
                }
            }
        }
    }

    private func confidenceName(_ value: Int) -> String {
        let figure = StileFormat.integer(value)
        return "Confidence \(figure)"
    }

    private func recentNote(_ note: SessionNote) -> some View {
        let days = StileFormat.integer(daysSince(note))
        let ink = note.sections.first?.ink ?? ""
        return VStack(alignment: .leading, spacing: StileSpace.steps(1)) {
            Text(StileFormat.day(note.dayKey))
                .font(StileFont.caption(caption))
                .foregroundStyle(DesignTokens.muted)
            Text(ink)
                .font(StileFont.body(bodySize))
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            Text("\(days) days since that note.")
                .font(StileFont.caption(caption))
                .foregroundStyle(DesignTokens.muted)
        }
        .padding(StileSpace.steps(3))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: StileRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: StileRadius.card, style: .continuous)
                .stroke(DesignTokens.ink, lineWidth: 2)
        )
        .stileShadow()
    }

    private var latestNote: SessionNote? {
        guard let clientID = store.document.selectedClientID else { return nil }
        return store.document.sessionNotes
            .filter { $0.clientID == clientID }
            .max { $0.dayKey < $1.dayKey }
    }

    private func daysSince(_ note: SessionNote) -> Int {
        DayKey.daysSince(note.dayKey, until: DayKey.make(from: Date())) ?? 0
    }

    private func fused(_ ladder: Ladder) -> some View {
        VStack(spacing: StileSpace.steps(2)) {
            ViewThatFits(in: .horizontal) {
                verbRow(ladder)
                VStack(spacing: StileSpace.steps(2)) {
                    verb("Set", role: ladder.phase == .open ? .primary : .quiet, enabled: ladder.phase == .open) {
                        commit(.set)
                    }
                    verb("Harvest", role: ladder.phase == .scaled ? .primary : .quiet, enabled: ladder.phase == .scaled) {
                        commit(.harvest)
                    }
                    verb("Review", role: ladder.phase == .harvested ? .primary : .quiet, enabled: ladder.phase == .harvested) {
                        commit(.review)
                    }
                }
            }
            if canRetract {
                Button {
                    confirmRetract = true
                } label: {
                    Text("Retract")
                        .frame(maxWidth: .infinity, minHeight: StileSpace.steps(11))
                        .contentShape(Rectangle())
                }
                .buttonStyle(MarkButtonStyle(role: .destructive, loading: busy))
                .disabled(busy)
            }
        }
    }

    private func verbRow(_ ladder: Ladder) -> some View {
        HStack(spacing: StileSpace.steps(2)) {
            verb("Set", role: ladder.phase == .open ? .primary : .quiet, enabled: ladder.phase == .open) {
                commit(.set)
            }
            verb("Harvest", role: ladder.phase == .scaled ? .primary : .quiet, enabled: ladder.phase == .scaled) {
                commit(.harvest)
            }
            verb("Review", role: ladder.phase == .harvested ? .primary : .quiet, enabled: ladder.phase == .harvested) {
                commit(.review)
            }
        }
    }

    private func verb(
        _ title: String,
        role: MarkButtonStyle.Role,
        enabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, minHeight: StileSpace.steps(11))
                .contentShape(Rectangle())
        }
        .buttonStyle(MarkButtonStyle(role: role, loading: busy))
        .disabled(enabled == false || busy)
    }

    private var canRetract: Bool {
        guard let selected = store.document.selectedLadderID,
              let successor = store.document.ladder(selected),
              successor.isEmptySuccessor else { return false }
        return store.document.ladders.contains { $0.phase == .reviewed && $0.successorID == selected }
    }

    private var emptyBody: some View {
        VStack(alignment: .leading, spacing: StileSpace.steps(4)) {
            Image("stl_EmptyHome")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: StileSpace.steps(56))
                .clipped()
                .accessibilityHidden(true)
            Text("No visit is open.")
                .font(StileFont.display(display))
                .foregroundStyle(DesignTokens.ink)
            Text("Open the roster, then tap Set.")
                .font(StileFont.body(bodySize))
                .foregroundStyle(DesignTokens.muted)
            Spacer(minLength: 0)
            Button("Open roster") { cover = .clients }
                .buttonStyle(MarkButtonStyle(role: .primary, loading: false))
        }
        .padding(StileSpace.steps(4))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var errorBody: some View {
        VStack(alignment: .leading, spacing: StileSpace.steps(4)) {
            Text("This visit could not be read.")
                .font(StileFont.display(display))
                .foregroundStyle(DesignTokens.ink)
            Text(store.statusLine)
                .font(StileFont.body(bodySize))
                .foregroundStyle(DesignTokens.muted)
            Spacer(minLength: 0)
            Button("Try again") {
                Task { await store.load() }
            }
            .buttonStyle(MarkButtonStyle(role: .primary, loading: false))
        }
        .padding(StileSpace.steps(4))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private func syncDrafts() {
        guard let ladder else { return }
        outcomeDraft = ladder.outcome.ink
        knowDraft = ladder.knowHow.ink
        actionDraft = ladder.action.ink
        if let held = store.document.rungs.first(where: { $0.ladderID == ladder.id && $0.holdsBead }) {
            bead = held.index
        }
        banner = ""
    }

    private enum Verb { case set, harvest, review }

    private func commit(_ verb: Verb) {
        guard busy == false else { return }
        focus = nil
        busy = true
        let result: FoldResult
        switch verb {
        case .set:
            result = store.setTheScale(rung: bead)
        case .harvest:
            result = store.harvest()
        case .review:
            result = store.reviewTheLadder(confidence: confidence)
        }
        switch result {
        case .scaleLocked, .harvestSeated, .reviewFiled:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            if case .reviewFiled = result {
                snap = 0
            } else {
                snap += 1
            }
        default:
            break
        }
        show(result, quietWhenWaiting: false)
        syncDrafts()
        show(result, quietWhenWaiting: false)
        busy = false
    }

    private func peel() async {
        busy = true
        let result = await store.retract()
        show(result, quietWhenWaiting: false)
        syncDrafts()
        show(result, quietWhenWaiting: false)
        busy = false
    }

    private func show(_ result: FoldResult, quietWhenWaiting: Bool) {
        if quietWhenWaiting, case .harvestWaiting = result {
            return
        }
        banner = phrase(result)
    }

    private func phrase(_ result: FoldResult) -> String {
        switch result {
        case .scaleLocked(let mark):
            return "Scaled. Bead \(StileFormat.integer(mark.rung))."
        case .outcomeEmpty:
            return "Void. The top lane needs ink before Set."
        case .setRefused:
            return "Set refused. The scale is already locked."
        case .rungRefused:
            return "Set refused. Choose a rung from 0 to 10."
        case .harvestSeated:
            return "Harvested. Both lanes are seated."
        case .harvestWaiting:
            return "Harvest is waiting. Both lanes need ink."
        case .laneRushed:
            return "Rush. That lane stays dim until Scaled."
        case .laneLocked:
            return "That lane is locked."
        case .reviewFiled(let mark):
            return "Reviewed. Confidence \(StileFormat.integer(mark.confidence)). Next visit is open."
        case .reviewHollow:
            return "Hollow. The action lane is empty."
        case .reviewUnripe:
            return "Unripe. Harvest before Review."
        case .confidenceRefused:
            return "Confidence stays from 1 to 5."
        case .retracted:
            return "Retracted. This visit is harvested again."
        case .retractRefused:
            return "Retract refused. The next visit already holds ink."
        case .bareOpened:
            return "Empty. This visit has no ink."
        }
    }
}

/// Vertical rung field. Drag writes the bead that Set locks.
private struct SetScale: View {
    @Binding var bead: Int
    var locked: Bool
    var snap: Int
    var allowsMotion: Bool
    var display: CGFloat

    var body: some View {
        GeometryReader { proxy in
            HStack(alignment: .center, spacing: StileSpace.steps(2)) {
                VStack(spacing: 0) {
                    ForEach((0...10).reversed(), id: \.self) { rung in
                        Text(StileFormat.integer(rung))
                            .font(StileFont.caption(13))
                            .foregroundStyle(rung == bead ? DesignTokens.ink : DesignTokens.muted)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(width: StileSpace.steps(8))
                ZStack(alignment: .top) {
                    Rectangle()
                        .fill(DesignTokens.surface)
                        .colorEffect(
                            ShaderLibrary.rungField(
                                .float(Float(beadY(in: proxy.size.height))),
                                .float(Float(proxy.size.height))
                            )
                        )
                    ChipSnap(token: snap, allowsMotion: allowsMotion)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                    Text(StileFormat.integer(bead))
                        .font(StileFont.display(display))
                        .foregroundStyle(DesignTokens.bg)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .frame(width: StileSpace.steps(14), height: StileSpace.steps(14))
                        .background(DesignTokens.ink)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(DesignTokens.accent, lineWidth: 3))
                        .offset(y: beadCenter(in: proxy.size.height) - StileSpace.steps(7))
                        .accessibilityHidden(true)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: StileRadius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: StileRadius.card, style: .continuous)
                    .stroke(DesignTokens.ink, lineWidth: 2)
            )
            .stileShadow()
            .contentShape(RoundedRectangle(cornerRadius: StileRadius.card, style: .continuous))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        guard locked == false else { return }
                        bead = rung(at: value.location.y, height: proxy.size.height)
                    }
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Scale bead")
            .accessibilityValue(StileFormat.integer(bead))
            .accessibilityAdjustableAction { direction in
                guard locked == false else { return }
                if direction == .increment {
                    bead = min(10, bead + 1)
                } else {
                    bead = max(0, bead - 1)
                }
            }
        }
    }

    private func beadY(in height: CGFloat) -> CGFloat {
        beadCenter(in: height)
    }

    private func beadCenter(in height: CGFloat) -> CGFloat {
        let radius = StileSpace.steps(7)
        let span = max(height - radius * 2, 1)
        return radius + CGFloat(10 - bead) * (span / 10)
    }

    private func rung(at y: CGFloat, height: CGFloat) -> Int {
        guard height > 0 else { return bead }
        let fraction = min(1, max(0, y / height))
        let value = Int((fraction * 10).rounded())
        return min(10, max(0, 10 - value))
    }
}

/// Know-how and the action lane, grouped, dim until the scale is set.
private struct HarvestLanes: View {
    @Binding var knowDraft: String
    @Binding var actionDraft: String
    var dim: Bool
    var bodySize: CGFloat
    var caption: CGFloat
    var focus: FocusState<LaneFocus?>.Binding
    var onKnow: (String) -> Void
    var onAction: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: StileSpace.steps(2)) {
            Text(dim ? closedHint : openHint)
                .font(StileFont.caption(caption))
                .foregroundStyle(DesignTokens.muted)
            field(knowTitle, text: $knowDraft, lane: .know, commit: onKnow)
            field(actionTitle, text: $actionDraft, lane: .action, commit: onAction)
        }
        .padding(StileSpace.steps(3))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: StileRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: StileRadius.card, style: .continuous)
                .stroke(DesignTokens.ink.opacity(dim ? 0.35 : 1), lineWidth: 2)
        )
        .opacity(dim ? 0.55 : 1)
        .disabled(dim)
        .stileShadow()
    }

    private var knowTitle: String { "Know-how" }
    private var actionTitle: String { "Action" }
    private var closedHint: String { "Next writing step, after Set: know-how, then the action." }
    private var openHint: String { "Both lanes need ink before Harvest." }

    private func field(
        _ title: String,
        text: Binding<String>,
        lane: LaneFocus,
        commit: @escaping (String) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: StileSpace.steps(1)) {
            Text(title)
                .font(StileFont.caption(caption))
                .foregroundStyle(DesignTokens.muted)
            TextField(title, text: text, axis: .vertical)
                .font(StileFont.body(bodySize))
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(2...4)
                .focused(focus, equals: lane)
                .padding(StileSpace.steps(2))
                .background(DesignTokens.bg)
                .clipShape(RoundedRectangle(cornerRadius: StileRadius.chip, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: StileRadius.chip, style: .continuous)
                        .stroke(DesignTokens.ink, lineWidth: 2)
                )
                .onChange(of: text.wrappedValue) { _, value in
                    commit(value)
                }
        }
    }
}

enum LadderCover: String, Identifiable {
    case clients
    case progress
    case settings
    case scan

    var id: String { rawValue }
}
