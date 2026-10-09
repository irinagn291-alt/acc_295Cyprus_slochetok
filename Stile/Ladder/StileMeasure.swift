import SwiftUI

/// Spacing, radii, type, and the one button style. Views reach colour only through DesignTokens.
enum StileSpace {
    static let unit: CGFloat = 4
    static func steps(_ count: Int) -> CGFloat { unit * CGFloat(count) }
}

enum StileRadius {
    /// Cards, sheets, and primary surfaces.
    static let card: CGFloat = 18
    /// Chips, badges, and small controls.
    static let chip: CGFloat = 8
}

enum StileFont {
    static func display(_ size: CGFloat) -> Font {
        .custom("AvenirNext-DemiBold", size: size, relativeTo: .largeTitle)
    }

    static func title(_ size: CGFloat) -> Font {
        .custom("AvenirNext-Regular", size: size, relativeTo: .title2)
    }

    static func headline(_ size: CGFloat) -> Font {
        .custom("AvenirNext-Regular", size: size, relativeTo: .headline)
    }

    static func body(_ size: CGFloat) -> Font {
        .custom("AvenirNext-Regular", size: size, relativeTo: .body)
    }

    static func caption(_ size: CGFloat) -> Font {
        .custom("AvenirNext-Regular", size: size, relativeTo: .caption)
    }

    static func micro(_ size: CGFloat) -> Font {
        .custom("AvenirNext-Regular", size: size, relativeTo: .caption2)
    }
}

enum StileFormat {
    static func integer(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    static func day(_ key: Int) -> String {
        guard let date = DayKey.date(from: key) else { return integer(key) }
        let formatter = DateFormatter()
        formatter.calendar = .current
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

extension View {
    func stileShadow() -> some View {
        shadow(color: DesignTokens.ink.opacity(0.16), radius: StileRadius.chip, x: 0, y: StileSpace.unit)
    }
}

/// Primary and destructive marks. Press scales to 0.97. Reduce Motion keeps the fade.
struct MarkButtonStyle: ButtonStyle {
    enum Role {
        case primary
        case destructive
        case quiet
    }

    var role: Role
    var loading: Bool
    var compact: Bool = false
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed && isEnabled && loading == false
        let radius = compact ? StileRadius.chip : StileRadius.card
        return configuration.label
            .font(StileFont.headline(StileSpace.steps(4)))
            .foregroundStyle(foreground)
            .frame(
                minWidth: compact ? StileSpace.steps(11) : nil,
                maxWidth: compact ? StileSpace.steps(11) : .infinity,
                minHeight: StileSpace.steps(11)
            )
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(DesignTokens.ink, lineWidth: 2)
            )
            .opacity(isEnabled && loading == false ? 1 : 0.45)
            .scaleEffect(pressed && reduceMotion == false ? 0.97 : 1)
            .animation(.easeOut(duration: 0.16), value: pressed)
            .contentShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay {
                if loading {
                    ProgressView()
                        .tint(foreground)
                }
            }
    }

    private var background: Color {
        switch role {
        case .primary: DesignTokens.accent
        case .destructive: DesignTokens.ink
        case .quiet: DesignTokens.surface
        }
    }

    private var foreground: Color {
        switch role {
        case .primary, .destructive: DesignTokens.bg
        case .quiet: DesignTokens.ink
        }
    }
}

struct SheetArrival: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shown = false

    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .scaleEffect(reduceMotion ? 1 : (shown ? 1 : 0.96))
            .onAppear {
                withAnimation(.easeOut(duration: 0.16)) {
                    shown = true
                }
            }
    }
}

extension View {
    func sheetArrival() -> some View {
        modifier(SheetArrival())
    }
}
