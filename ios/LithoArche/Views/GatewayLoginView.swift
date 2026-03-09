import SwiftUI
import SwiftData

// MARK: - Screen 1: 霧の境界 (The Veil Gate)

struct GatewayLoginView: View {
    var onUnlocked: () -> Void

    @Query private var profiles: [UserProfile]
    @State private var speech = SpeechRecognizer()

    // ── 霧・クリア状態 ──────────────────────────────
    @State private var fogClearProgress: Double = 0      // 0=完全な霧 / 1=完全に晴れた
    @State private var swipeClearZones:  [ClearZone] = []
    @State private var isUnlocking     = false

    // ── マイク長押し ─────────────────────────────────
    @State private var micPressProgress: CGFloat = 0     // 0.0〜1.0
    @State private var micPressTimer:    Timer?   = nil
    @State private var micPressActive             = false

    // ── ゲート演出 ────────────────────────────────────
    @State private var gateOpacity:   Double  = 0.18    // 霧越しのシルエット
    @State private var gateGlow:      Double  = 0
    @State private var lightBloom:    Double  = 0
    @State private var screenFlash:   Double  = 0

    // ── UI ───────────────────────────────────────────
    @State private var hintOpacity:   Double  = 0
    @State private var showDenied             = false

    private var magicWord: String { profiles.first?.magicWord ?? "" }

    // スワイプクリアゾーン
    struct ClearZone: Identifiable {
        let id     = UUID()
        var center: CGPoint
        var radius: CGFloat = 72
    }

    var body: some View {
        ZStack {

            // ── 背景: 深宇宙紺 ─────────────────────────
            Color(hex: "07091A").ignoresSafeArea()

            // ── 石門 (霧の奥で薄く存在) ────────────────
            gateView
                .opacity(gateOpacity)

            // ── 光のブルーム (解錠時) ──────────────────
            RadialGradient(
                colors: [
                    Color(hex: "C8D8F0").opacity(lightBloom * 0.9),
                    Color(hex: "3A6B9E").opacity(lightBloom * 0.4),
                    Color.clear
                ],
                center: .center,
                startRadius: 0,
                endRadius: 420
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            // ── 乳白色の霧パーティクル ─────────────────
            MilkyFogCanvas(
                clearProgress: fogClearProgress,
                clearZones:    swipeClearZones
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            // ── スワイプ受付レイヤー ────────────────────
            Color.clear
                .contentShape(Rectangle())
                .gesture(swipeGesture)
                .ignoresSafeArea()

            // ── UI オーバーレイ ─────────────────────────
            VStack {
                Spacer()
                hintLabel
                micButton
                    .padding(.bottom, 52)
            }
            .opacity(isUnlocking ? 0 : 1)
            .animation(.easeOut(duration: 0.5), value: isUnlocking)

            // ── 白フラッシュ (遷移直前) ─────────────────
            Color.white
                .opacity(screenFlash)
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
        .onAppear(perform: setup)
        .onChange(of: speech.state, handleSpeechState)
        .alert("マイクが使用できません", isPresented: $showDenied) {
            Button("設定を開く") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("設定 › Litho-Arche からマイクと音声認識を許可してください。")
        }
    }

    // MARK: - 石門ビュー

    private var gateView: some View {
        ZStack {
            // ゲートグロー
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "3A6B9E").opacity(0.35 + gateGlow * 0.4),
                            Color.clear
                        ],
                        center: .center, startRadius: 10, endRadius: 180
                    )
                )
                .frame(width: 360, height: 200)
                .blur(radius: 40)
                .offset(y: -20)

            // 石門シェイプ
            StoneGateShape()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "2A2838"), Color(hex: "16141F")],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .overlay(
                    StoneGateShape()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(hex: "5A5070").opacity(0.8 + gateGlow * 0.2),
                                    Color(hex: "3A3850").opacity(0.4)
                                ],
                                startPoint: .top, endPoint: .bottom
                            ),
                            lineWidth: 1.2
                        )
                )
                .shadow(
                    color: Color(hex: "3A6B9E").opacity(gateGlow * 0.6),
                    radius: 24
                )
                .frame(width: 240, height: 360)

            // アーチ内のグロー
            Ellipse()
                .fill(Color(hex: "1A3A5A").opacity(0.3 + gateGlow * 0.5))
                .frame(width: 110, height: 70)
                .blur(radius: 18)
                .offset(y: -65)
        }
    }

    // MARK: - ヒントラベル

    private var hintLabel: some View {
        VStack(spacing: 8) {
            // 音声認識中の書き起こし表示
            if case .listening = speech.state {
                Text(speech.transcript.isEmpty ? "聴いています…" : speech.transcript)
                    .font(.system(size: 13, weight: .light))
                    .foregroundStyle(Color(hex: "7A9ABE"))
                    .lineLimit(1)
                    .transition(.opacity)
            }

            Text(hintText)
                .font(.system(size: 12, weight: .light))
                .foregroundStyle(Color(hex: "3A4A5A"))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .opacity(hintOpacity)
        .padding(.bottom, 20)
        .animation(.easeInOut(duration: 0.3), value: speech.state == .listening)
    }

    private var hintText: String {
        switch speech.state {
        case .listening: return "「\(magicWord)」と唱えてください"
        default:         return "長押しで魔法の言葉を唱える\nまたは画面をなぞって霧を払う"
        }
    }

    // MARK: - マイクボタン (長押し)

    private var micButton: some View {
        ZStack {
            // 外側の長押しプログレスリング
            Circle()
                .trim(from: 0, to: micPressProgress)
                .stroke(
                    Color(hex: "3A6B9E"),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .frame(width: 72, height: 72)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.05), value: micPressProgress)

            // 外側の常駐リング
            Circle()
                .stroke(Color(hex: "1A2A3A"), lineWidth: 1)
                .frame(width: 72, height: 72)

            // 音声認識中のパルスリング
            if case .listening = speech.state {
                Circle()
                    .stroke(Color(hex: "3A6B9E").opacity(0.3), lineWidth: 1)
                    .frame(width: micPressActive ? 90 : 72, height: micPressActive ? 90 : 72)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                               value: micPressActive)
            }

            // ボタン本体
            Circle()
                .fill(micButtonFill)
                .frame(width: 60, height: 60)

            Image(systemName: micIcon)
                .font(.system(size: 22))
                .foregroundStyle(micIconColor)
        }
        .gesture(micLongPressGesture)
        .onTapGesture {
            // タップでも音声認識中なら停止できる
            if case .listening = speech.state { speech.stopListening() }
        }
    }

    private var micButtonFill: Color {
        if case .listening = speech.state { return Color(hex: "0F1E36") }
        return micPressProgress > 0 ? Color(hex: "0C1828") : Color(hex: "080E1C")
    }

    private var micIcon: String {
        switch speech.state {
        case .listening: return "mic.fill"
        case .denied:    return "mic.slash.fill"
        default:         return "mic"
        }
    }

    private var micIconColor: Color {
        switch speech.state {
        case .listening: return Color(hex: "C8D8F0")
        case .denied:    return Color(hex: "8A4A4A")
        default:         return Color(hex: "4A6A8A").opacity(0.6 + Double(micPressProgress) * 0.4)
        }
    }

    // MARK: - ジェスチャー

    /// マイクボタン長押し: 1.2秒で音声認識を起動
    private var micLongPressGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                guard micPressTimer == nil, !(speech.state == .listening) else { return }
                micPressActive = true
                micPressTimer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { t in
                    micPressProgress += 0.04 / 1.2   // 1.2秒で1.0に到達
                    if micPressProgress >= 1.0 {
                        t.invalidate()
                        micPressTimer    = nil
                        micPressProgress = 0
                        activateMic()
                    }
                }
            }
            .onEnded { _ in
                cancelMicPress()
            }
    }

    /// スワイプで霧を払う
    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard !isUnlocking else { return }
                swipeClearZones.append(ClearZone(center: value.location))
                checkSwipeThreshold()
            }
    }

    // MARK: - ロジック

    private func setup() {
        speech.magicWord = magicWord
        speech.requestPermissions()

        // ゲートシルエットをフェードイン
        withAnimation(.easeIn(duration: 2.5).delay(0.3)) { gateOpacity = 0.22 }
        // ヒントを表示
        withAnimation(.easeIn(duration: 1.5).delay(2.0)) { hintOpacity = 1.0 }
    }

    private func activateMic() {
        if case .denied = speech.state { showDenied = true; return }
        speech.startListening()
        micPressActive = true
    }

    private func cancelMicPress() {
        micPressTimer?.invalidate()
        micPressTimer    = nil
        micPressActive   = false
        withAnimation(.easeOut(duration: 0.3)) { micPressProgress = 0 }
    }

    private func handleSpeechState(_ old: SpeechRecognizer.State,
                                   _ new: SpeechRecognizer.State) {
        if case .matched = new { unlock(trigger: "voice") }
        if case .denied  = new { showDenied = true }
    }

    private func checkSwipeThreshold() {
        let screenArea   = Double(UIScreen.main.bounds.width * UIScreen.main.bounds.height)
        let coveredArea  = swipeClearZones.reduce(0.0) {
            $0 + .pi * Double($1.radius * $1.radius)
        }
        if coveredArea / screenArea > 0.38 { unlock(trigger: "swipe") }
    }

    private func unlock(trigger: String) {
        guard !isUnlocking else { return }
        isUnlocking = true
        speech.stopListening()

        let fogDuration:   Double = trigger == "voice" ? 2.0 : 1.2
        let glowDelay:     Double = trigger == "voice" ? 0.3 : 0.1
        let bloomDelay:    Double = fogDuration - 0.2
        let flashDelay:    Double = fogDuration + 0.4
        let transitionDelay: Double = fogDuration + 1.0

        // 霧を消す
        withAnimation(.easeOut(duration: fogDuration)) { fogClearProgress = 1.0 }
        // ゲートを完全表示 + グロー
        withAnimation(.easeIn(duration: 0.8).delay(glowDelay)) {
            gateOpacity = 1.0
            gateGlow    = 1.0
        }
        // 光のブルーム
        withAnimation(.easeIn(duration: 0.6).delay(bloomDelay)) { lightBloom = 0.8 }
        // 白フラッシュ
        withAnimation(.easeInOut(duration: 0.35).delay(flashDelay)) { screenFlash = 1.0 }
        // 遷移
        DispatchQueue.main.asyncAfter(deadline: .now() + transitionDelay) {
            onUnlocked()
        }
    }
}

// MARK: - 乳白色の霧 Canvas

private struct MilkyFogCanvas: View {
    var clearProgress: Double
    var clearZones:    [GatewayLoginView.ClearZone]

    @State private var particles: [FogParticle] = []

    struct FogParticle {
        var x, y:        CGFloat
        var rx, ry:      CGFloat    // 楕円の半径
        var baseOpacity: Double
        var phase:       Double
        var driftX, driftY: CGFloat
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate
                for p in particles {
                    drawFog(ctx: ctx, particle: p, time: t, size: size)
                }
            }
        }
        .onAppear { generate(in: UIScreen.main.bounds.size) }
    }

    private func generate(in size: CGSize) {
        particles = (0..<28).map { _ in
            FogParticle(
                x:           CGFloat.random(in: -120...size.width  + 120),
                y:           CGFloat.random(in: -80 ...size.height + 80),
                rx:          CGFloat.random(in: 100...280),
                ry:          CGFloat.random(in: 60...180),
                baseOpacity: Double.random(in: 0.30...0.60),
                phase:       Double.random(in: 0...(.pi * 2)),
                driftX:      CGFloat.random(in: -8...8),
                driftY:      CGFloat.random(in: -4...4)
            )
        }
    }

    private func drawFog(
        ctx:      GraphicsContext,
        particle: FogParticle,
        time:     TimeInterval,
        size:     CGSize
    ) {
        // 時間ベースのゆっくりした漂い
        let speed: CGFloat = 0.006
        var cx = particle.x + particle.driftX * CGFloat(time) * speed
        var cy = particle.y + particle.driftY * CGFloat(time) * speed

        // 画面端でループ
        let wrapW = size.width  + 240
        let wrapH = size.height + 160
        cx = cx.truncatingRemainder(dividingBy: wrapW)
        cy = cy.truncatingRemainder(dividingBy: wrapH)
        if cx < -120 { cx += wrapW }
        if cy < -80  { cy += wrapH }

        // サイン波で透明度ゆらぎ
        let wave    = (sin(time * 0.25 + particle.phase) + 1.0) * 0.5
        var opacity = particle.baseOpacity * (0.75 + wave * 0.25)

        // スワイプ消去ゾーン
        for zone in clearZones {
            let dist = hypot(cx - zone.center.x, cy - zone.center.y)
            let fall = max(0.0, 1.0 - dist / (Double(zone.radius) * 1.8))
            opacity *= (1.0 - fall * 0.96)
        }

        // グローバルクリア進行
        opacity *= max(0, 1.0 - clearProgress * 1.4)
        guard opacity > 0.01 else { return }

        // 乳白色: 青みがかった白
        let fogColor = Color(
            red:   0.82 + wave * 0.06,
            green: 0.85 + wave * 0.04,
            blue:  0.92 + wave * 0.03
        ).opacity(opacity)

        let rect = CGRect(
            x: cx - particle.rx, y: cy - particle.ry,
            width: particle.rx * 2, height: particle.ry * 2
        )
        ctx.fill(Path(ellipseIn: rect), with: .color(fogColor))
    }
}

// MARK: - 石門 Shape

private struct StoneGateShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let pw: CGFloat = rect.width  * 0.22    // 柱幅
        let ah: CGFloat = rect.height * 0.36    // アーチ高さ

        // 左柱
        p.addRect(CGRect(x: rect.minX, y: ah, width: pw, height: rect.height - ah))
        // 右柱
        p.addRect(CGRect(x: rect.maxX - pw, y: ah, width: pw, height: rect.height - ah))
        // 横梁
        p.addRect(CGRect(x: rect.minX, y: ah - 16, width: rect.width, height: 16))
        // アーチ（半円）
        let ar = (rect.width - pw * 2) * 0.5 + pw * 0.5
        p.addArc(center: CGPoint(x: rect.midX, y: ah),
                 radius: ar,
                 startAngle: .degrees(180), endAngle: .degrees(0),
                 clockwise: false)
        return p
    }
}

// Color(hex:) は Extensions.swift で定義
extension Color {
}

#Preview {
    GatewayLoginView(onUnlocked: {})
        .modelContainer(for: UserProfile.self, inMemory: true)
}
