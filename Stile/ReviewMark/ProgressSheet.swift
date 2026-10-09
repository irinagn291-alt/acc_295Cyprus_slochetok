import SwiftUI

/// ReviewMark timeline and a scale sparkline for the selected client.
struct ProgressView: View {
    @EnvironmentObject private var store: LadderStore
    @Environment(\.dismiss) private var dismiss
    @ScaledMetric(relativeTo: .largeTitle) private var display: CGFloat = 28
    @ScaledMetric(relativeTo: .body) private var bodySize: CGFloat = 17
    @ScaledMetric(relativeTo: .caption) private var caption: CGFloat = 13

    private var clientID: UUID? { store.document.selectedClientID }

    private var marks: [ReviewMark] {
        guard let clientID else { return [] }
        return store.document.reviewMarks
            .filter { $0.clientID == clientID }
            .sorted { $0.dayKey < $1.dayKey }
    }

    private var scales: [ScaleMark] {
        guard let clientID else { return [] }
        return store.document.scaleMarks
            .filter { $0.clientID == clientID }
            .sorted { $0.dayKey < $1.dayKey }
    }

    var body: some View {
        NavigationStack {
            Group {
                if store.statusLine.isEmpty == false && marks.isEmpty {
                    errorPage
                } else if marks.isEmpty {
                    emptyPage
                } else {
                    filled
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DesignTokens.bg.ignoresSafeArea())
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .frame(minWidth: StileSpace.steps(11), minHeight: StileSpace.steps(11))
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
        .sheetArrival()
    }

    private var emptyPage: some View {
        VStack(alignment: .leading, spacing: StileSpace.steps(4)) {
            Image("stl_EmptyHome")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: StileSpace.steps(56))
                .clipped()
                .accessibilityHidden(true)
            Text("No reviews filed.")
                .font(StileFont.display(display))
                .foregroundStyle(DesignTokens.ink)
            Text("Harvest and review a visit to read the trend.")
                .font(StileFont.body(bodySize))
                .foregroundStyle(DesignTokens.muted)
            Spacer(minLength: 0)
            Button("Back to today") { dismiss() }
                .buttonStyle(MarkButtonStyle(role: .primary, loading: false))
        }
        .padding(StileSpace.steps(4))
        .frame(maxHeight: .infinity, alignment: .leading)
    }

    private var errorPage: some View {
        VStack(alignment: .leading, spacing: StileSpace.steps(4)) {
            Text("Progress could not be read.")
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
        .frame(maxHeight: .infinity, alignment: .leading)
    }

    private var filled: some View {
        VStack(alignment: .leading, spacing: StileSpace.steps(4)) {
            if let clientID, let summary = store.document.nextSessionSummary(
                clientID: clientID,
                today: DayKey.make(from: Date())
            ) {
                Text(daysLine(summary.daysSince))
                    .font(StileFont.body(bodySize))
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            sparkline
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            ScrollView {
                VStack(alignment: .leading, spacing: StileSpace.steps(3)) {
                    ForEach(marks) { mark in
                        VStack(alignment: .leading, spacing: StileSpace.steps(1)) {
                            Text(StileFormat.day(mark.dayKey))
                                .font(StileFont.headline(StileSpace.steps(5)))
                                .foregroundStyle(DesignTokens.ink)
                            Text(confidenceLine(mark.confidence))
                                .font(StileFont.caption(caption))
                                .foregroundStyle(DesignTokens.muted)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(StileSpace.steps(3))
                        .background(DesignTokens.surface)
                        .clipShape(RoundedRectangle(cornerRadius: StileRadius.card, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: StileRadius.card, style: .continuous)
                                .stroke(DesignTokens.ink, lineWidth: 2)
                        )
                        .stileShadow()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(StileSpace.steps(4))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var sparkline: some View {
        VStack(alignment: .leading, spacing: StileSpace.steps(2)) {
            Text("Scale")
                .font(StileFont.caption(caption))
                .foregroundStyle(DesignTokens.muted)
            scaleBars
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(StileSpace.steps(3))
                .background(DesignTokens.surface)
                .clipShape(RoundedRectangle(cornerRadius: StileRadius.card, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: StileRadius.card, style: .continuous)
                        .stroke(DesignTokens.ink, lineWidth: 2)
                )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var scaleBars: some View {
        GeometryReader { geo in
            let label = StileSpace.steps(5)
            let gap = StileSpace.steps(1)
            let plot = max(geo.size.height - label - gap, StileSpace.steps(4))
            let peak = max(scales.map(\.rung).max() ?? 1, 1)
            HStack(alignment: .bottom, spacing: StileSpace.steps(2)) {
                if scales.isEmpty {
                    Text("No scale yet.")
                        .font(StileFont.body(bodySize))
                        .foregroundStyle(DesignTokens.muted)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                } else {
                    ForEach(scales) { mark in
                        VStack(spacing: gap) {
                            RoundedRectangle(cornerRadius: StileRadius.chip, style: .continuous)
                                .fill(DesignTokens.accent)
                                .frame(height: plot * CGFloat(mark.rung) / CGFloat(peak))
                            Text(StileFormat.integer(mark.rung))
                                .font(StileFont.caption(caption))
                                .foregroundStyle(DesignTokens.ink)
                                .frame(height: label)
                        }
                        .frame(maxWidth: .infinity, alignment: .bottom)
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
        }
    }

    private func daysLine(_ count: Int) -> String {
        let figure = StileFormat.integer(count)
        let unit = count == 1 ? "day" : "days"
        return "\(figure) \(unit) since the latest note."
    }

    private func confidenceLine(_ value: Int) -> String {
        let figure = StileFormat.integer(value)
        return "Confidence \(figure)"
    }
}

typealias ProgressSheet = ProgressView
