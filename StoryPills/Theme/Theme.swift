import SwiftUI

// Design tokens ported from the Figma Make prototype (src/index.css).

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

struct Palette {
    let background: Color
    let text: Color
    let muted: Color
    let faint: Color
    let surface: Color
    let surfaceBorder: Color
    let navBackground: Color

    static let dark = Palette(
        background: Color(hex: 0x0C0B20),
        text: Color(hex: 0xF8F7FF),
        muted: Color(hex: 0xAAA7C3),
        faint: Color(hex: 0x77738C),
        surface: Color.white.opacity(0.06),
        surfaceBorder: Color(hex: 0xB0CDFF, opacity: 0.12),
        navBackground: Color(hex: 0x14122D, opacity: 0.85)
    )

    static let light = Palette(
        background: Color(hex: 0xF5F1FC),
        text: Color(hex: 0x1F1838),
        muted: Color(hex: 0x746E83),
        faint: Color(hex: 0x8A849A),
        surface: Color.white.opacity(0.63),
        surfaceBorder: Color(hex: 0x45316B, opacity: 0.1),
        navBackground: Color(hex: 0xFAF7FF, opacity: 0.9)
    )
}

private struct PaletteKey: EnvironmentKey {
    static let defaultValue = Palette.dark
}

extension EnvironmentValues {
    var palette: Palette {
        get { self[PaletteKey.self] }
        set { self[PaletteKey.self] = newValue }
    }
}

enum Theme {
    static let eyebrow = Color(hex: 0xAEBDFF)
    static let violet = Color(hex: 0x966CFF)
    static let lilac = Color(hex: 0xC49BFF)

    static let primaryGradient = LinearGradient(
        colors: [Color(hex: 0x5868D9), Color(hex: 0x7358D8), Color(hex: 0x426FC8)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let titleGradient = LinearGradient(
        colors: [Color(hex: 0xC9D3FF), Color(hex: 0xA798FF), Color(hex: 0x86DCF3), Color(hex: 0xD5F7FF)],
        startPoint: .leading, endPoint: .trailing
    )
    static let progressGradient = LinearGradient(
        colors: [Color(hex: 0x8E63F5), Color(hex: 0xE658B7)],
        startPoint: .leading, endPoint: .trailing
    )
    static let avatarGradient = LinearGradient(
        colors: [Color(hex: 0x8862F4), Color(hex: 0xEB5AB4)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    // Manrope (headings) and DM Sans (body) in the web version.
    // Uses SF Rounded / SF until the custom fonts are bundled (see README).
    static func heading(_ size: CGFloat, _ weight: Font.Weight = .heavy) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
    static func body(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }
    static let reading = Font.system(size: 18, design: .serif)
}

// MARK: - Background

struct AppBackground: View {
    @Environment(\.palette) private var palette
    var body: some View {
        ZStack {
            palette.background
            RadialGradient(colors: [Color(hex: 0x7740E0, opacity: 0.22), .clear], center: UnitPoint(x: 0.9, y: 0.05), startRadius: 0, endRadius: 320)
            RadialGradient(colors: [Color(hex: 0x19A4E7, opacity: 0.12), .clear], center: UnitPoint(x: 0.1, y: 0.75), startRadius: 0, endRadius: 360)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Button styles

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.body(16, .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 55)
            .background(Theme.primaryGradient, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color(hex: 0xBEDAFF, opacity: 0.18)))
            .shadow(color: Color(hex: 0x1F338C, opacity: isEnabled ? 0.36 : 0), radius: 16, y: 12)
            .opacity(isEnabled ? 1 : 0.45)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.palette) private var palette
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.body(15, .semibold))
            .foregroundStyle(palette.text)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(palette.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(palette.surfaceBorder))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondary: SecondaryButtonStyle { SecondaryButtonStyle() }
}

/// Label used inside primary buttons: title on the left, icon in a frosted square on the right.
struct PrimaryLabel: View {
    let title: String
    var systemImage: String = "arrow.right"
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .semibold))
                .frame(width: 34, height: 34)
                .background(Color.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(.leading, 22)
        .padding(.trailing, 11)
    }
}

// MARK: - Glass card

struct GlassCard: ViewModifier {
    @Environment(\.palette) private var palette
    var cornerRadius: CGFloat = 21
    var tint: Color? = nil
    var selected = false

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(tint.map { $0.opacity(selected ? 0.14 : 0.06) } ?? palette.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(selected ? (tint ?? Theme.violet).opacity(0.8) : palette.surfaceBorder, lineWidth: 1)
            )
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 21, tint: Color? = nil, selected: Bool = false) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius, tint: tint, selected: selected))
    }
}
