# Story Pills iOS app (SwiftUI)

SwiftUI port of the Story Pills Figma Make prototype.

## Run it
1. Install **Xcode 16+** from the Mac App Store and open it once.
2. Open `StoryPills.xcodeproj`.
3. Pick an iPhone simulator at the top of the window and press **Run** (Cmd+R).

To run on a real iPhone, select the target → *Signing & Capabilities* → choose your Team (your Apple ID).

## Project layout
| Folder | What's in it |
| --- | --- |
| `StoryPills/StoryPillsApp.swift` | App entry point + `RootView` (switches between screens) |
| `State/AppState.swift` | All app state and navigation (`Screen` enum), ported from `App.tsx` |
| `Models/` | Data types (`Genre`, `LibraryBook`, …) and mock content in `SampleData` |
| `Theme/` | Colors, fonts, button styles, glass card modifier |
| `Components/` | Shared views: top bar, tab bar, genre cards, capsules, progress |
| `Screens/` | One file per area: onboarding/auth, create flow, reading, journey, library/profile, community |

New `.swift` files placed anywhere inside `StoryPills/` are picked up by Xcode automatically.

## Prototype → SwiftUI mapping
- `useState` in `App` → `@Published` properties on `AppState`
- `setScreen(...)` → `app.go(.screen)`
- `localStorage` → `UserDefaults` / `@AppStorage`
- Comments overlay → native `.sheet` with detents
- Canvas share image → `ImageRenderer` + `ShareLink`

## Not done yet / next steps
- **Fonts:** the web version uses Manrope + DM Sans. Add the `.ttf` files to the project, list them under *Fonts provided by application* in Info, and update `Theme.heading` / `Theme.body`.
- **App icon:** drop a 1024×1024 PNG into `Assets.xcassets/AppIcon`.
- **Real data:** all stories, comments and auth are mocked (same as the prototype). Replace `SampleData` and the fake auth in `AppState.authenticate` with your backend / AI story generation.
- Some decorative CSS animations (book particles, dispenser) are simplified.
