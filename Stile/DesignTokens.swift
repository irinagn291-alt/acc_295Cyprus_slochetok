import SwiftUI

/// SPEC section 7. The only place these hex values live — reach colours
/// and the font family through here. Keep this file and its values.
enum DesignTokens {
    /// #FFFFFF
    static let bg = Color(red: 1.000000, green: 1.000000, blue: 1.000000)
    static let bgHex = "#FFFFFF"
    /// #FFFFFF
    static let surface = Color(red: 1.000000, green: 1.000000, blue: 1.000000)
    static let surfaceHex = "#FFFFFF"
    /// #3C3C3C
    static let ink = Color(red: 0.235294, green: 0.235294, blue: 0.235294)
    static let inkHex = "#3C3C3C"
    /// #BE59FF
    static let accent = Color(red: 0.745098, green: 0.349020, blue: 1.000000)
    static let accentHex = "#BE59FF"
    /// #6E6E6E
    static let muted = Color(red: 0.431373, green: 0.431373, blue: 0.431373)
    static let mutedHex = "#6E6E6E"
    static let fontFamily = "Avenir Next"
}
