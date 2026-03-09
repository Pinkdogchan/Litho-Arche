import SwiftUI

// MARK: - 断片クリーチャー（モーフィング対応）

/// spikyness: 1.0 = とげとげした暗い断片体  /  0.0 = 滑らかな結晶体（浄化後）
struct FragmentCreatureView: View {

    var spikyness:   CGFloat  // 外部から Binding で操作
    var isPurified:  Bool
    var onPurified:  () -> Void = {}   // 浄化完了コールバック

    // ── アニメーション状態 ──────────────────────────
    @State private var breathScale:    CGFloat = 1.0
    @State private var wobbleAngle:    Double  = 0
    @State private var eyeBlink:       Bool    = false
    @State private var glowIntensity:  Double  = 0

    // ── 浄化パーティクル ─────────────────────────────
    @State private var burstParticles: [BurstParticle] = []
    @State private var burstActive    = false
    @State private var burstProgress: CGFloat = 0

    struct BurstParticle: Identifiable {
        let id    = UUID()
        var angle:  CGFloat
        var speed:  CGFloat
        var size:   CGFloat
        var color:  Color
        var offset: CGFloat = 0
    }

    // クリーチャーの体色（spikyness に応じて変化）
    private var bodyColor: Color {
        Color(
            red:   Double(0.14 + (1 - spikyness) * 0.10),
            green: Double(0.12 + (1 - spikyness) * 0.22),
            blue:  Double(0.20 + (1 - spikyness) * 0.42)
        )
    }
    private var outlineColor: Color {
        spikyness > 0.5
            ? Color(hex: "3A2830").opacity(0.8)
            : Color(hex: "4A8AB0").opacity(0.6 + Double(1 - spikyness) * 0.3)
    }
    private var glowColor: Color {
        spikyness > 0.5
            ? Color(hex: "5A2A30").opacity(0.2)
            : Color(hex: "3A6B9E").opacity(0.4 + Double(1 - spikyness) * 0.5)
    }

    var body: some View {
        ZStack {

            // ── グロー（浄化が進むほど強く） ──────────
            Circle()
                .fill(glowColor)
                .frame(width: 220, height: 220)
                .blur(radius: 40 + CGFloat(1 - spikyness) * 20)
                .scaleEffect(breathScale)

            // ── 浄化バーストパーティクル ───────────────
            if burstActive {
                TimelineView(.animation) { tl in
                    Canvas { ctx, size in
                        let t = CGFloat(tl.date.timeIntervalSinceReferenceDate)
                        for p in burstParticles {
                            let dist = p.speed * burstProgress * 150
                            let x = size.width  / 2 + cos(p.angle) * dist
                            let y = size.height / 2 + sin(p.angle) * dist
                            let fade = max(0, 1 - Double(burstProgress) * 1.2)
                            let rect = CGRect(x: x - p.size/2, y: y - p.size/2,
                                             width: p.size, height: p.size)
                            ctx.fill(Path(ellipseIn: rect),
                                     with: .color(p.color.opacity(fade)))
                            _ = t  // timeline 更新のために参照
                        }
                    }
                }
                .frame(width: 280, height: 280)
                .allowsHitTesting(false)
            }

            // ── クリーチャー本体 ──────────────────────
            ZStack {

                // 本体シェイプ
                CreatureBodyShape(spikyness: spikyness)
                    .fill(bodyColor)
                    .overlay(
                        CreatureBodyShape(spikyness: spikyness)
                            .stroke(outlineColor, lineWidth: 1.2)
                    )
                    .frame(width: 140, height: 140)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6), value: spikyness)

                // 内部の光（浄化後）
                if spikyness < 0.5 {
                    Circle()
                        .fill(Color(hex: "C8E8FF").opacity(Double((0.5 - spikyness) * 2) * 0.2))
                        .frame(width: 80, height: 80)
                        .blur(radius: 12)
                }

                // 目
                CreatureEyes(spikyness: spikyness, blink: eyeBlink)
                    .offset(y: -12)

                // 浄化後：結晶の輝き
                if isPurified {
                    ForEach(0..<6, id: \.self) { i in
                        DiamondShape()
                            .fill(Color(hex: "8ACAE8").opacity(0.6))
                            .frame(width: 8, height: 8)
                            .offset(
                                x: cos(.pi * 2 / 6 * CGFloat(i)) * 55,
                                y: sin(.pi * 2 / 6 * CGFloat(i)) * 55
                            )
                            .blur(radius: 1)
                    }
                }
            }
            .scaleEffect(breathScale)
            .rotationEffect(.degrees(wobbleAngle))
        }
        .onAppear(perform: startIdleAnimations)
        .onChange(of: isPurified) { _, v in if v { triggerBurst() } }
    }

    // MARK: - アイドルアニメーション

    private func startIdleAnimations() {
        // 呼吸
        withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
            breathScale = 1.06
        }
        // 揺れ（spikyな間は荒く、浄化後は穏やかに）
        withAnimation(
            .easeInOut(duration: spikyness > 0.5 ? 0.8 : 2.5)
                .repeatForever(autoreverses: true)
        ) { wobbleAngle = spikyness > 0.5 ? 4 : 1.5 }

        // まばたき
        Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.12)) { eyeBlink = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
                withAnimation(.easeInOut(duration: 0.1)) { eyeBlink = false }
            }
        }

        // グロー
        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
            glowIntensity = 1.0
        }
    }

    // MARK: - 浄化バースト

    private func triggerBurst() {
        burstParticles = (0..<28).map { i in
            let angle = CGFloat(i) / 28 * .pi * 2 + CGFloat.random(in: -0.2...0.2)
            return BurstParticle(
                angle: angle,
                speed: CGFloat.random(in: 0.7...1.3),
                size:  CGFloat.random(in: 4...10),
                color: [
                    Color(hex: "8ACAE8"), Color(hex: "C8D8F0"),
                    Color(hex: "3A6B9E"), Color(hex: "A0C8E8")
                ].randomElement()!
            )
        }
        burstActive = true

        withAnimation(.easeOut(duration: 1.2)) { burstProgress = 1.0 }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            burstActive    = false
            burstProgress  = 0
            onPurified()
        }
    }
}

// MARK: - クリーチャーの体のシェイプ（モーフィング対応）

struct CreatureBodyShape: Shape {
    var spikyness: CGFloat  // 0 = 滑らか / 1 = トゲだらけ

    var animatableData: CGFloat {
        get { spikyness }
        set { spikyness = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let cx       = rect.midX
        let cy       = rect.midY
        let numSpike = 14
        let outer    = min(rect.width, rect.height) * 0.48
        // spikyness が高いほど内側が小さく → トゲが鋭くなる
        let inner    = outer * (1.0 - spikyness * 0.42)
        let step     = CGFloat.pi * 2 / CGFloat(numSpike)

        var points: [CGPoint] = []
        for i in 0..<numSpike * 2 {
            let isOuter = i % 2 == 0
            let angle   = step / 2 * CGFloat(i) - .pi / 2
            // 不規則なノイズ（トゲの揺らぎ）
            let noise: CGFloat = spikyness > 0.05
                ? CGFloat(sin(Double(i) * 2.7) * Double(spikyness) * 0.08)
                : 0
            let r = (isOuter ? outer : inner) * (1 + noise)
            points.append(CGPoint(
                x: cx + r * cos(angle),
                y: cy + r * sin(angle)
            ))
        }

        var p = Path()
        if spikyness < 0.08 {
            // ほぼ円に近い場合はベジェで滑らかに
            p.addEllipse(in: CGRect(
                x: cx - outer, y: cy - outer,
                width: outer * 2, height: outer * 2
            ))
        } else {
            p.move(to: points[0])
            for i in 1..<points.count {
                if spikyness > 0.5 {
                    p.addLine(to: points[i])   // sharp
                } else {
                    // 滑らかになるにつれてベジェ
                    let prev = points[i - 1]
                    let curr = points[i]
                    let mid  = CGPoint(x: (prev.x + curr.x) / 2,
                                       y: (prev.y + curr.y) / 2)
                    p.addQuadCurve(to: mid, control: prev)
                    p.addLine(to: curr)
                }
            }
            p.closeSubpath()
        }
        return p
    }
}

// MARK: - クリーチャーの目

private struct CreatureEyes: View {
    var spikyness: CGFloat
    var blink:     Bool

    // spikyが高い → 細い怒り目 / 低い → 丸い穏やかな目
    private var eyeHeight: CGFloat { blink ? 1 : (2 + (1 - spikyness) * 8) }
    private var eyeColor: Color {
        spikyness > 0.5
            ? Color(hex: "FF6060").opacity(0.9)
            : Color(hex: "C8E8FF").opacity(0.9)
    }
    private var eyeWidth: CGFloat { 6 + (1 - spikyness) * 4 }

    var body: some View {
        HStack(spacing: 18) {
            Ellipse()
                .fill(eyeColor)
                .frame(width: eyeWidth, height: eyeHeight)
            Ellipse()
                .fill(eyeColor)
                .frame(width: eyeWidth, height: eyeHeight)
        }
        .animation(.easeInOut(duration: 0.15), value: blink)
        .animation(.spring(response: 0.6), value: spikyness)
    }
}

#Preview {
    ZStack {
        Color(hex: "07091A").ignoresSafeArea()
        VStack(spacing: 40) {
            FragmentCreatureView(spikyness: 1.0, isPurified: false)
            FragmentCreatureView(spikyness: 0.0, isPurified: true)
        }
    }
}
