import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var palette
    let step: Int
    @State private var activePill = "purple"

    private var content: (title: String, subtitle: String, action: String) {
        switch step {
        case 1: ("Your story. Your rules.", "Step into a world where every choice changes what happens next.", "Get Started")
        case 2: ("One pill. A new possibility.", "Mystery, romance, or something unexpected? Choose a pill and shape what happens next.", "Next")
        default: ("No two stories unfold the same.", "Watch your choices become a story that's uniquely yours. Save your journey and revisit it anytime.", "Create My Account")
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { app.go(.onboarding(step - 1)) } label: {
                    Label("Back", systemImage: "chevron.left").font(Theme.body(14, .semibold))
                }
                .disabled(step == 1)
                .opacity(step == 1 ? 0.35 : 1)
                Spacer()
                LogoView(compact: true)
                Spacer()
                Button("Skip") { app.openAuth(.login) }.font(Theme.body(14, .semibold))
            }
            .foregroundStyle(palette.text)
            .buttonStyle(.plain)
            .padding(.top, 8)

            Spacer(minLength: 12)
            visual.frame(height: 300)
            Spacer(minLength: 12)

            VStack(alignment: .leading, spacing: 12) {
                Eyebrow(text: "Discover · 0\(step)")
                Text(content.title)
                    .font(Theme.heading(33))
                    .tracking(-1.2)
                    .foregroundStyle(palette.text)
                Text(content.subtitle)
                    .font(Theme.body(15))
                    .foregroundStyle(palette.muted)
                    .lineSpacing(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .id(step)
            .transition(.opacity.combined(with: .move(edge: .bottom)))

            HStack(spacing: 18) {
                HStack(spacing: 6) {
                    ForEach(1...3, id: \.self) { dot in
                        Capsule()
                            .fill(dot <= step ? Theme.lilac : Color.white.opacity(0.18))
                            .frame(width: dot == step ? 22 : 7, height: 7)
                    }
                }
                .accessibilityLabel("Onboarding step \(step) of 3")
                Button {
                    if step < 3 { app.go(.onboarding(step + 1)) } else { app.openAuth(.signup) }
                } label: { PrimaryLabel(title: content.action) }
                .buttonStyle(.primary)
            }
            .padding(.top, 28)
            .padding(.bottom, 12)
        }
        .padding(.horizontal, 22)
        .background(alignment: .top) {
            Circle()
                .fill(auraColor.opacity(0.35))
                .frame(width: 380)
                .blur(radius: 90)
                .offset(y: 40)
                .animation(.easeInOut(duration: 0.5), value: activePill)
        }
    }

    private var auraColor: Color {
        switch activePill {
        case "pink": Genre.romance.accent
        case "blue": Genre.horror.accent
        default: Theme.violet
        }
    }

    @ViewBuilder private var visual: some View {
        switch step {
        case 1:
            ZStack {
                Image(systemName: "book.pages.fill")
                    .font(.system(size: 130, weight: .thin))
                    .foregroundStyle(LinearGradient(colors: [Color(hex: 0x86DCF3), Color(hex: 0xA798FF), Color(hex: 0xEE83CE)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .shadow(color: Theme.violet.opacity(0.7), radius: 30)
                ForEach(0..<6, id: \.self) { i in
                    Text("✦")
                        .font(.system(size: CGFloat(10 + i * 2)))
                        .foregroundStyle(.white.opacity(0.7))
                        .offset(x: CGFloat([-110, 90, -70, 120, -20, 60][i]), y: CGFloat([-90, -110, 80, 40, -140, 110][i]))
                }
            }
        case 2:
            HStack(spacing: 14) {
                ForEach([("pink", "Romance", "♡", Genre.romance.accent), ("blue", "Mystery", "?", Genre.horror.accent), ("purple", "Unexpected", "✦", Theme.violet)], id: \.0) { pill in
                    let active = activePill == pill.0
                    Button { withAnimation(.spring) { activePill = pill.0 } } label: {
                        VStack(spacing: 10) {
                            Text(pill.2)
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 70, height: 150)
                                .background(LinearGradient(colors: [pill.3.opacity(0.7), pill.3], startPoint: .top, endPoint: .bottom), in: Capsule())
                                .overlay(Capsule().stroke(.white.opacity(active ? 0.6 : 0.15), lineWidth: 1.5))
                                .shadow(color: pill.3.opacity(active ? 0.8 : 0.2), radius: active ? 24 : 8)
                            Text(pill.1).font(Theme.body(12, .semibold)).foregroundStyle(palette.muted)
                        }
                        .scaleEffect(active ? 1.08 : 0.94)
                        .offset(y: active ? -10 : 0)
                    }
                    .buttonStyle(.plain)
                }
            }
        default:
            ZStack {
                Path { p in
                    p.move(to: CGPoint(x: 48, y: 201))
                    p.addCurve(to: CGPoint(x: 118, y: 135), control1: CGPoint(x: 18, y: 159), control2: CGPoint(x: 61, y: 127))
                    p.addCurve(to: CGPoint(x: 220, y: 88), control1: CGPoint(x: 177, y: 143), control2: CGPoint(x: 241, y: 135))
                    p.addCurve(to: CGPoint(x: 275, y: 31), control1: CGPoint(x: 201, y: 46), control2: CGPoint(x: 229, y: 25))
                }
                .stroke(LinearGradient(colors: [Color(hex: 0x5ED6F1), Color(hex: 0x8B7AEE), Color(hex: 0xEE83CE)], startPoint: .bottomLeading, endPoint: .topTrailing), style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [2, 8]))
                .shadow(color: Color(hex: 0x8B7AEE), radius: 6)
                ForEach(Array([("01", "Mystery", CGPoint(x: 48, y: 201)), ("02", "Romance", CGPoint(x: 118, y: 135)), ("03", "Horror", CGPoint(x: 220, y: 88)), ("04", "Your ending", CGPoint(x: 275, y: 31))].enumerated()), id: \.offset) { _, orb in
                    VStack(spacing: 4) {
                        Text(orb.0)
                            .font(Theme.heading(12, .bold))
                            .foregroundStyle(.white)
                            .frame(width: 38, height: 38)
                            .background(LinearGradient(colors: [Color(hex: 0x8B7AEE), Color(hex: 0x5ED6F1)], startPoint: .topLeading, endPoint: .bottomTrailing), in: Circle())
                            .shadow(color: Color(hex: 0x8B7AEE), radius: 10)
                        Text(orb.1).font(.system(size: 10, weight: .semibold)).foregroundStyle(palette.muted)
                    }
                    .position(x: orb.2.x, y: orb.2.y + 12)
                }
            }
            .frame(width: 320, height: 240)
        }
    }
}

// MARK: - Auth

struct AuthView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var palette

    @State private var mode: AuthMode
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var errors: [String: String] = [:]
    @State private var loading = false
    @State private var sent = false

    init(initialMode: AuthMode) {
        _mode = State(initialValue: initialMode)
    }

    private var heading: (eyebrow: String, title: String, subtitle: String) {
        switch mode {
        case .signup: ("Begin your journey", "Create your account", "Save every world you create and every path you choose.")
        case .login: ("Welcome back", "Return to your stories", "Your stories are waiting exactly where you left them.")
        case .forgot: ("Account recovery", "Reset your password", "We'll send a secure reset link to your email.")
        }
    }

    var body: some View {
        ScreenScroll {
            TopBar(onBack: { app.go(.onboarding(3)) })

            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: mode == .forgot ? "sparkles" : "person")
                    .font(.system(size: 21))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(Theme.primaryGradient, in: RoundedRectangle(cornerRadius: 17))
                    .padding(.bottom, 6)
                Eyebrow(text: heading.eyebrow)
                Text(heading.title).font(Theme.heading(30)).tracking(-1).foregroundStyle(palette.text)
                Text(heading.subtitle).font(Theme.body(14)).foregroundStyle(palette.muted)
            }
            .padding(.vertical, 20)

            if sent {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(Genre.fantasy.accent, in: Circle())
                    Text("Check your inbox").font(Theme.heading(18, .bold)).foregroundStyle(palette.text)
                    (Text("A reset link was sent to ") + Text(email).bold() + Text("."))
                        .font(Theme.body(14)).foregroundStyle(palette.muted)
                    Button { switchMode(.login) } label: { PrimaryLabel(title: "Back to Log In") }
                        .buttonStyle(.primary)
                }
                .padding(20)
                .glassCard()
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    if mode == .signup {
                        field("Name", key: "name", icon: "person") {
                            TextField("Alex Morgan", text: $name).textContentType(.name)
                        }
                    }
                    field("Email", key: "email", icon: "at") {
                        TextField("you@example.com", text: $email)
                            .textContentType(.emailAddress)
                            .autocorrectionDisabled()
                            #if os(iOS)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            #endif
                    }
                    if mode != .forgot {
                        field("Password", key: "password", icon: "lock") {
                            HStack {
                                Group {
                                    if showPassword { TextField("At least 8 characters", text: $password) }
                                    else { SecureField("At least 8 characters", text: $password) }
                                }
                                .textContentType(mode == .signup ? .newPassword : .password)
                                Button(showPassword ? "Hide" : "Show") { showPassword.toggle() }
                                    .font(Theme.body(12, .semibold))
                                    .foregroundStyle(Theme.lilac)
                            }
                        }
                    }
                    if mode == .login {
                        Button("Forgot Password?") { switchMode(.forgot) }
                            .font(Theme.body(13, .semibold))
                            .foregroundStyle(Theme.lilac)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    Button(action: submit) {
                        HStack {
                            Text(loading ? "Opening your story…" : mode == .signup ? "Create Account" : mode == .login ? "Log In" : "Send Reset Link")
                            Spacer()
                            Group {
                                if loading { ProgressView().tint(.white) } else { Image(systemName: "arrow.right") }
                            }
                            .frame(width: 34, height: 34)
                            .background(Color.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.leading, 22).padding(.trailing, 11)
                    }
                    .buttonStyle(.primary)
                    .disabled(loading)
                    .padding(.top, 4)
                }
                .buttonStyle(.plain)
            }

            Group {
                if !sent && mode != .forgot {
                    HStack(spacing: 4) {
                        Text(mode == .signup ? "Already have an account?" : "New to Story Pills?").foregroundStyle(palette.muted)
                        Button(mode == .signup ? "Log In" : "Sign Up") { switchMode(mode == .signup ? .login : .signup) }
                            .foregroundStyle(Theme.lilac).fontWeight(.semibold)
                    }
                } else if !sent {
                    Button("Return to Log In") { switchMode(.login) }.foregroundStyle(Theme.lilac)
                }
            }
            .font(Theme.body(14))
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
            .padding(.top, 22)

            Text("Your password is used only to simulate authentication and is never stored.")
                .font(Theme.body(11))
                .foregroundStyle(palette.faint)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 14)
        }
        .background(alignment: .topTrailing) {
            Circle().fill(Theme.violet.opacity(0.25)).frame(width: 300).blur(radius: 80).offset(x: 80, y: -60)
        }
    }

    private func field<Content: View>(_ label: String, key: String, icon: String, @ViewBuilder input: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(label).font(Theme.body(13, .semibold)).foregroundStyle(palette.muted)
            HStack(spacing: 10) {
                Image(systemName: icon).foregroundStyle(palette.muted).frame(width: 18)
                input()
                    .font(Theme.body(15))
                    .foregroundStyle(palette.text)
            }
            .padding(.horizontal, 14)
            .frame(height: 52)
            .glassCard(cornerRadius: 16, tint: errors[key] != nil ? .red : nil, selected: errors[key] != nil)
            if let error = errors[key] {
                Text(error).font(Theme.body(12)).foregroundStyle(Color(hex: 0xFF7A9A))
            }
        }
    }

    private func switchMode(_ next: AuthMode) {
        withAnimation {
            mode = next
            errors = [:]
            sent = false
        }
    }

    private func submit() {
        var next: [String: String] = [:]
        if mode == .signup && name.trimmingCharacters(in: .whitespaces).count < 2 { next["name"] = "Enter your name." }
        if email.range(of: #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#, options: .regularExpression) == nil { next["email"] = "Enter a valid email address." }
        if mode != .forgot && password.count < 8 { next["password"] = "Use at least 8 characters." }
        if mode == .signup && email.lowercased() == "taken@example.com" { next["email"] = "An account already uses this email." }
        withAnimation { errors = next }
        guard next.isEmpty else { return }
        loading = true
        Task {
            try? await Task.sleep(nanoseconds: 720_000_000)
            loading = false
            if mode == .forgot {
                withAnimation { sent = true }
            } else {
                app.authenticate(UserProfile(name: mode == .signup ? name.trimmingCharacters(in: .whitespaces) : "Alex", email: email.lowercased()))
            }
        }
    }
}
