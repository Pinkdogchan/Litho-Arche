import SwiftUI
import SwiftData

// MARK: - Screen 6 コンテナ

struct PhantasmAtelierView: View {
    @AppStorage("hasSeenAtelierIntro") private var hasSeenIntro = false
    @State private var showGallery = false

    var body: some View {
        Group {
            if hasSeenIntro || showGallery {
                PhantasmGalleryView()
                    .transition(.opacity)
            } else {
                PhantasmAtelierIntroView {
                    hasSeenIntro = true
                    withAnimation(.easeInOut(duration: 0.9)) { showGallery = true }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.9), value: showGallery)
        .navigationBarHidden(true)
    }
}

// MARK: - 導入：ルーフェンの案内

struct PhantasmAtelierIntroView: View {

    var onComplete: () -> Void  // ギャラリーへ移行

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    // 行フェード状態
    @State private var visibleLines: [String] = []
    @State private var lineIndex:    Int      = 0
    @State private var showTemplates: Bool    = false
    @State private var showGalleryLink: Bool  = false
    @State private var glowPulse:    Bool     = false
    @State private var appeared:     Bool     = false

    // ルーフェンの語りかけ（5行）
    private let narrationLines: [String] = [
        "ようこそ。ここは、君の魂に一番似合う『姿』を形にする場所。",
        "現実の君を縛っている形は、ここでは意味を持たない。",
        "君がずっと求めていた、自由な重力。\n君が一番誇らしくいられる輪郭。",
        "さあ、君だけの『幻装』を、僕と一緒に仕立てていこう。",
        "まずどこへ行きたい？　どんな魔法を使って、誰を笑わせたい？」"
    ]

    // テンプレート選択肢（語り終わりに出現）
    private let templates: [(GuideTemplate, String, String)] = [
        (.humanSkeleton,  "中性体", "figure.arms.open"),
        (.masculine,      "男性体", "figure.stand"),
        (.feminine,       "女性体", "figure.wave"),
        (.beastSkeleton,  "獣型",   "pawprint"),
        (.wingedSkeleton, "翼型",   "bird")
    ]

    @State private var activeEntry: DrawingEntry? = nil

    var body: some View {
        ZStack(alignment: .topLeading) {
            // ── 背景 ───────────────────────────────
            Color(hex: "080603").ignoresSafeArea()
            AtelierAmbience()

            // ── 漂う設計書 ──────────────────────────
            GeometryReader { geo in
                FloatingPapersView(size: geo.size)
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 0) {

                // ── ルーフェンの灯（上部 40%）────────
                Spacer()
                ruufenPresence
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 1.2), value: appeared)

                Spacer().frame(height: 32)

                // ── 語りかけ（中央）─────────────────
                narrationArea
                    .padding(.horizontal, 36)

                Spacer().frame(height: 32)

                // ── テンプレート選択（語り終わりに出現）
                if showTemplates {
                    templateChoices
                        .padding(.horizontal, 24)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // ── 「過去の幻装を見る」─────────────
                if showGalleryLink {
                    Button(action: onComplete) {
                        Text("過去の幻装を見る")
                            .font(.system(size: 11, weight: .light))
                            .foregroundStyle(Color(hex: "8A7A5A").opacity(0.7))
                            .padding(.top, 16)
                    }
                    .transition(.opacity)
                }

                Spacer()
            }

            // ── 戻るボタン ──────────────────────────
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16))
                    .foregroundStyle(Color(hex: "7A6A4A"))
                    .frame(width: 44, height: 44)
            }
            .padding(.top, 52)
            .padding(.leading, 8)
        }
        .fullScreenCover(item: $activeEntry) { entry in
            NavigationStack {
                WorkshopView(entry: entry)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) { appeared = true }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                startTypewriter()
            }
        }
    }

    // MARK: - ルーフェンの存在感（灯）

    private var ruufenPresence: some View {
        ZStack {
            // 外側のグロー
            ForEach([0, 1, 2], id: \.self) { i in
                Circle()
                    .fill(Color(hex: "C89040").opacity(glowPulse ? 0.04 - Double(i) * 0.01 : 0.02))
                    .frame(width: CGFloat(140 + i * 55), height: CGFloat(140 + i * 55))
                    .blur(radius: CGFloat(14 + i * 8))
            }

            // 核（フローライト石を模した温かい光）
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "D4A860").opacity(0.5),
                                     Color(hex: "8A6020").opacity(0.15),
                                     .clear],
                            center: .center, startRadius: 0, endRadius: 40
                        )
                    )
                    .frame(width: 80, height: 80)
                    .blur(radius: 12)
                    .scaleEffect(glowPulse ? 1.12 : 0.95)

                // 六角形ダイヤ（石）
                AtelierGemShape()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "D4A860"), Color(hex: "8A5A18")],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .overlay(
                        AtelierGemShape()
                            .stroke(Color(hex: "E8C880").opacity(0.8), lineWidth: 0.8)
                    )
                    .frame(width: 26, height: 26)
                    .shadow(color: Color(hex: "C89040").opacity(glowPulse ? 0.9 : 0.5), radius: 12)
                    .scaleEffect(glowPulse ? 1.08 : 1.0)
            }
            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: glowPulse)
        }
        .frame(height: 140)
    }

    // MARK: - 語りかけエリア

    private var narrationArea: some View {
        VStack(alignment: .leading, spacing: 18) {
            ForEach(visibleLines.indices, id: \.self) { i in
                Text(visibleLines[i])
                    .font(.system(size: 15, weight: .thin, design: .serif))
                    .foregroundStyle(Color(hex: "C8B890"))
                    .lineSpacing(8)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: "0D0A06").opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color(hex: "6A5020").opacity(0.35), lineWidth: 0.8)
                )
        )
    }

    // MARK: - テンプレート選択

    private var templateChoices: some View {
        VStack(spacing: 14) {
            Text("姿を選んでください")
                .font(.system(size: 10, weight: .light))
                .foregroundStyle(Color(hex: "8A7A5A"))
                .tracking(2)

            // 人型 3種（中性・男性・女性）
            HStack(spacing: 10) {
                ForEach(0..<3, id: \.self) { i in
                    let (template, label, icon) = templates[i]
                    TemplateChoiceCard(
                        label: label,
                        icon:  icon,
                        delay: Double(i) * 0.10
                    ) {
                        beginDrawing(template: template)
                    }
                }
            }

            // 異型 2種（獣・翼）
            HStack(spacing: 10) {
                ForEach(3..<5, id: \.self) { i in
                    let (template, label, icon) = templates[i]
                    TemplateChoiceCard(
                        label: label,
                        icon:  icon,
                        delay: Double(i) * 0.10
                    ) {
                        beginDrawing(template: template)
                    }
                }
            }
            .padding(.horizontal, 40)
        }
    }

    // MARK: - 行フェード表示

    private func startTypewriter() {
        guard lineIndex < narrationLines.count else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.75)) {
                    showTemplates = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                withAnimation(.easeIn(duration: 0.5)) { showGalleryLink = true }
            }
            return
        }

        let line = narrationLines[lineIndex]
        withAnimation(.easeOut(duration: 1.1)) {
            visibleLines.append(line)
        }
        lineIndex += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            startTypewriter()
        }
    }

    // MARK: - WorkshopView を開く

    private func beginDrawing(template: GuideTemplate) {
        let entry = DrawingEntry(title: "幻装", guideId: template.rawValue)
        context.insert(entry)
        try? context.save()
        activeEntry = entry
    }
}

// MARK: - テンプレート選択カード

private struct TemplateChoiceCard: View {
    let label:   String
    let icon:    String
    let delay:   Double
    let onTap:   () -> Void

    @State private var appeared  = false
    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "C89040").opacity(0.08))
                        .frame(width: 58, height: 58)
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundStyle(Color(hex: "C8A060"))
                }
                Text(label)
                    .font(.system(size: 12, weight: .light, design: .serif))
                    .foregroundStyle(Color(hex: "D4C090"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: "100D08"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "6A5020").opacity(isPressed ? 0.8 : 0.4), lineWidth: 1)
                    )
                    .shadow(color: Color(hex: "C89040").opacity(isPressed ? 0.25 : 0.08), radius: 10)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.94 : (appeared ? 1.0 : 0.85))
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(delay), value: appeared)
        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded   { _ in isPressed = false }
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                appeared = true
            }
        }
    }
}

// MARK: - 幻装ギャラリー（過去の作品一覧）

struct PhantasmGalleryView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss)      private var dismiss
    @Query(sort: \DrawingEntry.updatedAt, order: .reverse) private var drawings: [DrawingEntry]

    @State private var activeEntry:   DrawingEntry? = nil
    @State private var appeared       = false
    @AppStorage("hasSeenAtelierIntro") private var hasSeenIntro = false

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(hex: "080603").ignoresSafeArea()
            AtelierAmbience()

            VStack(alignment: .leading, spacing: 0) {

                // ナビゲーションバー
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16))
                            .foregroundStyle(Color(hex: "7A6A4A"))
                            .frame(width: 44, height: 44)
                    }
                    Spacer()
                    TitleBannerView(title: "幻装の仕立て処", subtitle: "PHANTASM-SHELL ATELIER")
                        .colorMultiply(Color(hex: "D4C090"))
                        .frame(maxWidth: 260)
                    Spacer()
                    // バランス用
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.top, 52)
                .padding(.horizontal, 8)

                if drawings.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(drawings) { entry in
                                VesselThumbnailCard(entry: entry) {
                                    activeEntry = entry
                                }
                                .opacity(appeared ? 1 : 0)
                                .animation(.easeOut(duration: 0.5)
                                    .delay(Double(drawings.firstIndex(where: { $0.id == entry.id }) ?? 0) * 0.06),
                                    value: appeared
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 100)
                    }
                }
            }

            // 新規作成 FAB
            Button {
                let e = DrawingEntry(title: "幻装")
                context.insert(e)
                try? context.save()
                activeEntry = e
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(hex: "1A1408"))
                        .overlay(Circle().stroke(Color(hex: "8A6A2A"), lineWidth: 1))
                        .frame(width: 56, height: 56)
                        .shadow(color: Color(hex: "C89040").opacity(0.3), radius: 14)
                    Image(systemName: "plus")
                        .font(.system(size: 20))
                        .foregroundStyle(Color(hex: "D4A860"))
                }
            }
            .padding(28)
        }
        .fullScreenCover(item: $activeEntry) { entry in
            NavigationStack { WorkshopView(entry: entry) }
        }
        .navigationBarHidden(true)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { appeared = true }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            AtelierGemShape()
                .fill(Color(hex: "4A3A18").opacity(0.4))
                .frame(width: 48, height: 48)
            Text("まだ幻装がありません\n＋ ボタンから仕立てを始めましょう")
                .font(.system(size: 13, weight: .light))
                .foregroundStyle(Color(hex: "3A3020"))
                .multilineTextAlignment(.center)
                .lineSpacing(7)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 漂う設計書

private struct FloatingPapersView: View {
    let size: CGSize

    private let layout: [(x: Double, y: Double, rot: Double, scale: Double, delay: Double)] = [
        (0.12, 0.18, -14, 0.30, 0.0),
        (0.78, 0.12,   9, 0.28, 0.5),
        (0.85, 0.58,  -6, 0.26, 1.0),
        (0.08, 0.72,  13, 0.29, 0.3),
        (0.58, 0.80,  -8, 0.27, 0.8),
        (0.42, 0.40,   5, 0.25, 0.6),
    ]
    private let names = [
        "phantasm1.png","phantasm2.png","phantasm3.png",
        "phantasm4.png","phantasm5.png","phantasm6.png"
    ]

    var body: some View {
        ZStack {
            ForEach(0..<layout.count, id: \.self) { i in
                FloatingPaper(
                    imageName: names[i],
                    baseX:  size.width  * layout[i].x,
                    baseY:  size.height * layout[i].y,
                    baseRot: layout[i].rot,
                    scale:  CGFloat(layout[i].scale),
                    delay:  layout[i].delay,
                    width:  size.width
                )
            }
        }
    }
}

private struct FloatingPaper: View {
    let imageName: String
    let baseX:    CGFloat
    let baseY:    CGFloat
    let baseRot:  Double
    let scale:    CGFloat
    let delay:    Double
    let width:    CGFloat

    @State private var driftX: CGFloat = 0
    @State private var driftY: CGFloat = 0
    @State private var tilt:   Double  = 0
    @State private var flipY:  Double  = 0

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: width * scale)
            .clipShape(RoundedRectangle(cornerRadius: 3))
            .shadow(color: Color.black.opacity(0.4), radius: 12, x: 4, y: 8)
            .opacity(0.68)
            .rotation3DEffect(.degrees(flipY), axis: (x: 0, y: 1, z: 0), perspective: 0.35)
            .rotationEffect(.degrees(baseRot + tilt))
            .offset(x: driftX, y: driftY)
            .position(x: baseX, y: baseY)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 4.2 + delay * 0.7)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    driftX = baseRot > 0 ?  20 : -20
                    driftY = -24 - CGFloat(delay) * 4
                    tilt   = baseRot > 0 ?   7 :  -7
                }
                withAnimation(
                    .easeInOut(duration: 2.8 + delay * 0.5)
                    .repeatForever(autoreverses: true)
                    .delay(delay + 1.0)
                ) {
                    flipY = baseRot > 0 ? 22 : -22
                }
            }
    }
}

// MARK: - アトリエ専用ジェムシェイプ（六角形）

struct AtelierGemShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        let cx = rect.midX, cy = rect.midY
        let r  = min(w, h) * 0.48
        var p  = Path()
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3 - .pi / 6
            let pt = CGPoint(x: cx + r * cos(angle), y: cy + r * sin(angle))
            i == 0 ? p.move(to: pt) : p.addLine(to: pt)
        }
        p.closeSubpath()
        return p
    }
}

// MARK: - アトリエ背景（蜃気楼のような琥珀の埃）

struct AtelierAmbience: View {
    @State private var particles: [AP] = []

    struct AP: Identifiable {
        let id    = UUID()
        var x, y, size, speed, phase: CGFloat
        var hue: CGFloat  // 色相の微妙な差異
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate
                for p in particles {
                    let wave    = (sin(Double(t) * Double(p.speed) + Double(p.phase)) + 1) * 0.5
                    let opacity = 0.04 + wave * 0.10
                    let dx      = sin(Double(t) * Double(p.speed) * 0.4 + Double(p.phase)) * 8
                    let dy      = CGFloat(t) * p.speed * 5
                    let py      = (p.y - dy).truncatingRemainder(dividingBy: size.height + 20)
                    let ay      = py < -10 ? py + size.height + 20 : py
                    let color   = Color(hue: Double(p.hue), saturation: 0.55, brightness: 0.75)
                    ctx.fill(
                        Path(ellipseIn: CGRect(x: p.x + CGFloat(dx) - p.size/2,
                                              y: ay - p.size/2,
                                              width: p.size, height: p.size)),
                        with: .color(color.opacity(opacity))
                    )
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onAppear {
            let s = UIScreen.main.bounds
            particles = (0..<38).map { _ in
                AP(
                    x:     .random(in: 0...s.width),
                    y:     .random(in: 0...s.height),
                    size:  .random(in: 1.0...3.0),
                    speed: .random(in: 0.005...0.016),
                    phase: .random(in: 0...(.pi * 2)),
                    hue:   .random(in: 0.08...0.14)   // 琥珀〜金色の色相帯
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        PhantasmAtelierView()
    }
    .modelContainer(for: DrawingEntry.self, inMemory: true)
}
