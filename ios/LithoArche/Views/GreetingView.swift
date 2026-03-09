import SwiftUI
import SwiftData

// MARK: - Screen 2: ルーフェンの出迎え (Lufen's Greeting)

struct GreetingView: View {

    @Bindable var profile: UserProfile
    @Environment(\.modelContext) private var context

    var onBeginJourney: () -> Void   // → Chapter 1 (初回)
    var onEnterSanctuary: () -> Void // → Screen 3 聖域の広間（2回目以降）

    // ── 表示フェーズ ────────────────────────────────
    private enum Phase { case appearing, greeting, ready }
    @State private var phase: Phase = .appearing

    // ── ルーフェンのフィギュア ──────────────────────
    @State private var figureOpacity:  Double  = 0
    @State private var figureOffset:   CGFloat = 30
    @State private var floatOffset:    CGFloat = 0     // 浮遊アニメ

    // ── テキスト ────────────────────────────────────
    @State private var displayedLines: [String] = []
    @State private var currentLine = 0
    @State private var lineTimer: Timer? = nil

    // ── ボタン ──────────────────────────────────────
    @State private var buttonOpacity:  Double  = 0
    @State private var buttonGlow:     Double  = 0
    @State private var stonePulse:     Bool    = false
    @State private var isTransitioning = false

    private var isFirstTime: Bool { !profile.hasCompletedOnboarding }

    // 挨拶テキスト（初回 / リピート）
    private var greetingLines: [String] {
        isFirstTime ? [
            "……あなたが来てくれました。",
            "私はルーフェン。Litho-Archeの主席記録官です。",
            "ここは、まだ言葉にならなかった想いを\n記録する場所。",
            "あなたの旅を、始めましょう。"
        ] : [
            "おかえりなさい。",
            "記録庫は、いつもここにあります。",
        ]
    }

    private var buttonLabel: String {
        isFirstTime ? "旅を始める" : "聖域へ戻る"
    }

    var body: some View {
        ZStack {
            // ── 背景 ───────────────────────────────
            Color(hex: "07091A").ignoresSafeArea()

            // 足元の光溜まり（霧の残滓）
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "1A2A4A").opacity(0.5), .clear],
                        center: .center,
                        startRadius: 0, endRadius: 260
                    )
                )
                .frame(width: 520, height: 180)
                .blur(radius: 30)
                .offset(y: 260)

            // ── ルーフェンのフィギュア ──────────────
            RuufenFigureView(floatOffset: floatOffset)
                .opacity(figureOpacity)
                .offset(y: figureOffset)
                .frame(maxHeight: .infinity, alignment: .center)
                .offset(y: -40)

            // ── テキスト + ボタン ───────────────────
            VStack(spacing: 0) {
                Spacer()

                // 挨拶テキストエリア
                greetingTextArea
                    .padding(.horizontal, 40)
                    .padding(.bottom, 48)

                // 発光する石のボタン
                glowingStoneButton
                    .opacity(buttonOpacity)
                    .padding(.bottom, 60)
            }
        }
        .onAppear(perform: startSequence)
    }

    // MARK: - 挨拶テキスト

    private var greetingTextArea: some View {
        VStack(alignment: .center, spacing: 14) {
            ForEach(Array(displayedLines.enumerated()), id: \.offset) { _, line in
                Text(line)
                    .font(.system(size: 16, weight: .thin, design: .serif))
                    .foregroundStyle(Color(hex: "C8D8F0"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .offset(y: 8)),
                            removal:   .opacity
                        )
                    )
            }

            // タイピングカーソル（まだ書いている最中）
            if phase == .greeting {
                HStack(spacing: 0) {
                    BlinkingCursorView(color: Color(hex: "3A6B9E"))
                }
                .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.5), value: displayedLines.count)
    }

    // MARK: - 発光する石ボタン

    private var glowingStoneButton: some View {
        Button(action: handleButtonTap) {
            ZStack {
                // 外側のグロー
                DiamondShape()
                    .fill(Color(hex: "3A6B9E").opacity(buttonGlow * 0.35))
                    .frame(width: stonePulse ? 72 : 64, height: stonePulse ? 72 : 64)
                    .blur(radius: 12)
                    .animation(
                        .easeInOut(duration: 1.8).repeatForever(autoreverses: true),
                        value: stonePulse
                    )

                // 石本体
                DiamondShape()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "4A8AB0"),
                                Color(hex: "2A5A80"),
                                Color(hex: "1A3A5A")
                            ],
                            startPoint: .topLeading,
                            endPoint:   .bottomTrailing
                        )
                    )
                    .overlay(
                        DiamondShape()
                            .stroke(
                                LinearGradient(
                                    colors: [Color(hex: "8AB8D8"), Color(hex: "2A6A9E")],
                                    startPoint: .top, endPoint: .bottom
                                ),
                                lineWidth: 1
                            )
                    )
                    .frame(width: 48, height: 48)
                    .shadow(color: Color(hex: "3A6B9E").opacity(buttonGlow * 0.8), radius: 16)

                // 石の内部光
                DiamondShape()
                    .fill(Color(hex: "C8E8FF").opacity(0.25 + buttonGlow * 0.15))
                    .frame(width: 24, height: 24)
                    .blur(radius: 4)
            }
            .frame(width: 80, height: 80)

            // ラベル
            Text(buttonLabel)
                .font(.system(size: 14, weight: .light, design: .serif))
                .foregroundStyle(Color(hex: "A0C0E0"))
                .tracking(2)
                .padding(.top, 4)
        }
        .buttonStyle(.plain)
        .disabled(isTransitioning)
    }

    // MARK: - アニメーション シーケンス

    private func startSequence() {
        // 1. ルーフェン登場
        withAnimation(.easeOut(duration: 1.4).delay(0.2)) {
            figureOpacity = 1.0
            figureOffset  = 0
        }

        // 2. 浮遊ループ開始
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                floatOffset = -10
            }
        }

        // 3. テキスト逐次表示
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            phase = .greeting
            showNextLine()
        }
    }

    private func showNextLine() {
        guard currentLine < greetingLines.count else {
            // 全行表示完了
            phase = .ready
            lineTimer = nil
            showButton()
            return
        }

        let delay: TimeInterval = currentLine == 0 ? 0 : 1.6

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation {
                displayedLines.append(greetingLines[currentLine])
            }
            currentLine += 1
            showNextLine()
        }
    }

    private func showButton() {
        withAnimation(.easeIn(duration: 0.8).delay(0.4)) { buttonOpacity = 1.0 }
        withAnimation(.easeIn(duration: 1.2).delay(0.6)) { buttonGlow    = 1.0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { stonePulse = true }
    }

    // MARK: - ボタンタップ

    private func handleButtonTap() {
        guard !isTransitioning else { return }
        isTransitioning = true

        // ボタンとルーフェンをフェードアウト
        withAnimation(.easeOut(duration: 0.5)) {
            buttonOpacity  = 0
            figureOpacity  = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            if isFirstTime {
                onBeginJourney()
            } else {
                onEnterSanctuary()
            }
        }
    }
}

// MARK: - ルーフェンのフィギュー（コード描画）

private struct RuufenFigureView: View {
    var floatOffset: CGFloat

    @State private var mantleStars: [MantieStar] = []
    @State private var stoneGlow: Double = 0

    struct MantieStar: Identifiable {
        let id = UUID()
        var x, y:    CGFloat
        var size:    CGFloat
        var opacity: Double
        var phase:   Double
    }

    var body: some View {
        ZStack(alignment: .top) {

            // ── オーラ（背後の光） ─────────────────────
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "3A6B9E").opacity(0.20),
                            Color(hex: "6A3A8A").opacity(0.08),
                            .clear
                        ],
                        center: .center, startRadius: 20, endRadius: 160
                    )
                )
                .frame(width: 320, height: 420)
                .blur(radius: 30)

            // ── マント（星空） ─────────────────────────
            Canvas { ctx, size in
                // マントのシルエット（左右に広がる曲線）
                var mantlePath = Path()
                let cx = size.width / 2
                let top: CGFloat = 70       // 肩の位置
                let bottom: CGFloat = size.height - 10

                mantlePath.move(to: CGPoint(x: cx, y: top))
                mantlePath.addCurve(
                    to: CGPoint(x: cx - 130, y: bottom),
                    control1: CGPoint(x: cx - 60,  y: top + 60),
                    control2: CGPoint(x: cx - 140, y: bottom - 120)
                )
                mantlePath.addCurve(
                    to: CGPoint(x: cx + 130, y: bottom),
                    control1: CGPoint(x: cx - 80,  y: bottom + 20),
                    control2: CGPoint(x: cx + 80,  y: bottom + 20)
                )
                mantlePath.addCurve(
                    to: CGPoint(x: cx, y: top),
                    control1: CGPoint(x: cx + 140, y: bottom - 120),
                    control2: CGPoint(x: cx + 60,  y: top + 60)
                )

                ctx.fill(mantlePath,
                         with: .color(Color(red: 0.04, green: 0.05, blue: 0.14).opacity(0.92)))
                ctx.stroke(mantlePath,
                           with: .color(Color(hex: "2A3A5A").opacity(0.6)),
                           lineWidth: 0.8)
            }
            .frame(width: 280, height: 340)
            .offset(y: 90)

            // ── 星屑（マント内） ───────────────────────
            TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { tl in
                Canvas { ctx, size in
                    let t = tl.date.timeIntervalSinceReferenceDate
                    for star in mantleStars {
                        let twinkle = (sin(t * 1.2 + star.phase) + 1.0) * 0.5
                        let opacity = star.opacity * (0.4 + twinkle * 0.6)
                        let rect = CGRect(
                            x: star.x - star.size / 2,
                            y: star.y - star.size / 2,
                            width: star.size, height: star.size
                        )
                        ctx.fill(Path(ellipseIn: rect),
                                 with: .color(Color(hex: "C8D8F0").opacity(opacity)))
                    }
                }
            }
            .frame(width: 280, height: 340)
            .offset(y: 90)
            .clipShape(
                // マントの内側にクリップ
                MantleClipShape()
            )

            // ── 体のシルエット ─────────────────────────
            RuufenBodyShape()
                .fill(Color(hex: "141220"))
                .overlay(
                    RuufenBodyShape()
                        .stroke(Color(hex: "3A3850").opacity(0.5), lineWidth: 0.8)
                )
                .frame(width: 60, height: 160)
                .offset(y: 70)

            // ── 頭部 ───────────────────────────────────
            ZStack {
                // 頭のオーラ
                Circle()
                    .fill(Color(hex: "3A6B9E").opacity(0.12))
                    .frame(width: 80, height: 80)
                    .blur(radius: 16)

                // 頭のシルエット
                Circle()
                    .fill(Color(hex: "141220"))
                    .overlay(Circle().stroke(Color(hex: "3A3850").opacity(0.4), lineWidth: 0.8))
                    .frame(width: 46, height: 46)
            }
            .offset(y: 20)

            // ── フローライト石（胸の光） ────────────────
            ZStack {
                // グロー
                Circle()
                    .fill(Color(hex: "3A6B9E").opacity(0.5 + stoneGlow * 0.3))
                    .frame(width: 20, height: 20)
                    .blur(radius: 8)

                // 石本体
                DiamondShape()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "8AB8D8"), Color(hex: "2A5A80")],
                            center: .center, startRadius: 0, endRadius: 8
                        )
                    )
                    .frame(width: 10, height: 10)
            }
            .offset(y: 118)
        }
        .offset(y: floatOffset)
        .onAppear {
            generateStars()
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                stoneGlow = 1.0
            }
        }
    }

    private func generateStars() {
        mantleStars = (0..<60).map { _ in
            MantieStar(
                x:       CGFloat.random(in: 20...260),
                y:       CGFloat.random(in: 10...320),
                size:    CGFloat.random(in: 0.8...2.4),
                opacity: Double.random(in: 0.3...0.9),
                phase:   Double.random(in: 0...(.pi * 2))
            )
        }
    }
}

// MARK: - 形状定義

/// ルーフェンの体のシルエット（細長い台形）
private struct RuufenBodyShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to:    CGPoint(x: rect.width * 0.35, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.width * 0.65, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.width * 0.58, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.width * 0.42, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

/// マントのクリッピング形状
private struct MantleClipShape: Shape {
    func path(in rect: CGRect) -> Path {
        let cx = rect.width / 2
        let top: CGFloat    = 0
        let bottom: CGFloat = rect.height
        var p = Path()
        p.move(to: CGPoint(x: cx, y: top))
        p.addCurve(
            to:       CGPoint(x: cx - 130, y: bottom),
            control1: CGPoint(x: cx - 60,  y: top + 60),
            control2: CGPoint(x: cx - 140, y: bottom - 120)
        )
        p.addCurve(
            to:       CGPoint(x: cx + 130, y: bottom),
            control1: CGPoint(x: cx - 80,  y: bottom + 20),
            control2: CGPoint(x: cx + 80,  y: bottom + 20)
        )
        p.addCurve(
            to:       CGPoint(x: cx, y: top),
            control1: CGPoint(x: cx + 140, y: bottom - 120),
            control2: CGPoint(x: cx + 60,  y: top + 60)
        )
        return p
    }
}

/// ダイヤモンド（フローライト石）形状
struct DiamondShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to:    CGPoint(x: rect.midX,  y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX,  y: rect.midY))
        p.addLine(to: CGPoint(x: rect.midX,  y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX,  y: rect.midY))
        p.closeSubpath()
        return p
    }
}

// MARK: - 点滅カーソル

private struct BlinkingCursorView: View {
    let color: Color
    @State private var visible = true

    var body: some View {
        Rectangle()
            .fill(color.opacity(0.7))
            .frame(width: 1.5, height: 18)
            .opacity(visible ? 1 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.55).repeatForever(autoreverses: true)) {
                    visible = false
                }
            }
    }
}

#Preview {
    GreetingView(
        profile: UserProfile(magicWord: "しずか"),
        onBeginJourney: {},
        onEnterSanctuary: {}
    )
    .modelContainer(for: UserProfile.self, inMemory: true)
}
