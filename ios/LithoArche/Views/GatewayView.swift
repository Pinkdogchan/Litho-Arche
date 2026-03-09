import SwiftUI

/// 冒頭ビュー: 深い霧の中から石造りの門が現れる
struct GatewayView: View {
    var onFinished: () -> Void

    // 霧レイヤーのアニメーション状態
    @State private var fogOpacity: Double  = 1.0
    @State private var fogOffset: CGFloat  = 0
    @State private var gateOpacity: Double = 0
    @State private var gateScale: CGFloat  = 0.88
    @State private var titleOpacity: Double = 0
    @State private var hintOpacity: Double  = 0

    var body: some View {
        ZStack {
            // ── 背景: 深宇宙紺 ──────────────────────────
            Color(hex: "080A1A")
                .ignoresSafeArea()

            // ── 石門 ────────────────────────────────────
            StoneGateShape()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "2C2A38"), Color(hex: "1A1825")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    StoneGateShape()
                        .stroke(Color(hex: "4A4560"), lineWidth: 1.5)
                )
                .frame(width: 260, height: 380)
                .scaleEffect(gateScale)
                .opacity(gateOpacity)

            // ── タイトル ─────────────────────────────────
            VStack(spacing: 12) {
                Spacer()
                Text("Litho-Arche")
                    .font(.system(size: 36, weight: .thin, design: .serif))
                    .foregroundStyle(Color(hex: "C8D8F0"))
                    .opacity(titleOpacity)

                Text("深い霧の中へ")
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(Color(hex: "7A8FAA"))
                    .opacity(titleOpacity)

                Spacer().frame(height: 80)

                Text("画面をタップして進む")
                    .font(.system(size: 12, weight: .light))
                    .foregroundStyle(Color(hex: "4A5A6A"))
                    .opacity(hintOpacity)

                Spacer().frame(height: 40)
            }

            // ── 霧レイヤー（複数重ね）───────────────────
            FogLayer(
                color: Color(hex: "0D1830"),
                blurRadius: 40,
                opacity: fogOpacity * 0.9,
                offsetY: fogOffset - 30
            )
            FogLayer(
                color: Color(hex: "121A2E"),
                blurRadius: 60,
                opacity: fogOpacity * 0.7,
                offsetY: fogOffset
            )
            FogLayer(
                color: Color(hex: "0A0F20"),
                blurRadius: 80,
                opacity: fogOpacity * 0.85,
                offsetY: fogOffset + 40
            )
        }
        .onTapGesture(perform: advance)
        .onAppear(perform: startAnimation)
    }

    // MARK: - Animation

    private func startAnimation() {
        // 霧が徐々に晴れて石門が現れる
        withAnimation(.easeInOut(duration: 3.5).delay(0.5)) {
            fogOpacity  = 0.15
            fogOffset   = -60
            gateOpacity = 1.0
            gateScale   = 1.0
        }
        withAnimation(.easeIn(duration: 2.0).delay(2.5)) {
            titleOpacity = 1.0
        }
        withAnimation(.easeIn(duration: 1.5).delay(4.5)) {
            hintOpacity = 1.0
        }
    }

    private func advance() {
        withAnimation(.easeInOut(duration: 0.6)) {
            fogOpacity   = 1.0
            gateOpacity  = 0
            titleOpacity = 0
            hintOpacity  = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            onFinished()
        }
    }
}

// MARK: - 霧レイヤー

private struct FogLayer: View {
    let color: Color
    let blurRadius: CGFloat
    let opacity: Double
    let offsetY: CGFloat

    var body: some View {
        Ellipse()
            .fill(color)
            .frame(width: 700, height: 320)
            .blur(radius: blurRadius)
            .opacity(opacity)
            .offset(y: offsetY)
            .allowsHitTesting(false)
    }
}

// MARK: - 石門 Shape

/// アーチ付き石門をパスで描画
private struct StoneGateShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()

        let pillarW: CGFloat = rect.width * 0.22
        let archH:   CGFloat = rect.height * 0.38
        let baseY:   CGFloat = rect.maxY

        // 左柱
        p.addRect(CGRect(x: rect.minX, y: archH, width: pillarW, height: baseY - archH))
        // 右柱
        p.addRect(CGRect(x: rect.maxX - pillarW, y: archH, width: pillarW, height: baseY - archH))

        // アーチ（半円）
        let archCenter = CGPoint(x: rect.midX, y: archH)
        let archRadius = (rect.width - pillarW * 2) / 2 + pillarW / 2
        p.addArc(center: archCenter,
                 radius: archRadius,
                 startAngle: .degrees(180),
                 endAngle: .degrees(0),
                 clockwise: false)

        // アーチ下部をつなぐ横梁
        p.addRect(CGRect(x: rect.minX, y: archH - 14, width: rect.width, height: 14))

        return p
    }
}

// Color(hex:) は Extensions.swift で定義

#Preview {
    GatewayView(onFinished: {})
}
