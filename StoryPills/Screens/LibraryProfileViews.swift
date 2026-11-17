import SwiftUI

// MARK: - Library

struct LibraryView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var palette
    @State private var filter = "All"
    private let filters = ["All", "In Progress", "Completed"]

    private var visibleBooks: [LibraryBook] {
        filter == "All" ? SampleData.libraryBooks : SampleData.libraryBooks.filter { $0.status.rawValue == filter }
    }

    var body: some View {
        ScreenScroll(bottomInset: 110) {
            TopBar()
            HeadingBlock(eyebrow: "Your collection", eyebrowIcon: nil, line1: "My", line2: "Library", subtitle: "Stories born from your choices.")

            HStack(spacing: 6) {
                ForEach(filters, id: \.self) { item in
                    Button(item) { withAnimation { filter = item } }
                        .font(Theme.body(13, .semibold))
                        .foregroundStyle(filter == item ? .white : palette.muted)
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(filter == item ? AnyShapeStyle(Theme.primaryGradient) : AnyShapeStyle(palette.surface), in: Capsule())
                        .buttonStyle(.plain)
                }
            }

            if filter != "Completed" {
                let book = SampleData.libraryBooks[0]
                Button { app.openBook(book) } label: {
                    HStack(spacing: 14) {
                        MotifArt(motif: .door, accent: book.genre.accent, cornerRadius: 16)
                            .frame(width: 110, height: 150)
                            .overlay(alignment: .topLeading) {
                                Text("In progress").font(Theme.body(10, .semibold)).foregroundStyle(.white)
                                    .padding(.horizontal, 8).padding(.vertical, 4)
                                    .background(.black.opacity(0.35), in: Capsule()).padding(8)
                            }
                        VStack(alignment: .leading, spacing: 0) {
                            Text(book.meta.uppercased()).font(.system(size: 10, weight: .semibold)).tracking(0.8).foregroundStyle(Color(hex: 0xA889F2))
                            Text(book.title).font(Theme.heading(17, .bold)).foregroundStyle(palette.text).padding(.top, 7)
                            Spacer(minLength: 12)
                            GradientProgress(value: Double(book.progress) / 100, height: 3)
                            Text(book.chapterLabel).font(Theme.body(11)).foregroundStyle(palette.faint).padding(.top, 5)
                            Label("Open story", systemImage: "arrow.right")
                                .labelStyle(TrailingIconLabelStyle())
                                .font(Theme.body(12, .bold)).foregroundStyle(.white)
                                .frame(maxWidth: .infinity, minHeight: 34)
                                .background(Theme.primaryGradient, in: RoundedRectangle(cornerRadius: 10))
                                .padding(.top, 10)
                        }
                    }
                    .padding(12)
                    .glassCard(cornerRadius: 22)
                }
                .buttonStyle(.plain)
                .padding(.top, 16)
            }

            HStack {
                Text(filter == "All" ? "All stories" : filter).font(Theme.heading(15, .bold)).foregroundStyle(palette.text)
                Spacer()
                Text("\(visibleBooks.count) stories").font(Theme.body(11)).foregroundStyle(palette.faint)
            }
            .padding(.top, 23).padding(.bottom, 10)

            VStack(spacing: 8) {
                ForEach(visibleBooks.filter { filter == "Completed" || $0.id != "door" }) { book in
                    Button { app.openBook(book) } label: {
                        HStack(spacing: 12) {
                            Text(book.genre.symbol)
                                .font(.system(size: 18)).foregroundStyle(.white)
                                .frame(width: 49, height: 59)
                                .background(LinearGradient(colors: [book.genre.accent, Color(hex: 0x2A173D)], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 11))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(book.meta.uppercased()).font(.system(size: 10, weight: .semibold)).tracking(0.8).foregroundStyle(Color(hex: 0xA889F2))
                                Text(book.title).font(Theme.heading(14, .semibold)).foregroundStyle(palette.text)
                                Text(book.chapterLabel).font(Theme.body(11)).foregroundStyle(palette.faint)
                            }
                            Spacer()
                            Image(systemName: "chevron.right").foregroundStyle(palette.faint)
                        }
                        .padding(9)
                        .glassCard(cornerRadius: 18)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct TrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 6) { configuration.title; configuration.icon }
    }
}

// MARK: - Book details

struct BookDetailsView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var palette

    var body: some View {
        let book = app.selectedBook
        ScreenScroll {
            TopBar(title: "Book details", onBack: { app.go(.library) })

            VStack(spacing: 10) {
                Text(book.genre.symbol).font(.system(size: 60, weight: .bold)).foregroundStyle(.white)
                    .shadow(color: book.genre.accent, radius: 20)
                Text(book.meta).font(Theme.body(12, .semibold)).foregroundStyle(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity, minHeight: 220)
            .background(
                LinearGradient(colors: [book.genre.accent.opacity(0.9), Color(hex: 0x2A173D)], startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: 26, style: .continuous)
            )
            .padding(.top, 10)

            VStack(alignment: .leading, spacing: 8) {
                Eyebrow(text: book.status.rawValue)
                Text(book.title).font(Theme.heading(28)).tracking(-1).foregroundStyle(palette.text)
                Text(book.summary).font(Theme.body(14)).foregroundStyle(palette.muted).lineSpacing(3)
            }
            .padding(.vertical, 20)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Reading progress").font(Theme.body(13)).foregroundStyle(palette.muted)
                    Spacer()
                    Text("\(book.progress)%").font(Theme.heading(15, .bold)).foregroundStyle(palette.text)
                }
                GradientProgress(value: Double(book.progress) / 100)
                Text(book.chapterLabel).font(Theme.body(11)).foregroundStyle(palette.faint)
            }
            .padding(16)
            .glassCard(cornerRadius: 18)

            Button { app.openJourney(back: .details, bookJourney: book.journey) } label: {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles").foregroundStyle(Theme.lilac)
                        .frame(width: 34, height: 34).background(Theme.violet.opacity(0.16), in: RoundedRectangle(cornerRadius: 11))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Story journey").font(Theme.heading(14, .bold)).foregroundStyle(palette.text)
                        Text("\(book.journey.count) plot points · Tap to explore").font(Theme.body(11)).foregroundStyle(palette.faint)
                    }
                    Spacer()
                    Image(systemName: "chevron.right").foregroundStyle(palette.faint)
                }
                .padding(14)
                .glassCard(cornerRadius: 18)
            }
            .buttonStyle(.plain)
            .padding(.top, 12)

            Button(action: app.readBook) { PrimaryLabel(title: book.status == .completed ? "Read Again" : "Resume Reading") }
                .buttonStyle(.primary)
                .padding(.top, 20)
        }
    }
}

// MARK: - Profile

struct ProfileView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var palette
    @State private var notifications = true

    var body: some View {
        ScreenScroll(bottomInset: 110) {
            TopBar()
            VStack(spacing: 4) {
                Text(app.profile.initials)
                    .font(Theme.heading(22)).foregroundStyle(.white)
                    .frame(width: 72, height: 72)
                    .background(Theme.avatarGradient, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                    .shadow(color: Color(hex: 0x8B43D6, opacity: 0.3), radius: 14, y: 13)
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "sparkles").font(.system(size: 10)).foregroundStyle(.white)
                            .frame(width: 25, height: 25)
                            .background(Color(hex: 0x35CBD9), in: Circle())
                            .overlay(Circle().stroke(palette.background, lineWidth: 3))
                            .offset(x: 5, y: 4)
                    }
                Text(app.profile.name).font(Theme.heading(22)).foregroundStyle(palette.text).padding(.top, 12)
                Text(app.profile.email).font(Theme.body(13)).foregroundStyle(palette.muted)
                HStack(spacing: 22) {
                    stat("7", "Stories")
                    Rectangle().fill(palette.surfaceBorder).frame(width: 1, height: 23)
                    stat("34", "Choices")
                    Rectangle().fill(palette.surfaceBorder).frame(width: 1, height: 23)
                    stat("3", "Worlds")
                }
                .padding(.top, 18)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)

            Text("PREFERENCES").font(.system(size: 11, weight: .bold)).tracking(1.2).foregroundStyle(palette.faint).padding(.leading, 4).padding(.bottom, 8)
            VStack(spacing: 0) {
                row(icon: app.lightTheme ? "sun.max" : "moon", tint: Theme.violet, title: "Appearance", subtitle: app.lightTheme ? "Dreamy light" : "Midnight glow") {
                    Picker("Appearance", selection: $app.lightTheme) {
                        Image(systemName: "moon").tag(false)
                        Image(systemName: "sun.max").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 96)
                }
                Divider().overlay(palette.surfaceBorder)
                row(icon: "sparkles", tint: Genre.horror.accent, title: "Story reminders", subtitle: "Nudge me to keep reading") {
                    Toggle("", isOn: $notifications).labelsHidden().tint(Theme.violet)
                }
                Divider().overlay(palette.surfaceBorder)
                row(icon: "book", tint: Genre.romance.accent, title: "Reading preferences", subtitle: "Text size and spacing") {
                    Image(systemName: "chevron.right").foregroundStyle(palette.faint)
                }
            }
            .glassCard(cornerRadius: 18)

            VStack(spacing: 0) {
                row(icon: nil, tint: .clear, title: "About Story Pills", subtitle: "Version 1.0 · Made for dreamers") {
                    Image(systemName: "chevron.right").foregroundStyle(palette.faint)
                }
                Divider().overlay(palette.surfaceBorder)
                Button(action: app.logout) {
                    row(icon: nil, tint: .clear, title: "Log out", subtitle: "Return to the login screen", titleColor: Color(hex: 0xFF7A9A)) {
                        Image(systemName: "chevron.right").foregroundStyle(palette.faint)
                    }
                }
                .buttonStyle(.plain)
            }
            .glassCard(cornerRadius: 18)
            .padding(.top, 15)
        }
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(Theme.heading(17)).foregroundStyle(palette.text)
            Text(label.uppercased()).font(.system(size: 10)).tracking(0.8).foregroundStyle(palette.faint)
        }
    }

    private func row<Accessory: View>(icon: String?, tint: Color, title: String, subtitle: String, titleColor: Color? = nil, @ViewBuilder accessory: () -> Accessory) -> some View {
        HStack(spacing: 11) {
            if let icon {
                Image(systemName: icon).foregroundStyle(tint)
                    .frame(width: 36, height: 36)
                    .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 12))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(Theme.heading(14, .semibold)).foregroundStyle(titleColor ?? palette.text)
                Text(subtitle).font(Theme.body(11)).foregroundStyle(palette.faint)
            }
            Spacer()
            accessory()
        }
        .padding(.horizontal, 12)
        .frame(minHeight: 62)
        .contentShape(Rectangle())
    }
}
