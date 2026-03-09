import SwiftUI

// MARK: - 霧パーティクル

struct FogParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var radius:   CGFloat
    var baseOpacity: Double
    var phaseOffset: Double   // サイン波のオフセット（個体差）
    var driftAngle: Double    // 流れる方向
    var speed:    CGFloat
}

// MARK: - 霧エフェクト + ジェスチャー消去ビュー

struct FogEffectView: View {

    /// 0.0 (完全に霧) ─ 1.0 (完全に晴れた)
    var clearProgress: Double

    /// スワイプによる消去円のリスト (中心, 半径)
    @Binding var swipeClearZones: [ClearZone]

    struct ClearZone: Identifiable {
        let id = UUID()
        var center: CGPoint
        var radius: CGFloat
        var opacity: Double = 1.0
    }

    // パーティクル配列（起動時に生成）
    @State private var particles: [FogParticle] = []

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate

                for particle in particles {
                    drawFogParticle(
                        context:    context,
                        particle:   particle,
                        time:       t,
                        clearZones: swipeClearZones,
                        globalClear: clearProgress,
                        canvasSize: size
                    )
                }
            }
        }
        .onAppear { generateParticles(in: UIScreen.main.bounds.size) }
        .allowsHitTesting(false) // タッチは親ビューで処理
    }

    // MARK: - Generate

    private func generateParticles(in size: CGSize) {
        particles = (0..<40).map { _ in
            FogParticle(
                position: CGPoint(
                    x: CGFloat.random(in: -100...size.width + 100),
                    y: CGFloat.random(in: -80...size.height + 80)
                ),
                radius:      CGFloat.random(in: 80...200),
                baseOpacity: Double.random(in: 0.25...0.55),
                phaseOffset: Double.random(in: 0...(.pi * 2)),
                driftAngle:  Double.random(in: 0...(.pi * 2)),
                speed:       CGFloat.random(in: 4...14)
            )
        }
    }

    // MARK: - Draw

    private func drawFogParticle(
        context:     GraphicsContext,
        particle:    FogParticle,
        time:        TimeInterval,
        clearZones:  [ClearZone],
        globalClear: Double,
        canvasSize:  CGSize
    ) {
        // 時間ベースの漂い
        let drift = CGPoint(
            x: particle.position.x + cos(particle.driftAngle + time * 0.03) * particle.speed * CGFloat(time * 0.01),
            y: particle.position.y + sin(particle.driftAngle + time * 0.02) * particle.speed * CGFloat(time * 0.008)
        )

        // ループ（画面外に出たら反対側から）
        let loopedX = drift.x.truncatingRemainder(dividingBy: canvasSize.width + 200)
        let loopedY = drift.y.truncatingRemainder(dividingBy: canvasSize.height + 160)
        let pos = CGPoint(
            x: loopedX < -100 ? loopedX + canvasSize.width + 200 : loopedX,
            y: loopedY < -80  ? loopedY + canvasSize.height + 160 : loopedY
        )

        // サイン波で透明度をゆらぐ
        let wave = (sin(time * 0.4 + particle.phaseOffset) + 1) / 2  // 0〜1
        var opacity = particle.baseOpacity * (0.7 + wave * 0.3)

        // スワイプ消去ゾーンの影響
        for zone in clearZones {
            let dist = hypot(pos.x - zone.center.x, pos.y - zone.center.y)
            if dist < zone.radius * 1.5 {
                let falloff = max(0, 1.0 - (dist / (zone.radius * 1.5)))
                opacity *= (1.0 - falloff * zone.opacity * 0.95)
            }
        }

        // 音声/全体クリアの影響
        opacity *= max(0, 1.0 - clearProgress)

        guard opacity > 0.01 else { return }

        // グラデーション楕円で霧を描画
        let rect = CGRect(
            x: pos.x - particle.radius,
            y: pos.y - particle.radius * 0.6,
            width:  particle.radius * 2,
            height: particle.radius * 1.2
        )

        let fogColor = Color(
            red:   0.06 + wave * 0.02,
            green: 0.08 + wave * 0.02,
            blue:  0.18 + wave * 0.04
        ).opacity(opacity)

        context.fill(
            Path(ellipseIn: rect),
            with: .color(fogColor)
        )
    }
}
