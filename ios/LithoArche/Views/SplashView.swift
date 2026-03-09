import SwiftUI

// MARK: - 起動スプラッシュ画面

struct SplashView: View {

    var onFinished: () -> Void

    @State private var logoOpacity: Double  = 0
    @State private var logoScale:   CGFloat = 0.90
    @State private var glowOpacity: Double  = 0
    @State private var coverOpacity: Double = 0

    var body: some View {
        ZStack {
            // 白背景（ロゴに合わせて）
            Color(red: 0.97, green: 0.96, blue: 0.94)
                .ignoresSafeArea()

            // ロゴ下グロー
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [Color(red: 0.3, green: 0.45, blue: 0.75).opacity(0.25), .clear],
                        center: .center, startRadius: 0, endRadius: 200
                    )
                )
                .frame(width: 400, height: 160)
                .blur(radius: 30)
                .opacity(glowOpacity)
                .offset(y: 20)

            // ロゴ画像
            Image("litho_arche_logo.png")
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 32)
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

            // 暗転カバー（遷移用）
            Color(red: 0.024, green: 0.027, blue: 0.098)
                .ignoresSafeArea()
                .opacity(coverOpacity)
        }
        .onAppear(perform: startSequence)
    }

    private func startSequence() {
        // ロゴフェードイン
        withAnimation(.easeOut(duration: 1.6).delay(0.3)) {
            logoOpacity = 1.0
            logoScale   = 1.0
        }
        withAnimation(.easeOut(duration: 1.8).delay(0.6)) {
            glowOpacity = 1.0
        }

        // 暗転して次の画面へ
        withAnimation(.easeIn(duration: 1.0).delay(3.0)) {
            coverOpacity = 1.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.2) {
            onFinished()
        }
    }
}

#Preview {
    SplashView(onFinished: {})
}
