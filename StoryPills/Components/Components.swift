import Combine
import SwiftUI

// MARK: - Logo

struct LogoView: View {
    var compact = false
    var body: some View {
        Image("StoryPillLogo")
            .resizable()
            .scaledToFit()
            .frame(height: compact ? 34 : 120)
            .accessibilityLabel("Story Pill")
    }
}

// MARK: - Top bar

struct TopBar<Trailing: View>: View {
    @Environment(\.palette) private var palette
    var title: String? = nil
    var onBack: (() -> Void)? = nil
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        ZStack {
            HStack {
                if let onBack {
                    IconButton(systemImage: "chevron.left", action: onBack)
                        .accessibilityLabel("Go back")
                } else {
                    LogoView(compact: true)
                }
                Spacer()
                trailing()
            }
            if let title {
                Text(title)
                    .font(Theme.heading(14, .bold))
                    .foregroundStyle(palette.text)
            }
        }
        .frame(height: 58)
    }
}

extension TopBar where Trailing == EmptyView {
    init(title: String? = nil, onBack: (() -> Void)? = nil) {
        self.title = title
        self.onBack = onBack
        self.trailing = { EmptyView() }
    }
}

struct IconButton: View {
    @Environment(\.palette) private var palette
    let systemImage: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(palette.text)
                .frame(width: 40, height: 40)
                .glassCard(cornerRadius: 14)
        }
        .buttonStyle(.plain)
    }
}

struct AvatarBadge: View {
    let initials: String
    var size: CGFloat = 36
    var body: some View {
        Text(initials)
            .font(Theme.heading(size * 0.33, .bold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(Theme.avatarGradient, in: Circle())
    }
}

// MARK: - Headings

struct Eyebrow: View {
    let text: String
    var systemImage: String? = nil
    var body: some View {
        HStack(spacing: 6) {
            if let systemImage { Image(systemName: systemImage) }
            Text(text.uppercased())
        }
        .font(.system(size: 11, weight: .heavy))
        .tracking(1.5)
        .foregroundStyle(Theme.eyebrow)
        .shadow(color: Color(hex: 0x789EFF, opacity: 0.42), radius: 9)
    }
}

/// Two-line heading where the second line uses the shimmering gradient.
struct GradientHeading: View {
    @Environment(\.palette) private var palette
    let line1: String
    let line2: String
    var size: CGFloat = 31
    var alignment: TextAlignment = .leading

    var body: some View {
        VStack(alignment: alignment == .center ? .center : .leading, spacing: 0) {
            Text(line1).foregroundStyle(palette.text)
            Text(line2).foregroundStyle(Theme.titleGradient)
        }
        .font(Theme.heading(size))
        .tracking(-1)
        .multilineTextAlignment(alignment)
    }
}

struct HeadingBlock: View {
    @Environment(\.palette) private var palette
    let eyebrow: String
    var eyebrowIcon: String? = "sparkles"
    let line1: String
    let line2: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Eyebrow(text: eyebrow, systemImage: eyebrowIcon)
            GradientHeading(line1: line1, line2: line2)
            if let subtitle {
                Text(subtitle)
                    .font(Theme.body(14))
                    .foregroundStyle(palette.muted)
                    .lineSpacing(3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 20)
        .padding(.bottom, 18)
    }
}

// MARK: - Genre UI

struct GenreSymbol: View {
    let genre: Genre
    var size: CGFloat = 35
    var circle = false
    var body: some View {
        Text(genre.symbol)
            .font(.system(size: size * 0.45, weight: .bold))
            .foregroundStyle(genre.accent)
            .frame(width: size, height: size)
            .background(genre.accent.opacity(0.25), in: RoundedRectangle(cornerRadius: circle ? size / 2 : 13, style: .continuous))
    }
}

struct GenreCard: View {
    @Environment(\.palette) private var palette
    let genre: Genre
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                GenreSymbol(genre: genre)
                Text(genre.name)
                    .font(Theme.heading(15, .bold))
                    .foregroundStyle(palette.text)
                    .padding(.top, 10)
                Text(genre.detail)
                    .font(Theme.body(11))
                    .foregroundStyle(palette.muted)
                    .padding(.top, 2)
            }
            .frame(maxWidth: .infinity, minHeight: 113, alignment: .leading)
            .padding(15)
            .background(alignment: .topTrailing) {
                Circle().fill(genre.accent.opacity(0.14)).frame(width: 70).blur(radius: 7).offset(x: 23, y: -25)
            }
            .clipShape(RoundedRectangle(cornerRadius: 21, style: .continuous))
            .glassCard(tint: genre.accent, selected: selected)
            .overlay(alignment: .topTrailing) {
                if selected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 22, height: 22)
                        .background(genre.accent, in: Circle())
                        .padding(11)
                }
            }
            .offset(y: selected ? -2 : 0)
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.2), value: selected)
    }
}

struct GenreGrid: View {
    @Binding var selected: Genre
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            ForEach(Genre.allCases) { genre in
                GenreCard(genre: genre, selected: selected == genre) { selected = genre }
            }
        }
    }
}

/// Small colored "→" chain of genres used on community cards.
struct GenrePath: View {
    let genres: [Genre]
    var size: CGFloat = 10
    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(genres.enumerated()), id: \.offset) { index, genre in
                HStack(spacing: 3) {
                    Text(genre.symbol)
                    Text(genre.name)
                }
                .font(.system(size: size, weight: .semibold))
                .foregroundStyle(genre.summaryAccent)
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(genre.summaryAccent.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
                if index < genres.count - 1 {
                    Image(systemName: "arrow.right").font(.system(size: size - 2)).foregroundStyle(.secondary)
                }
            }
        }
        .lineLimit(1)
    }
}

struct GenreTag: View {
    let genre: Genre
    var body: some View {
        HStack(spacing: 6) {
            Text(genre.symbol)
            Text(genre.name.uppercased())
        }
        .font(.system(size: 10, weight: .bold))
        .tracking(0.7)
        .foregroundStyle(genre.summaryAccent)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(genre.summaryAccent.opacity(0.12), in: RoundedRectangle(cornerRadius: 11))
        .overlay(RoundedRectangle(cornerRadius: 11).stroke(genre.summaryAccent.opacity(0.22)))
    }
}

// MARK: - Motif cover art

struct MotifArt: View {
    let motif: Motif
    var accent: Color = Theme.violet
    var cornerRadius: CGFloat = 18

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: 0x1B2556), Color(hex: 0x2A1850), Color(hex: 0x0E0C24)], startPoint: .topLeading, endPoint: .bottomTrailing)
            Circle().fill(accent.opacity(0.35)).frame(width: 120).blur(radius: 30).offset(x: 40, y: -30)
            Circle().fill(Color(hex: 0xE9E4FF, opacity: 0.85)).frame(width: 26).offset(x: 46, y: -26)
                .shadow(color: .white.opacity(0.6), radius: 10)
            Image(systemName: motif.systemImage)
                .font(.system(size: 34, weight: .light))
                .foregroundStyle(.white.opacity(0.85))
                .shadow(color: accent, radius: 12)
            Text("✦").foregroundStyle(.white.opacity(0.7)).offset(x: -50, y: 26)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

// MARK: - Progress bar

struct GradientProgress: View {
    let value: Double // 0...1
    var height: CGFloat = 4
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.08))
                Capsule().fill(Theme.progressGradient).frame(width: geo.size.width * min(max(value, 0), 1))
            }
        }
        .frame(height: height)
        .animation(.easeInOut(duration: 0.3), value: value)
    }
}

// MARK: - Loading dots

struct LoadingDots: View {
    @State private var phase = 0
    let timer = Timer.publish(every: 0.35, on: .main, in: .common).autoconnect()
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Theme.lilac)
                    .frame(width: 7, height: 7)
                    .opacity(phase == index ? 1 : 0.3)
                    .scaleEffect(phase == index ? 1.2 : 1)
            }
        }
        .onReceive(timer) { _ in withAnimation(.easeInOut(duration: 0.25)) { phase = (phase + 1) % 3 } }
    }
}

// MARK: - Glowing capsule ("pill") illustration

struct CapsuleIllustration: View {
    var left: Color = Color(hex: 0x6557DD)
    var right: Color = Color(hex: 0xAD65DF)
    var width: CGFloat = 150
    @State private var floating = false

    var body: some View {
        let height = width * 0.42
        HStack(spacing: 2) {
            UnevenRoundedRectangle(topLeadingRadius: height / 2, bottomLeadingRadius: height / 2, bottomTrailingRadius: 6, topTrailingRadius: 6)
                .fill(LinearGradient(colors: [left.opacity(0.75), left], startPoint: .topLeading, endPoint: .bottomTrailing))
            UnevenRoundedRectangle(topLeadingRadius: 6, bottomLeadingRadius: 6, bottomTrailingRadius: height / 2, topTrailingRadius: height / 2)
                .fill(LinearGradient(colors: [right.opacity(0.75), right], startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        .frame(width: width, height: height)
        .overlay(Image(systemName: "sparkles").font(.system(size: height * 0.4)).foregroundStyle(.white).shadow(color: .white, radius: 8))
        .rotationEffect(.degrees(-12))
        .shadow(color: right.opacity(0.5), radius: 24)
        .offset(y: floating ? -7 : 0)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) { floating = true }
        }
    }
}

// MARK: - Bottom tab bar

struct BottomNav: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var palette

    private let items: [(icon: String, label: String, target: Screen)] = [
        ("house", "Create", .home),
        ("person.2", "Community", .community),
        ("books.vertical", "Library", .library),
        ("person", "Profile", .profile),
    ]

    var body: some View {
        HStack {
            ForEach(items, id: \.label) { item in
                let active = app.screen == item.target
                Button { app.go(item.target) } label: {
                    VStack(spacing: 3) {
                        Image(systemName: active ? item.icon + ".fill" : item.icon)
                            .font(.system(size: 17))
                            .frame(width: 40, height: 30)
                            .background(LinearGradient(colors: [Color(hex: 0x885BF0, opacity: 0.28), Color(hex: 0xED50BB, opacity: 0.18)], startPoint: .topLeading, endPoint: .bottomTrailing).opacity(active ? 1 : 0), in: RoundedRectangle(cornerRadius: 11))
                        Text(item.label).font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(active ? Theme.lilac : Color(hex: 0x76738D))
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 69)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 23, style: .continuous))
        .background(palette.navBackground, in: RoundedRectangle(cornerRadius: 23, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 23, style: .continuous).stroke(Color.white.opacity(0.1)))
        .shadow(color: .black.opacity(0.34), radius: 20, y: 10)
        .padding(.horizontal, 16)
    }
}

// MARK: - Screen scaffold

/// Standard scrolling content screen with the app background and horizontal padding.
struct ScreenScroll<Content: View>: View {
    var bottomInset: CGFloat = 24
    @ViewBuilder var content: () -> Content
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) { content() }
                .padding(.horizontal, 20)
                .padding(.bottom, bottomInset)
        }
    }
}
