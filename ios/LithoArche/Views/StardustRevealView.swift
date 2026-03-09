import SwiftUI

/// ワーク03: 星屑の採取標本
/// 霧に包まれたカードを払うと、隠れた言葉が現れる（トレーシングペーパーのデジタル版）
struct StardustRevealView: View {

    var body: some View {
        ZStack {
            Color(hex: "080A1A").ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // ヘッダー
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 11))
                                .foregroundStyle(Color(hex: "8A6A2A"))
                            Text("STARDUST SPECIMEN — CLASSIFIED")
                                .font(.system(size: 10, weight: .light))
                                .foregroundStyle(Color(hex: "8A6A2A"))
                                .tracking(2)
                        }
                        Text("消えかけの星屑が、ここに保管されている。\n霧を払うと、誰にも届かなかった言葉が現れる。")
                            .font(.system(size: 13, weight: .light))
                            .foregroundStyle(Color(hex: "5A6A5A"))
                            .lineSpacing(6)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 28)
                    .padding(.bottom, 32)

                    // 標本カード一覧
                    VStack(spacing: 20) {
                        ForEach(StardustSpecimen.all) { specimen in
                            SpecimenCard(specimen: specimen)
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.bottom, 60)
                }
            }
        }
        .navigationTitle("星屑の採取標本")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - 標本データ

struct StardustSpecimen: Identifiable {
    let id:          String
    let hiddenText:  String   // 霧の下に隠れている言葉（ルーフェンのメッセージ）
    let label:       String   // 標本ラベル（霧の上に表示）
    let color:       Color
}

extension StardustSpecimen {
    static let all: [StardustSpecimen] = [
        StardustSpecimen(
            id: "s01",
            hiddenText: "あなたが「大丈夫」と言い続けた夜の数だけ、私は記録を積み重ねた。全部、ちゃんと残っている。",
            label: "標本 No.001 — 未発信の言葉",
            color: Color(hex: "3A6B9E")
        ),
        StardustSpecimen(
            id: "s02",
            hiddenText: "誰かに言えなかった「ありがとう」も、ここに保管されている。言葉は届かなくても、想いは消えない。",
            label: "標本 No.002 — 届かなかった優しさ",
            color: Color(hex: "8A6A2A")
        ),
        StardustSpecimen(
            id: "s03",
            hiddenText: "子供のころの夢は、諦めたのではなく、形を変えただけかもしれない。記録官として私はそう観測している。",
            label: "標本 No.003 — 変容した夢",
            color: Color(hex: "6A3A8A")
        ),
        StardustSpecimen(
            id: "s04",
            hiddenText: "あなたが気づかないうちにやってのけたことが、いくつもある。私はすべて記録している。",
            label: "標本 No.004 — 見えない功績",
            color: Color(hex: "3A6A4A")
        ),
        StardustSpecimen(
            id: "s05",
            hiddenText: "孤独は、世界からあなたが切り離されているのではない。まだ繋がっていない場所があるというだけだ。",
            label: "標本 No.005 — 未接続の接点",
            color: Color(hex: "7A3A5A")
        ),
    ]
}

// MARK: - 標本カード（霧払いインタラクション）

private struct SpecimenCard: View {
    let specimen: StardustSpecimen

    @State private var clearZones: [ClearZone] = []
    @State private var isFullyRevealed = false
    @State private var tapCount = 0

    struct ClearZone: Identifiable {
        let id = UUID()
        var center: CGPoint
        var radius: CGFloat
    }

    private var revealRatio: Double {
        // 消去ゾーンの合計面積でおよその開示率を計算
        let total = 340.0 * 160.0
        let covered = clearZones.reduce(0.0) { $0 + .pi * Double($1.radius * $1.radius) }
        return min(covered / total, 1.0)
    }

    var body: some View {
        ZStack {
            // ── 背景 ──────────────────────────────────
            RoundedRectangle(cornerRadius: 4)
                .fill(specimen.color.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(specimen.color.opacity(0.2), lineWidth: 0.5)
                )

            // ── 隠れている言葉 ──────────────────────
            VStack(spacing: 12) {
                Image(systemName: "sparkle")
                    .font(.system(size: 16))
                    .foregroundStyle(specimen.color.opacity(0.6))

                Text(specimen.hiddenText)
                    .font(.system(size: 15, weight: .thin, design: .serif))
                    .foregroundStyle(Color(hex: "C8D8F0"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .padding(.horizontal, 20)
            }
            .padding(.vertical, 28)

            // ── 霧レイヤー（Canvas で描画） ─────────
            if !isFullyRevealed {
                TimelineView(.animation(minimumInterval: 1/30)) { timeline in
                    Canvas { ctx, size in
                        let t = timeline.date.timeIntervalSinceReferenceDate

                        // 霧の塊を複数描く
                        for i in 0..<12 {
                            let fi = Double(i)
                            let cx = size.width  * (0.1 + 0.8 * fmod(fi * 0.137 + t * 0.012, 1.0))
                            let cy = size.height * (0.1 + 0.8 * fmod(fi * 0.241 + t * 0.008, 1.0))
                            let r  = CGFloat(40 + fmod(fi * 17, 30))

                            var opacity = 0.65 + 0.1 * sin(t * 0.5 + fi)

                            // 消去ゾーンの影響
                            for zone in clearZones {
                                let dist = hypot(cx - Double(zone.center.x), cy - Double(zone.center.y))
                                if dist < Double(zone.radius) * 1.6 {
                                    let fall = max(0.0, 1.0 - dist / (Double(zone.radius) * 1.6))
                                    opacity *= (1.0 - fall * 0.95)
                                }
                            }

                            guard opacity > 0.01 else { continue }

                            let rect = CGRect(x: cx - Double(r), y: cy - Double(r * 0.7),
                                             width: Double(r * 2), height: Double(r * 1.4))
                            ctx.fill(
                                Path(ellipseIn: rect),
                                with: .color(Color(hex: "080A1A").opacity(opacity))
                            )
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .allowsHitTesting(false)

                // 霧の上に表示するラベル
                VStack {
                    HStack {
                        Text(specimen.label)
                            .font(.system(size: 10, weight: .light))
                            .foregroundStyle(specimen.color.opacity(0.5))
                            .tracking(1)
                            .padding(.horizontal, 14)
                            .padding(.top, 14)
                        Spacer()
                    }
                    Spacer()
                    Text("なぞって霧を払う")
                        .font(.system(size: 11, weight: .light))
                        .foregroundStyle(Color(hex: "2A3A4A"))
                        .padding(.bottom, 12)
                }
                .allowsHitTesting(false)
            }
        }
        .frame(height: 160)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { val in
                    guard !isFullyRevealed else { return }
                    clearZones.append(ClearZone(center: val.location, radius: 44))
                    if revealRatio > 0.55 {
                        withAnimation(.easeOut(duration: 0.6)) { isFullyRevealed = true }
                    }
                }
        )
        .onTapGesture {
            // タップでも少しずつ霧を払える
            guard !isFullyRevealed else { return }
            tapCount += 1
            let center = CGPoint(x: 170, y: 80)
            let offset = CGFloat(tapCount) * 30
            clearZones.append(ClearZone(
                center: CGPoint(x: center.x + offset.truncatingRemainder(dividingBy: 200),
                                y: center.y + offset / 200 * 40),
                radius: 50
            ))
            if revealRatio > 0.55 {
                withAnimation(.easeOut(duration: 0.6)) { isFullyRevealed = true }
            }
        }
        // 再び霧をかける（長押し）
        .onLongPressGesture(minimumDuration: 1.2) {
            withAnimation(.easeIn(duration: 0.8)) {
                clearZones    = []
                isFullyRevealed = false
                tapCount      = 0
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if isFullyRevealed {
                Text("長押しで隠す")
                    .font(.system(size: 9, weight: .light))
                    .foregroundStyle(Color(hex: "2A3A4A"))
                    .padding(10)
            }
        }
    }
}

#Preview {
    NavigationStack { StardustRevealView() }
}
