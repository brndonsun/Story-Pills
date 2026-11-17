import SwiftUI

// MARK: - Interactive plot matrix

struct StoryJourneyView: View {
    @Environment(\.palette) private var palette
    let journey: [Genre]
    var compact = false

    @State private var active = 0
    @State private var momentsOpen = false

    private var summary: ChapterSummary { SampleData.chapterSummaries[min(active, SampleData.chapterSummaries.count - 1)] }
    private var choice: ChapterChoice { SampleData.chapterChoices[min(active, SampleData.chapterChoices.count - 1)] }
    private var activeGenre: Genre { journey.indices.contains(active) ? journey[active] : .mystery }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("YOUR PLOT MATRIX").font(.system(size: 10, weight: .semibold)).tracking(1).foregroundStyle(palette.faint)
                    Text("\(journey.count) choices made").font(Theme.heading(14, .bold)).foregroundStyle(palette.text)
                }
                Spacer()
                Image(systemName: "sparkles").foregroundStyle(Theme.lilac)
                    .frame(width: 31, height: 31)
                    .background(Theme.violet.opacity(0.16), in: RoundedRectangle(cornerRadius: 11))
            }

            pathRow

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Chapter \(active + 1)").font(Theme.body(11)).foregroundStyle(palette.faint)
                        Text(SampleData.chapters[min(active, SampleData.chapters.count - 1)].title)
                            .font(Theme.heading(16, .bold)).foregroundStyle(palette.text)
                    }
                    Spacer()
                    GenreTag(genre: activeGenre)
                }
                Text(summary.summary)
                    .font(Theme.body(14)).foregroundStyle(palette.text.opacity(0.9))
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        LinearGradient(colors: [activeGenre.summaryAccent.opacity(0.22), activeGenre.summaryAccent.opacity(0.04)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )

                if !compact {
                    VStack(alignment: .leading, spacing: 10) {
                        Button { withAnimation { momentsOpen.toggle() } } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Moments That Shaped This Chapter").font(Theme.heading(13, .bold)).foregroundStyle(palette.text)
                                    Text(momentsOpen ? "Hide key moments" : "Reveal 3 key moments").font(Theme.body(11)).foregroundStyle(palette.faint)
                                }
                                Spacer()
                                Image(systemName: "chevron.right").rotationEffect(.degrees(momentsOpen ? 90 : 0)).foregroundStyle(palette.muted)
                            }
                        }
                        .buttonStyle(.plain)
                        if momentsOpen {
                            ForEach(Array(summary.events.enumerated()), id: \.offset) { index, event in
                                HStack(spacing: 10) {
                                    Text("\(index + 1)").font(Theme.body(11, .bold)).foregroundStyle(.white)
                                        .frame(width: 22, height: 22).background(activeGenre.summaryAccent, in: Circle())
                                    Text(event).font(Theme.body(13)).foregroundStyle(palette.muted)
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                    }
                    .padding(14)
                    .glassCard(cornerRadius: 16)

                    VStack(alignment: .leading, spacing: 8) {
                        Label("The choice that changed everything".uppercased(), systemImage: "sparkles")
                            .font(.system(size: 10, weight: .bold)).tracking(1).foregroundStyle(activeGenre.summaryAccent)
                        Text("“\(choice.decision)”").font(Theme.heading(18, .bold)).foregroundStyle(palette.text)
                        Text(choice.impact).font(Theme.body(13)).foregroundStyle(palette.muted)
                        HStack(spacing: 4) {
                            Text("Selected pill").foregroundStyle(palette.faint)
                            Text(activeGenre.symbol)
                            Text(activeGenre.name).bold()
                        }
                        .font(Theme.body(12)).foregroundStyle(activeGenre.summaryAccent)
                    }
                    .padding(16)
                    .glassCard(cornerRadius: 18, tint: activeGenre.summaryAccent, selected: true)
                }
            }
            .id(active)
            .transition(.opacity)
        }
        .animation(.easeInOut(duration: 0.25), value: active)
    }

    private var pathRow: some View {
        GeometryReader { geo in
            let count = max(journey.count, 1)
            let step = count > 1 ? (geo.size.width - 40) / CGFloat(count - 1) : 0
            let points = (0..<count).map { CGPoint(x: 20 + CGFloat($0) * step, y: $0 % 2 == 0 ? 26 : 46) }
            ZStack(alignment: .topLeading) {
                Path { path in
                    for (i, p) in points.enumerated() { i == 0 ? path.move(to: p) : path.addLine(to: p) }
                }
                .stroke(palette.surfaceBorder, style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [4, 6]))
                Path { path in
                    for (i, p) in points.prefix(active + 1).enumerated() { i == 0 ? path.move(to: p) : path.addLine(to: p) }
                }
                .stroke(LinearGradient(colors: [Color(hex: 0x916FFF), Color(hex: 0x5FD5E1), Color(hex: 0xED72BA)], startPoint: .leading, endPoint: .trailing), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                .shadow(color: Color(hex: 0x916FFF), radius: 4)

                ForEach(Array(journey.enumerated()), id: \.offset) { index, genre in
                    Button { active = index; momentsOpen = false } label: {
                        VStack(spacing: 3) {
                            Text(genre.symbol)
                                .font(.system(size: 13, weight: .bold)).foregroundStyle(.white)
                                .frame(width: active == index ? 34 : 28, height: active == index ? 34 : 28)
                                .background(genre.summaryAccent.opacity(active == index ? 1 : 0.55), in: Circle())
                                .shadow(color: genre.summaryAccent.opacity(active == index ? 0.9 : 0), radius: 10)
                            Text("Ch. \(index + 1)").font(.system(size: 9)).foregroundStyle(palette.faint)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Open chapter \(index + 1) summary")
                    .position(x: points[index].x, y: points[index].y + 8)
                }
            }
        }
        .frame(height: 80)
    }
}

// MARK: - Journey screen

struct JourneyScreen: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var palette

    var body: some View {
        ScreenScroll {
            TopBar(title: "Story journey", onBack: { app.go(app.journeyBack) })
            VStack(alignment: .leading, spacing: 10) {
                Eyebrow(text: "The path you created")
                GradientHeading(line1: "Every choice left", line2: "a mark.")
                Text("Here’s the story only you could create.").font(Theme.body(14)).foregroundStyle(palette.muted)
            }
            .padding(.vertical, 20)

            StoryJourneyView(journey: app.journey)
                .padding(16)
                .glassCard()

            if app.journeyCompleted {
                VStack(spacing: 12) {
                    Label("Saved to Library", systemImage: "checkmark")
                        .font(Theme.body(12, .semibold)).foregroundStyle(Genre.fantasy.accent)
                    ShareLink(item: StoryCardRenderer.render(journey: app.journey), preview: SharePreview("My Story Pills journey", image: StoryCardRenderer.render(journey: app.journey))) {
                        PrimaryLabel(title: "Share My Story", systemImage: "sparkles")
                    }
                    .buttonStyle(.primary)
                    Button(action: app.restart) { Text("Start a New Story") }
                        .buttonStyle(.secondary)
                }
                .padding(.top, 20)
            }
        }
    }
}

// MARK: - Shareable story card (replaces the <canvas> renderer)

struct StoryCardView: View {
    let journey: [Genre]

    var body: some View {
        let dna = StoryDNA(journey: journey)
        ZStack(alignment: .topLeading) {
            LinearGradient(colors: [Color(hex: 0x111C45), Color(hex: 0x18143B), Color(hex: 0x080B1C)], startPoint: .topLeading, endPoint: .bottomTrailing)
            RadialGradient(colors: [Color(hex: 0x53D6EB, opacity: 0.5), Color(hex: 0x6B59DC, opacity: 0.3), .clear], center: UnitPoint(x: 0.8, y: 0.15), startRadius: 10, endRadius: 600)
            VStack(alignment: .leading, spacing: 0) {
                Text("STORY PILLS · MY STORY CONSTELLATION").font(.system(size: 28, weight: .semibold)).tracking(5).foregroundStyle(Color(hex: 0xAABAFF))
                Text("The Door Without\na Shadow").font(.system(size: 76, weight: .bold)).foregroundStyle(Color(hex: 0xF5F7FF)).padding(.top, 40)
                Text("A story shaped by every choice.").font(.system(size: 31)).foregroundStyle(Color(hex: 0x9EA7C1)).padding(.top, 16)

                HStack(spacing: 0) {
                    ForEach(Array(journey.enumerated()), id: \.offset) { index, genre in
                        VStack(spacing: 14) {
                            Text("\(index + 1)").font(.system(size: 28, weight: .bold)).foregroundStyle(.white)
                                .frame(width: 76, height: 76).background(genre.summaryAccent, in: Circle())
                                .shadow(color: genre.summaryAccent, radius: 20)
                            Text(genre.name.uppercased()).font(.system(size: 20, weight: .semibold)).foregroundStyle(Color(hex: 0x8790AB))
                        }
                        .offset(y: index % 2 == 0 ? 0 : 100)
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 110)

                Text("YOUR STORY DNA").font(.system(size: 22, weight: .semibold)).foregroundStyle(Color(hex: 0x8994B0)).padding(.top, 170)
                GeometryReader { geo in
                    HStack(spacing: 0) {
                        ForEach(dna.segments) { segment in
                            Rectangle().fill(segment.genre.summaryAccent).frame(width: geo.size.width * CGFloat(segment.percentage) / 100)
                        }
                    }
                }
                .frame(height: 24).padding(.top, 20)
                Text(dna.title).font(.system(size: 49, weight: .bold)).foregroundStyle(Color(hex: 0xF5F7FF)).padding(.top, 70)
                Text(dna.description).font(.system(size: 27)).foregroundStyle(Color(hex: 0x9EA7C1)).padding(.top, 16)
                Spacer()
                Text("story pills").font(.system(size: 33, weight: .bold)).foregroundStyle(Color(hex: 0xEEF4FF))
                Text("Your story. Your choices.").font(.system(size: 23)).foregroundStyle(Color(hex: 0x8792AF)).padding(.top, 6)
            }
            .padding(.horizontal, 122)
            .padding(.top, 380)
            .padding(.bottom, 120)
        }
        .frame(width: 1080, height: 1920)
    }
}

@MainActor
enum StoryCardRenderer {
    static func render(journey: [Genre]) -> Image {
        let renderer = ImageRenderer(content: StoryCardView(journey: journey))
        renderer.scale = 1
        #if os(iOS)
        if let image = renderer.uiImage { return Image(uiImage: image) }
        #else
        if let image = renderer.nsImage { return Image(nsImage: image) }
        #endif
        return Image(systemName: "sparkles")
    }
}
