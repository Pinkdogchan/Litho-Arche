import SwiftUI
import SwiftData

@main
struct LithoArcheApp: App {

    var body: some Scene {
        WindowGroup {
            SplashRootView()
        }
        .modelContainer(for: [
            UserProfile.self,
            DrawingEntry.self,
            SensoryEntry.self,
            LogResponse.self,
            SealedMemory.self,
            HourglassEntry.self,
        ])
    }
}

struct SplashRootView: View {
    @State private var splashDone = false
    @ObservedObject private var bgm = BGMPlayer.shared

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if splashDone {
                TestRootView()
                    .transition(.opacity)
            } else {
                SplashView {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        splashDone = true
                    }
                }
                .transition(.opacity)
            }

            // ── BGMボタン（スプラッシュ後に表示）──────────
            if splashDone {
                BGMToggleButton(bgm: bgm)
                    .padding(.top, 52)
                    .padding(.trailing, 12)
                    .transition(.opacity)
                    .zIndex(999)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: splashDone)
    }
}

struct TestRootView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [UserProfile]

    var body: some View {
        if let profile = profiles.first {
            SanctuaryView(profile: profile)
        } else {
            ZStack {
                Color(hex: "060810").ignoresSafeArea()
                Button {
                    let p = UserProfile(magicWord: "test", sanctuaryName: "テスト聖域")
                    context.insert(p)
                    try? context.save()
                } label: {
                    Text("テスト開始")
                        .foregroundStyle(.white)
                        .padding(20)
                        .background(Color.blue.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
}
