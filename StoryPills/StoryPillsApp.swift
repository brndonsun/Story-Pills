import SwiftUI

@main
struct StoryPillsApp: App {
    @StateObject private var app = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(app)
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var app: AppState

    var body: some View {
        let palette = app.lightTheme ? Palette.light : Palette.dark
        ZStack(alignment: .bottom) {
            AppBackground()
            screenView
                .id(app.screen)
                .transition(.opacity.combined(with: .offset(y: 8)))
            if app.screen.showsTabBar {
                BottomNav()
                    .padding(.bottom, 4)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .environment(\.palette, palette)
        .foregroundStyle(palette.text)
        .preferredColorScheme(app.lightTheme ? .light : .dark)
    }

    @ViewBuilder private var screenView: some View {
        switch app.screen {
        case .onboarding(let step): OnboardingView(step: max(1, min(step, 3)))
        case .auth: AuthView(initialMode: app.authMode).id(app.authMode)
        case .home: HomeView()
        case .storyIdea: TopicSelectionView()
        case .storyLength: StoryLengthView()
        case .storyLoading: StoryLoadingView()
        case .reading: ReadingView()
        case .pills: PillSelectionView()
        case .generating: GeneratingView()
        case .ending: EndingView()
        case .library: LibraryView()
        case .details: BookDetailsView()
        case .journey: JourneyScreen()
        case .profile: ProfileView()
        case .community: CommunityView()
        case .communityPreview: CommunityPreviewView()
        }
    }
}

#Preview {
    RootView().environmentObject(AppState())
}
