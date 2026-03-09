import SwiftUI
import SwiftData

// MARK: - エリア定義

enum SanctuaryArea: String, CaseIterable, Hashable {
    case atelier    // 幻装の仕立て処
    case senses     // 五感の標本箱
    case stone      // リトの石碑
    case hourglass  // 時の砂時計
    case gate       // 外界への門

    var japaneseName: String {
        switch self {
        case .atelier:   return "幻装の仕立て処"
        case .senses:    return "五感の標本箱"
        case .stone:     return "リトの石碑"
        case .hourglass: return "時の砂時計"
        case .gate:      return "外界への門"
        }
    }
    var englishName: String {
        switch self {
        case .atelier:   return "Phantasm-Shell Atelier"
        case .senses:    return "Sensory Specimen"
        case .stone:     return "Litho-Stone Archive"
        case .hourglass: return "Hourglass Review"
        case .gate:      return "Gateway to the World"
        }
    }
    var description: String {
        switch self {
        case .atelier:   return "理想の姿を描くワーク"
        case .senses:    return "感覚のアーカイブ"
        case .stone:     return "魔法の言葉と命名"
        case .hourglass: return "自己問診と時間の記録"
        case .gate:      return "SNS・BOOTHへのポータル"
        }
    }
    var icon: String {
        switch self {
        case .atelier:   return "paintbrush.pointed"   // 魔法の筆
        case .senses:    return "testtube.2"            // 標本管
        case .stone:     return "key.fill"              // 古い鍵
        case .hourglass: return "hourglass"             // 砂時計
        case .gate:      return "arrow.up.forward"      // 外界への矢
        }
    }
    var color: Color {
        switch self {
        case .atelier:   return Color(hex: "8A6A2A")
        case .senses:    return Color(hex: "2A7A8A")
        case .stone:     return Color(hex: "3A6B9E")
        case .hourglass: return Color(hex: "5A6A3A")
        case .gate:      return Color(hex: "7A3A6A")
        }
    }
    var dimColor: Color {
        switch self {
        case .atelier:   return Color(hex: "1A1408")
        case .senses:    return Color(hex: "0A1E22")
        case .stone:     return Color(hex: "0A1428")
        case .hourglass: return Color(hex: "0E1208")
        case .gate:      return Color(hex: "1A0A1E")
        }
    }
}

// MARK: - Screen 3: 聖域の広間

struct SanctuaryView: View {

    let profile: UserProfile

    @State private var path         = NavigationPath()
    @State private var appeared     = false
    @State private var menuAppeared = false

    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // ── 背景画像 ─────────────────────────
                    Image("entrance_bg.jpg")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                        .clipped()
                    // 画像の上に薄い暗幕（メニュー文字を読みやすくする）
                    Color(hex: "07091A").opacity(0.35).ignoresSafeArea()
                    SanctuaryAmbience()

                    // ── 装飾枠 ──────────────────────────
                    Image("deco_border.png")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                        .opacity(0.18)
                        .blendMode(.screen)
                        .allowsHitTesting(false)

                    // ── 霧と大気（右側の余白美）──────────
                    MistLayer()
                        .allowsHitTesting(false)

                    // ── ルーフェン（コンテンツエリア左寄り）──
                    RuufenCharacterView()
                        .position(
                            x: 160 + (geo.size.width - 160) * 0.40,
                            y: geo.size.height * 0.50
                        )
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 1.4).delay(0.6), value: appeared)

                    // ── 右上タイトル ＋ 右下の詩テキスト ────
                    VStack {
                        HStack {
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("STELLAR ARCHIVE")
                                    .font(.system(size: 8, weight: .light))
                                    .foregroundStyle(Color(hex: "3A6B9E").opacity(0.55))
                                    .tracking(3)
                                Text(profile.sanctuaryName.isEmpty
                                     ? "聖域の広間"
                                     : profile.sanctuaryName)
                                    .font(.system(size: 16, weight: .thin, design: .serif))
                                    .foregroundStyle(Color(hex: "C8D8F0"))
                                    .tracking(1)
                                Text("「\(profile.magicWord)」")
                                    .font(.system(size: 11, weight: .thin, design: .serif))
                                    .foregroundStyle(Color(hex: "3A5A7A"))
                                    .tracking(2)
                            }
                            .padding(.trailing, 24)
                            .padding(.top, 60)
                        }
                        Spacer()
                        // 右下の詩的テキスト（余白の美）
                        HStack {
                            Spacer()
                            Text("― 石の言葉は、星に届く ―")
                                .font(.system(size: 9, weight: .thin, design: .serif))
                                .foregroundStyle(Color(hex: "3A6B9E").opacity(0.30))
                                .tracking(2)
                                .padding(.trailing, 28)
                                .padding(.bottom, 44)
                        }
                    }
                    .allowsHitTesting(false)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.9).delay(0.3), value: appeared)

                    // ── 左メニューパネル ────────────────
                    LeftMenuPanel { area in
                        path.append(area)
                    }
                    .opacity(menuAppeared ? 1 : 0)
                    .offset(x: menuAppeared ? 0 : -50)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1),
                               value: menuAppeared)
                }
                .ignoresSafeArea()
            }
            .navigationBarHidden(true)
            .navigationDestination(for: SanctuaryArea.self) { area in
                switch area {
                case .atelier:   PhantasmAtelierView()
                case .senses:    SensorySpecimenView()
                case .stone:     LithoStoneView()
                case .hourglass: HourglassView()
                case .gate:      OuterGateView()
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.2)) { appeared     = true }
            withAnimation(.easeOut(duration: 0.7).delay(0.2)) { menuAppeared = true }
        }
    }
}

// MARK: - 左メニューパネル

private struct LeftMenuPanel: View {
    let onSelect: (SanctuaryArea) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── ロゴエリア ──────────────────────────
            VStack(alignment: .leading, spacing: 6) {
                Text("LITHO · ARCHE")
                    .font(.system(size: 7, weight: .light))
                    .foregroundStyle(Color(hex: "3A6B9E").opacity(0.55))
                    .tracking(3)
                Text("聖域")
                    .font(.system(size: 22, weight: .thin, design: .serif))
                    .foregroundStyle(Color(hex: "8AA8C8"))
            }
            .padding(.top, 70)
            .padding(.horizontal, 22)
            .padding(.bottom, 24)

            // 区切り線（グラデーション）
            LinearGradient(
                colors: [Color(hex: "3A6B9E").opacity(0.6), .clear],
                startPoint: .leading, endPoint: .trailing
            )
            .frame(height: 0.5)
            .padding(.leading, 22)
            .padding(.bottom, 18)

            // ── ナビゲーション項目 ──────────────────
            ForEach(SanctuaryArea.allCases, id: \.self) { area in
                MenuItemRow(area: area) { onSelect(area) }
            }

            Spacer()

            // ── フッター ────────────────────────────
            LinearGradient(
                colors: [Color(hex: "3A6B9E").opacity(0.3), .clear],
                startPoint: .leading, endPoint: .trailing
            )
            .frame(height: 0.5)
            .padding(.leading, 22)
            .padding(.bottom, 16)

            Text("Lex Animae & Lapidis")
                .font(.system(size: 8, weight: .light))
                .foregroundStyle(Color(hex: "2A3A5A").opacity(0.7))
                .tracking(1)
                .padding(.leading, 22)
                .padding(.bottom, 40)
        }
        .frame(width: 162)
        .frame(maxHeight: .infinity)
        .background(
            ZStack {
                Color(hex: "060812").opacity(0.88)
                // 右端の光のライン
                HStack {
                    Spacer()
                    LinearGradient(
                        colors: [.clear, Color(hex: "3A6B9E").opacity(0.3), .clear],
                        startPoint: .top, endPoint: .bottom
                    )
                    .frame(width: 0.5)
                }
            }
        )
        .ignoresSafeArea(edges: .vertical)
    }
}

// MARK: - メニュー行（刷新版：セリフ体＋カスタムアイコン）

private struct MenuItemRow: View {
    let area:   SanctuaryArea
    let action: () -> Void

    @State private var isPressed = false
    @State private var glow      = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // 各エリア専用の非対称アイコンフレーム
                AreaIconView(area: area, isGlowing: glow)

                VStack(alignment: .leading, spacing: 4) {
                    Text(area.japaneseName)
                        .font(.system(size: 13, weight: .thin, design: .serif))
                        .foregroundStyle(Color(hex: "D4C8E8"))
                        .tracking(1)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                    Text(area.description)
                        .font(.system(size: 9, weight: .light))
                        .foregroundStyle(area.color.opacity(glow ? 0.85 : 0.55))
                        .tracking(0.5)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                Spacer()
            }
            .padding(.leading, 16)
            .padding(.trailing, 10)
            .padding(.vertical, 13)
            .background(
                isPressed
                    ? area.color.opacity(0.08)
                    : Color.clear
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.22, dampingFraction: 0.7), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded   { _ in isPressed = false }
        )
        .onAppear {
            withAnimation(
                .easeInOut(duration: Double.random(in: 1.8...2.8))
                .repeatForever(autoreverses: true)
                .delay(Double.random(in: 0...0.8))
            ) { glow = true }
        }
    }
}

// MARK: - エリア専用アイコン（非対称カスタム形状）

private struct AreaIconView: View {
    let area:      SanctuaryArea
    let isGlowing: Bool

    var body: some View {
        Canvas { ctx, size in
            let path = framePath(in: size)
            // 内部塗り
            ctx.fill(path, with: .color(area.color.opacity(isGlowing ? 0.18 : 0.07)))
            // 枠線
            ctx.stroke(path,
                       with: .color(area.color.opacity(isGlowing ? 0.70 : 0.22)),
                       lineWidth: 0.8)
        }
        .overlay {
            Image(systemName: area.icon)
                .font(.system(size: 11, weight: .ultraLight))
                .foregroundStyle(area.color.opacity(isGlowing ? 1.0 : 0.5))
                // 菱形の重心補正
                .offset(y: area == .stone ? 1 : 0)
        }
        .frame(width: 30, height: 36)
    }

    /// エリアごとに異なる輪郭パスを返す
    private func framePath(in size: CGSize) -> Path {
        let w = size.width, h = size.height
        switch area {

        case .atelier:
            // ── 円形メダル（芸術家の印章）────────────
            let r = min(w, h) / 2 - 1
            return Path(ellipseIn: CGRect(x: w/2 - r, y: h/2 - r, width: r*2, height: r*2))

        case .senses:
            // ── 標本瓶（縦長角丸）────────────────────
            return Path(roundedRect: CGRect(x: 2, y: 0, width: w - 4, height: h),
                        cornerRadius: w * 0.28)

        case .stone:
            // ── 菱形（石碑・宝石の断面）──────────────
            var p = Path()
            p.move(to:    CGPoint(x: w/2,     y: 1))
            p.addLine(to: CGPoint(x: w - 1,   y: h/2))
            p.addLine(to: CGPoint(x: w/2,     y: h - 1))
            p.addLine(to: CGPoint(x: 1,       y: h/2))
            p.closeSubpath()
            return p

        case .hourglass:
            // ── 砂時計型（上下が広く、中央でくびれる）──
            var p = Path()
            let inset: CGFloat = 3
            p.move(to:    CGPoint(x: inset,       y: 1))
            p.addLine(to: CGPoint(x: w - inset,   y: 1))
            p.addLine(to: CGPoint(x: w/2 + 3,     y: h/2 - 1))
            p.addLine(to: CGPoint(x: w - inset,   y: h - 1))
            p.addLine(to: CGPoint(x: inset,       y: h - 1))
            p.addLine(to: CGPoint(x: w/2 - 3,     y: h/2 + 1))
            p.closeSubpath()
            return p

        case .gate:
            // ── アーチ門（半円天頂＋縦長矩形）──────────
            var p = Path()
            let archH = h * 0.46
            p.move(to:    CGPoint(x: 2,     y: h - 1))
            p.addLine(to: CGPoint(x: 2,     y: archH))
            p.addArc(center: CGPoint(x: w/2, y: archH),
                     radius: w/2 - 2,
                     startAngle: .degrees(180),
                     endAngle:   .degrees(0),
                     clockwise: false)
            p.addLine(to: CGPoint(x: w - 2, y: h - 1))
            p.closeSubpath()
            return p
        }
    }
}

// MARK: - ルーフェン キャラクタービュー

private struct RuufenCharacterView: View {
    @State private var floatY:    CGFloat = 0
    @State private var glowPulse: Bool    = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // 足元グロー
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "3A6B9E").opacity(glowPulse ? 0.30 : 0.12),
                            .clear
                        ],
                        center: .center, startRadius: 0, endRadius: 100
                    )
                )
                .frame(width: 220, height: 55)
                .blur(radius: 18)
                .offset(y: 10)

            // キャラクター画像（ruufen.png をアセットに追加）
            Image("ruufen.png")
                .resizable()
                .scaledToFit()
                .frame(height: 300)
                .offset(y: floatY)
                .shadow(
                    color: Color(hex: "3A6B9E").opacity(glowPulse ? 0.35 : 0.15),
                    radius: 24, y: 12
                )
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 3.8)
                .repeatForever(autoreverses: true)
            ) { floatY = -14 }

            withAnimation(
                .easeInOut(duration: 2.6)
                .repeatForever(autoreverses: true)
                .delay(0.5)
            ) { glowPulse = true }
        }
    }
}

// MARK: - 霧と余白の大気（右側の空間美）

private struct MistLayer: View {
    var body: some View {
        ZStack {
            // 右側から広がる薄い霞
            HStack {
                Spacer()
                LinearGradient(
                    colors: [.clear, Color(hex: "1A2440").opacity(0.14)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 260)
                .blur(radius: 40)
            }

            // 下方の深い霧
            VStack {
                Spacer()
                LinearGradient(
                    colors: [
                        Color(hex: "07091A").opacity(0.55),
                        Color(hex: "0A1428").opacity(0.20),
                        .clear
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 200)
                .blur(radius: 12)
            }

            // 右上の星雲状ぼかし（遠景感）
            VStack {
                HStack {
                    Spacer()
                    Ellipse()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: "1A3A6A").opacity(0.10),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 180)
                        .blur(radius: 30)
                        .padding(.top, 60)
                        .padding(.trailing, 30)
                }
                Spacer()
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - 背景アンビエンス

private struct SanctuaryAmbience: View {
    @State private var particles: [AmbParticle] = []

    struct AmbParticle: Identifiable {
        let id = UUID()
        var x, y: CGFloat
        var size:  CGFloat
        var phase: Double
        var speed: CGFloat
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate
                for p in particles {
                    let wave   = (sin(t * Double(p.speed) + p.phase) + 1) * 0.5
                    let opacity = 0.06 + wave * 0.10
                    let dy = CGFloat(t) * p.speed * 8
                    let py = (p.y - dy).truncatingRemainder(dividingBy: size.height + 20)
                    let adjustedY = py < -10 ? py + size.height + 20 : py
                    ctx.fill(
                        Path(ellipseIn: CGRect(x: p.x - p.size/2, y: adjustedY - p.size/2,
                                              width: p.size, height: p.size)),
                        with: .color(Color(hex: "C8D8F0").opacity(opacity))
                    )
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onAppear {
            let s = UIScreen.main.bounds
            particles = (0..<40).map { _ in
                AmbParticle(
                    x:     CGFloat.random(in: 0...s.width),
                    y:     CGFloat.random(in: 0...s.height),
                    size:  CGFloat.random(in: 1...3),
                    phase: Double.random(in: 0...(.pi * 2)),
                    speed: CGFloat.random(in: 0.008...0.022)
                )
            }
        }
    }
}

// MARK: - エリア遷移先ビュー（各フェーズで本実装）

/// 断片の収集エリア（ミニマル版: 未実装プレースホルダー）
struct FragmentArchiveView: View {
    var body: some View {
        ZStack {
            Color(hex: "07091A").ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "diamond.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color(hex: "7A3A4A"))
                Text("断片の収集エリア")
                    .font(.system(size: 18, weight: .thin, design: .serif))
                    .foregroundStyle(Color(hex: "C8D8F0"))
                Text("準備中")
                    .font(.system(size: 12, weight: .light))
                    .foregroundStyle(Color(hex: "3A4A5A"))
            }
        }
        .navigationBarBackButtonHidden(false)
    }
}

/// 霊殻の仕立て処 → WorkshopView エントリポイント（ギャラリー）
struct AtelierEntryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \DrawingEntry.updatedAt, order: .reverse) private var drawings: [DrawingEntry]
    @State private var activeEntry: DrawingEntry?

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(hex: "07091A").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // ヘッダー
                    VStack(alignment: .leading, spacing: 6) {
                        Text("VESSEL ATELIER")
                            .font(.system(size: 9, weight: .light))
                            .foregroundStyle(Color(hex: "8A6A2A").opacity(0.7))
                            .tracking(3)
                        Text("霊殻の仕立て処")
                            .font(.system(size: 22, weight: .thin, design: .serif))
                            .foregroundStyle(Color(hex: "C8D8F0"))
                        Text("ガイドの光に沿い、自分の魂の姿を描く")
                            .font(.system(size: 11, weight: .light))
                            .foregroundStyle(Color(hex: "3A4A5A"))
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 28)
                    .padding(.bottom, 20)

                    if drawings.isEmpty {
                        emptyState
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(drawings) { entry in
                                VesselThumbnailCard(entry: entry) {
                                    activeEntry = entry
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }

            // 新規作成ボタン
            Button {
                let e = DrawingEntry(title: "新しい器")
                context.insert(e)
                try? context.save()
                activeEntry = e
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(hex: "1A1408"))
                        .overlay(Circle().stroke(Color(hex: "8A6A2A"), lineWidth: 1))
                        .frame(width: 56, height: 56)
                        .shadow(color: Color(hex: "8A6A2A").opacity(0.3), radius: 12)
                    Image(systemName: "plus")
                        .font(.system(size: 20))
                        .foregroundStyle(Color(hex: "D4B870"))
                }
            }
            .padding(28)
        }
        .fullScreenCover(item: $activeEntry) { WorkshopView(entry: $0) }
        .navigationTitle("仕立て処")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 60)
            Image(systemName: "figure.arms.open")
                .font(.system(size: 52))
                .foregroundStyle(Color(hex: "3A2A14"))
            Text("まだ器がありません\n＋ ボタンで最初の魂の器を描いてください")
                .font(.system(size: 13, weight: .light))
                .foregroundStyle(Color(hex: "3A4A5A"))
                .multilineTextAlignment(.center)
                .lineSpacing(7)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 作品サムネイルカード

struct VesselThumbnailCard: View {
    let entry:  DrawingEntry
    let onTap:  () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    // サムネイル
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: "0D0E1A"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    entry.isPlacedInSanctuary
                                        ? Color(hex: "3A6B9E")
                                        : Color(hex: "2A2A3A"),
                                    lineWidth: entry.isPlacedInSanctuary ? 1.5 : 0.5
                                )
                        )
                        .frame(height: 140)

                    if let data = entry.thumbnailData, let img = UIImage(data: data) {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    } else {
                        Image(systemName: "scribble")
                            .font(.system(size: 36))
                            .foregroundStyle(Color(hex: "2A3A4A"))
                    }

                    // 「聖域配置中」バッジ
                    if entry.isPlacedInSanctuary {
                        VStack {
                            HStack {
                                Spacer()
                                HStack(spacing: 3) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 8))
                                    Text("聖域")
                                        .font(.system(size: 8, weight: .light))
                                }
                                .foregroundStyle(Color(hex: "C8D8F0"))
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule()
                                        .fill(Color(hex: "3A6B9E").opacity(0.8))
                                )
                                .padding(8)
                            }
                            Spacer()
                        }
                    }
                }

                // タイトル・日付
                VStack(alignment: .leading, spacing: 3) {
                    Text(entry.title.isEmpty ? "（無題）" : entry.title)
                        .font(.system(size: 13, weight: .light, design: .serif))
                        .foregroundStyle(Color(hex: "C8D8F0"))
                        .lineLimit(1)
                    Text(entry.updatedAt.formatted(
                        .dateTime.month().day()
                            .locale(Locale(identifier: "ja_JP"))
                    ))
                    .font(.system(size: 10, weight: .light))
                    .foregroundStyle(Color(hex: "3A4A5A"))
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 4)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.28, dampingFraction: 0.65), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded   { _ in isPressed = false }
        )
    }
}

// MARK: - 歩く魂の器

private struct WalkingVesselView: View {
    let imageData: Data
    private let walkDuration: Double = 18.0

    var body: some View {
        if let uiImage = UIImage(data: imageData) {
            GeometryReader { geo in
                walkingFigure(uiImage: uiImage, in: geo)
            }
        }
    }

    private func walkingFigure(uiImage: UIImage, in geo: GeometryProxy) -> some View {
        let w = geo.size.width
        let h = geo.size.height
        let figH: CGFloat = 80
        let minX: CGFloat = figH * 0.5
        let maxX: CGFloat = w - figH * 0.5

        return TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { tl in
            let t     = tl.date.timeIntervalSinceReferenceDate
            let cycle = walkDuration * 2
            let phase = t.truncatingRemainder(dividingBy: cycle)
            let frac  = phase < walkDuration
                ? CGFloat(phase / walkDuration)
                : CGFloat(1.0 - (phase - walkDuration) / walkDuration)
            let xPos      = minX + frac * (maxX - minX)
            let goRight   = phase < walkDuration
            let bob       = CGFloat(sin(t * .pi * 2.2) * 3.5)  // 上下の揺れ

            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(height: figH)
                .scaleEffect(x: goRight ? 1 : -1, y: 1)
                .opacity(0.65)
                .shadow(color: Color(hex: "3A6B9E").opacity(0.28), radius: 8, y: 4)
                .position(x: xPos, y: h * 0.87 + bob)
        }
    }
}


// MARK: - リトの石碑

struct LithoStoneView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \UserProfile.createdAt, order: .forward) private var profiles: [UserProfile]

    @State private var magicWordDraft    = ""
    @State private var sanctuaryDraft   = ""
    @State private var saved            = false

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        ZStack {
            Color(hex: "07091A").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    TitleBannerView(title: "リトの石碑", subtitle: "LITHO · STONE ARCHIVE")
                        .padding(.bottom, 32)

                    VStack(alignment: .leading, spacing: 28) {

                        // ── 聖域の名前 ─────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            Text("聖域の名前")
                                .font(.system(size: 10, weight: .light))
                                .foregroundStyle(Color(hex: "3A6B9E").opacity(0.8))
                                .tracking(2)
                            TextField("", text: $sanctuaryDraft,
                                      prompt: Text("例：星の記録庫")
                                        .foregroundColor(Color(hex: "2A3A5A")))
                                .font(.system(size: 18, weight: .thin, design: .serif))
                                .foregroundStyle(Color(hex: "C8D8F0"))
                                .padding(.vertical, 10)
                                .overlay(alignment: .bottom) {
                                    Rectangle()
                                        .fill(Color(hex: "3A6B9E").opacity(0.4))
                                        .frame(height: 0.7)
                                }
                        }

                        // ── 合言葉 ─────────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            Text("魔法の合言葉")
                                .font(.system(size: 10, weight: .light))
                                .foregroundStyle(Color(hex: "3A6B9E").opacity(0.8))
                                .tracking(2)
                            TextField("", text: $magicWordDraft,
                                      prompt: Text("扉を開く言葉を刻む")
                                        .foregroundColor(Color(hex: "2A3A5A")))
                                .font(.system(size: 18, weight: .thin, design: .serif))
                                .foregroundStyle(Color(hex: "C8D8F0"))
                                .padding(.vertical, 10)
                                .overlay(alignment: .bottom) {
                                    Rectangle()
                                        .fill(Color(hex: "3A6B9E").opacity(0.4))
                                        .frame(height: 0.7)
                                }
                        }

                        // ── 保存ボタン ─────────────────────
                        Button {
                            guard let p = profile else { return }
                            p.magicWord     = magicWordDraft
                            p.sanctuaryName = sanctuaryDraft
                            try? context.save()
                            withAnimation { saved = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation { saved = false }
                            }
                        } label: {
                            Text(saved ? "刻まれた" : "石碑に刻む")
                                .font(.system(size: 14, weight: .light))
                                .foregroundStyle(saved ? Color(hex: "8AA8C8") : Color(hex: "C8D8F0"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2)
                                        .stroke(
                                            (saved ? Color(hex: "3A6B9E") : Color(hex: "3A6B9E")).opacity(0.5),
                                            lineWidth: 1
                                        )
                                )
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 36)
                }
                .padding(.bottom, 60)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            magicWordDraft  = profile?.magicWord    ?? ""
            sanctuaryDraft  = profile?.sanctuaryName ?? ""
        }
    }
}

// MARK: - 外界への門

struct OuterGateView: View {

    private struct Portal: Identifiable {
        let id    = UUID()
        let label: String
        let sub:   String
        let icon:  String
        let color: String
        let url:   String
    }

    private let portals: [Portal] = [
        Portal(label: "X (Twitter)",   sub: "@LithoArche",    icon: "bird",          color: "1A8CD8", url: "https://twitter.com/"),
        Portal(label: "BOOTH",          sub: "グッズ・作品",   icon: "bag.fill",       color: "F15D28", url: "https://booth.pm/"),
        Portal(label: "YouTube",        sub: "動画アーカイブ", icon: "play.rectangle.fill", color: "FF0000", url: "https://youtube.com/"),
        Portal(label: "Instagram",      sub: "ギャラリー",     icon: "camera.fill",    color: "C13584", url: "https://instagram.com/"),
    ]

    var body: some View {
        ZStack {
            Color(hex: "07091A").ignoresSafeArea()

            VStack(spacing: 0) {
                TitleBannerView(title: "外界への門", subtitle: "GATEWAY TO THE WORLD")
                    .padding(.bottom, 32)

                VStack(spacing: 16) {
                    ForEach(portals) { p in
                        Link(destination: URL(string: p.url)!) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: p.color).opacity(0.15))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: p.icon)
                                        .font(.system(size: 18))
                                        .foregroundStyle(Color(hex: p.color))
                                }

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(p.label)
                                        .font(.system(size: 15, weight: .light, design: .serif))
                                        .foregroundStyle(Color(hex: "C8D8F0"))
                                    Text(p.sub)
                                        .font(.system(size: 11, weight: .light))
                                        .foregroundStyle(Color(hex: "3A4A5A"))
                                }

                                Spacer()

                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color(hex: "3A6B9E").opacity(0.6))
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(hex: "0D0F20"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color(hex: p.color).opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 20)
                        }
                    }
                }

                Spacer()
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

#Preview {
    SanctuaryView(profile: UserProfile(magicWord: "しずか", sanctuaryName: "星の記録庫"))
        .modelContainer(
            for: [UserProfile.self, DrawingEntry.self, SensoryEntry.self,
                  LogResponse.self, SealedMemory.self, HourglassEntry.self],
            inMemory: true
        )
}
