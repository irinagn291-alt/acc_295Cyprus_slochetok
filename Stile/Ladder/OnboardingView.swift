import SwiftUI

/// Three pages. Skip and Continue both write the completion flag.
struct OnboardingView: View {
    @EnvironmentObject private var store: LadderStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var page = 0
    @ScaledMetric(relativeTo: .largeTitle) private var display: CGFloat = 28
    @ScaledMetric(relativeTo: .body) private var bodySize: CGFloat = 17

    private let pages: [(art: String, title: String, line: String)] = [
        ("stl_Onboarding1", "Session notes stay on this phone.", "Set the scale, harvest the visit, and file it here."),
        ("stl_Onboarding2", "Set the scale first.", "Drag the bead from 0 to 10, then tap Set."),
        ("stl_Onboarding3", "Review files the ladder.", "Know-how and Action seat together before the note freezes.")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: StileSpace.steps(4)) {
            pageBody
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            Button(page == pages.count - 1 ? "Continue" : "Next") {
                advance()
            }
            .buttonStyle(MarkButtonStyle(role: .primary, loading: false))
            .accessibilityHint("Writes the starting ladder and opens the session.")
            Button("Skip") {
                store.finishOnboarding()
            }
            .buttonStyle(MarkButtonStyle(role: .quiet, loading: false))
        }
        .padding(StileSpace.steps(4))
        .background(DesignTokens.bg.ignoresSafeArea())
    }

    private var pageBody: some View {
        let item = pages[page]
        return VStack(alignment: .leading, spacing: StileSpace.steps(4)) {
            Image(item.art)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: StileSpace.steps(70))
                .clipped()
                .accessibilityHidden(true)
            Text(item.title)
                .font(StileFont.display(display))
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(item.line)
                .font(StileFont.body(bodySize))
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .id(page)
        .transition(reduceMotion ? .opacity : .opacity)
    }

    private func advance() {
        if page < pages.count - 1 {
            withAnimation(reduceMotion ? .easeOut(duration: 0.16) : .easeOut(duration: 0.16)) {
                page += 1
            }
        } else {
            store.finishOnboarding()
        }
    }
}
