import SwiftUI
import SwiftData
import PhotosUI

// MARK: - Screen 5: 五感の標本箱

struct SensorySpecimenView: View {

    @Environment(\.modelContext) private var context
    @Query(sort: \SensoryEntry.updatedAt, order: .reverse) private var allEntries: [SensoryEntry]

    @State private var addingCategory:    SensoryCategory? = nil
    @State private var viewingCategory:   SensoryCategory? = nil
    @State private var showAllEntries     = false
    @State private var showCategoryPicker = false
    @State private var appeared           = false

    // 最近の標本（全カテゴリー）
    private var recentSpecimen: [SensoryEntry] {
        Array(allEntries.prefix(6))
    }

    var body: some View {
        ZStack {
            Color(hex: "050810").ignoresSafeArea()
            SpecimenAmbience()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    specimenHeader
                    specimenBoxSection
                    shelfPlank
                    recentSection
                }
                .padding(.bottom, 60)
            }

        }
        .navigationTitle("五感の標本箱")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            withAnimation(.easeOut(duration: 0.9).delay(0.2)) { appeared = true }
        }
        // 採取シート
        .sheet(item: $addingCategory) { cat in
            SpecimenCaptureSheet(category: cat)
        }
        // カテゴリー一覧シート
        .sheet(item: $viewingCategory) { cat in
            NavigationStack {
                CategorySpecimenListView(
                    category: cat,
                    entries: allEntries.filter { $0.category == cat }
                )
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        // 全エントリ一覧
        .sheet(isPresented: $showAllEntries) {
            NavigationStack { ArchiveView() }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        // 空きスロットタップ → カテゴリー選択
        .confirmationDialog("どの感覚の標本を採取しますか？",
                            isPresented: $showCategoryPicker,
                            titleVisibility: .visible) {
            ForEach(SensoryCategory.allCases, id: \.self) { cat in
                Button(cat.label) { addingCategory = cat }
            }
            Button("キャンセル", role: .cancel) {}
        }
    }

    // MARK: - ヘッダー

    private var specimenHeader: some View {
        VStack(spacing: 16) {
            Text("SENSORY SPECIMENS")
                .font(.system(size: 9, weight: .light))
                .foregroundStyle(Color(hex: "3A4A6A").opacity(0.8))
                .tracking(3)
                .padding(.top, 28)

            // タイトルバナー
            TitleBannerView(title: "五感の標本箱", subtitle: "感覚の欠片を、瓶に封じ込める")
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 8)
                .animation(.easeOut(duration: 0.7).delay(0.15), value: appeared)
                .padding(.bottom, 12)
        }
    }

    // MARK: - 標本箱セクション（メイン）

    private var specimenBoxSection: some View {
        SpecimenBoxView(
            entries:    allEntries,
            onTapEntry: { entry in viewingCategory = entry.category },
            onTapEmpty: { showCategoryPicker = true },
            onTapFixed: { cat in addingCategory = cat }
        )
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.9).delay(0.2), value: appeared)
    }

    // MARK: - 木製棚板

    private var shelfPlank: some View {
        ZStack(alignment: .top) {
            // 板本体
            Rectangle()
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color(hex: "4A3018"), location: 0.0),
                            .init(color: Color(hex: "321E0C"), location: 0.35),
                            .init(color: Color(hex: "201208"), location: 1.0)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(height: 18)
                .shadow(color: Color.black.opacity(0.6), radius: 6, y: 3)

            // 上辺ハイライト（木の艶）
            Rectangle()
                .fill(Color(hex: "7A5530").opacity(0.45))
                .frame(height: 1.5)
        }
        .padding(.top, 4)
    }

    // MARK: - 最近の標本

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 7) {
                    Image(systemName: "clock")
                        .font(.system(size: 11))
                        .foregroundStyle(Color(hex: "3A5A6A"))
                    Text("最近の標本")
                        .font(.system(size: 13, weight: .light))
                        .foregroundStyle(Color(hex: "7A8A9A"))
                        .tracking(1)
                }
                Spacer()
                Button { showAllEntries = true } label: {
                    HStack(spacing: 4) {
                        Text("すべて見る")
                            .font(.system(size: 11, weight: .light))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10))
                    }
                    .foregroundStyle(Color(hex: "3A6B9E"))
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 28)

            if recentSpecimen.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 32))
                        .foregroundStyle(Color(hex: "2A3A4A"))
                    Text("まだ標本がありません\n瓶をタップして最初の標本を採取しましょう")
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(Color(hex: "2A3A4A"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(recentSpecimen) { entry in
                    SpecimenEntryRow(entry: entry) {
                        viewingCategory = entry.category
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
    }
}

// MARK: - 標本瓶カード

struct SpecimenJarCard: View {
    let category:   SensoryCategory
    let entryCount: Int
    let onTap:      () -> Void
    let onLongPress:() -> Void

    @State private var isPressed = false
    @State private var pulseGlow = false

    private var fillLevel: CGFloat {
        min(CGFloat(entryCount) / 18.0, 0.72)
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {

                // コルク
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "9A7040"), Color(hex: "6A4820")],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color(hex: "4A3010").opacity(0.8), lineWidth: 0.5)
                    )
                    .frame(width: 24, height: 10)
                    .shadow(color: Color.black.opacity(0.4), radius: 2, y: 1)

                // 瓶本体
                ZStack {
                    // ガラス中身（液体＋パーティクル）
                    JarParticleCanvas(category: category, fillLevel: fillLevel)
                        .clipShape(JarBodyShape())

                    // ガラス外枠
                    JarBodyShape()
                        .fill(Color.white.opacity(0.04))
                    JarBodyShape()
                        .stroke(
                            category.color.opacity(pulseGlow ? 0.55 : 0.30),
                            lineWidth: 1.2
                        )

                    // ガラスの光沢（左上ハイライト）
                    JarBodyShape()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.10), Color.clear],
                                startPoint: UnitPoint(x: 0.1, y: 0.05),
                                endPoint:   UnitPoint(x: 0.5, y: 0.55)
                            )
                        )

                    // エントリ数バッジ
                    if entryCount > 0 {
                        VStack {
                            HStack {
                                Spacer()
                                Text("\(entryCount)")
                                    .font(.system(size: 9, weight: .light))
                                    .foregroundStyle(category.color)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule().fill(category.color.opacity(0.15))
                                    )
                                    .padding(.top, 14)
                                    .padding(.trailing, 10)
                            }
                            Spacer()
                        }
                    }
                }
                .frame(width: 88, height: 120)

                // カテゴリー名
                Text(category.label)
                    .font(.system(size: 12, weight: .light, design: .serif))
                    .foregroundStyle(category.color)
                    .padding(.top, 8)

                Text("タップで採取")
                    .font(.system(size: 9, weight: .light))
                    .foregroundStyle(category.color.opacity(0.40))
                    .padding(.top, 2)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.94 : 1.0)
        .animation(.spring(response: 0.28, dampingFraction: 0.65), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded   { _ in isPressed = false }
        )
        .onLongPressGesture(minimumDuration: 0.5) { onLongPress() }
        .onAppear {
            withAnimation(
                .easeInOut(duration: Double.random(in: 1.8...2.6))
                    .repeatForever(autoreverses: true)
                    .delay(Double.random(in: 0...0.6))
            ) { pulseGlow = true }
        }
    }
}

// MARK: - 瓶のシェイプ

struct JarBodyShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w  = rect.width
        let h  = rect.height
        let cx = rect.midX

        let lipHW:  CGFloat = w * 0.40
        let neckHW: CGFloat = w * 0.22
        let bodyHW: CGFloat = w * 0.48

        let y0 = rect.minY              // 口元上端
        let y1 = y0 + h * 0.07         // 口元下端 / ネック上端
        let y2 = y1 + h * 0.18         // ネック下端 / 肩上端
        let y3 = y2 + h * 0.10         // 肩下端 / 胴体上端
        let y4 = rect.maxY - h * 0.09  // 底丸み開始
        let yB = rect.maxY             // 底中心

        var p = Path()
        p.move(to: CGPoint(x: cx - lipHW, y: y0))
        p.addLine(to: CGPoint(x: cx + lipHW, y: y0))    // 口元上辺
        p.addLine(to: CGPoint(x: cx + lipHW, y: y1))    // 口元右辺
        p.addLine(to: CGPoint(x: cx + neckHW, y: y1))   // ネックへの段差（右）
        p.addLine(to: CGPoint(x: cx + neckHW, y: y2))   // ネック右辺
        // 肩のベジェ（右）
        p.addCurve(
            to:       CGPoint(x: cx + bodyHW, y: y3),
            control1: CGPoint(x: cx + neckHW, y: y2 + (y3 - y2) * 0.6),
            control2: CGPoint(x: cx + bodyHW, y: y2 + (y3 - y2) * 0.4)
        )
        p.addLine(to: CGPoint(x: cx + bodyHW, y: y4))   // 胴体右辺
        // 底丸み
        p.addQuadCurve(
            to:      CGPoint(x: cx - bodyHW, y: y4),
            control: CGPoint(x: cx, y: yB + h * 0.03)
        )
        p.addLine(to: CGPoint(x: cx - bodyHW, y: y3))   // 胴体左辺
        // 肩のベジェ（左）
        p.addCurve(
            to:       CGPoint(x: cx - neckHW, y: y2),
            control1: CGPoint(x: cx - bodyHW, y: y2 + (y3 - y2) * 0.4),
            control2: CGPoint(x: cx - neckHW, y: y2 + (y3 - y2) * 0.6)
        )
        p.addLine(to: CGPoint(x: cx - neckHW, y: y1))   // ネック左辺
        p.addLine(to: CGPoint(x: cx - lipHW,  y: y1))   // ネックから口元段差（左）
        p.addLine(to: CGPoint(x: cx - lipHW,  y: y0))   // 口元左辺
        p.closeSubpath()
        return p
    }
}

// MARK: - 瓶内パーティクル＋液体

private struct JarParticleCanvas: View {
    let category:  SensoryCategory
    let fillLevel: CGFloat

    @State private var particles: [JP] = []

    struct JP: Identifiable {
        let id    = UUID()
        var xNorm:  CGFloat  // 0–1
        var phase:  Double
        var size:   CGFloat
        var speed:  CGFloat
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack(alignment: .bottom) {
                // 液体（下から fillLevel 分）
                LinearGradient(
                    colors: [
                        category.color.opacity(0.50),
                        category.color.opacity(0.20)
                    ],
                    startPoint: .bottom, endPoint: .top
                )
                .frame(height: h * fillLevel)
                .animation(.spring(response: 1.0, dampingFraction: 0.8), value: fillLevel)

                // パーティクル（液体より上に浮く）
                TimelineView(.animation(minimumInterval: 1.0 / 24.0)) { tl in
                    Canvas { ctx, size in
                        let t = tl.date.timeIntervalSinceReferenceDate
                        for p in particles {
                            let elapsed  = CGFloat(t) * p.speed + CGFloat(p.phase)
                            let progress = elapsed.truncatingRemainder(dividingBy: 1.0)
                            let py       = size.height * (1.0 - progress) * 0.90 + size.height * 0.05
                            let px       = size.width * p.xNorm + sin(t * 0.6 + p.phase * 2.5) * 3
                            let opacity  = Double(sin(.pi * Double(progress))) * 0.45
                            guard opacity > 0.02 else { continue }
                            let r = CGRect(x: px - p.size/2, y: py - p.size/2,
                                           width: p.size, height: p.size)
                            drawParticle(&ctx, category: category,
                                         px: px, py: py, size: p.size,
                                         phase: p.phase, opacity: opacity, time: t, baseRect: r)
                        }
                    }
                    .frame(width: w, height: h)
                }
            }
        }
        .onAppear {
            particles = (0..<10).map { i in
                JP(
                    xNorm: CGFloat(i) / 10.0 + CGFloat.random(in: -0.04...0.04),
                    phase: Double(i) / 10.0,
                    size:  CGFloat.random(in: 2.5...5.0),
                    speed: CGFloat.random(in: 0.04...0.09)
                )
            }
        }
    }

    // Canvas 内から呼び出すことでコンパイラの型推論負荷を分散
    private func drawParticle(
        _ ctx:      inout GraphicsContext,
        category:   SensoryCategory,
        px:         CGFloat,
        py:         CGFloat,
        size:       CGFloat,
        phase:      Double,
        opacity:    Double,
        time:       Double,
        baseRect r: CGRect
    ) {
        let col = category.color
        switch category {
        case .sound:
            ctx.fill(Path(ellipseIn: r), with: .color(col.opacity(opacity)))

        case .taste:
            let drop = CGRect(x: r.minX, y: r.minY - r.height * 0.3,
                              width: r.width, height: r.height * 1.4)
            ctx.fill(Path(ellipseIn: drop), with: .color(col.opacity(opacity)))

        case .scent:
            ctx.translateBy(x: px, y: py)
            ctx.rotate(by: .degrees(30))
            ctx.fill(Path(ellipseIn: CGRect(x: -size*0.4, y: -size*0.7,
                                            width: size*0.8, height: size*1.4)),
                     with: .color(col.opacity(opacity)))
            ctx.rotate(by: .degrees(-30))
            ctx.translateBy(x: -px, y: -py)

        case .texture:
            ctx.translateBy(x: px, y: py)
            ctx.rotate(by: .degrees(45))
            ctx.fill(Path(CGRect(x: -size*0.4, y: -size*0.4,
                                 width: size*0.8, height: size*0.8)),
                     with: .color(col.opacity(opacity)))
            ctx.rotate(by: .degrees(-45))
            ctx.translateBy(x: -px, y: -py)

        case .dream:
            let angle = time * 0.5 + phase * 1.8
            ctx.translateBy(x: px, y: py)
            ctx.rotate(by: .degrees(angle * 57.3))
            ctx.fill(Path(ellipseIn: CGRect(x: -size*0.3, y: -size*0.8,
                                            width: size*0.6, height: size*1.6)),
                     with: .color(col.opacity(opacity * 0.85)))
            ctx.rotate(by: .degrees(-angle * 57.3))
            ctx.translateBy(x: -px, y: -py)

        case .place:
            var pin = Path()
            pin.addEllipse(in: CGRect(x: px-size*0.5, y: py-size, width: size, height: size))
            pin.move(to:    CGPoint(x: px-size*0.28, y: py-size*0.1))
            pin.addLine(to: CGPoint(x: px+size*0.28, y: py-size*0.1))
            pin.addLine(to: CGPoint(x: px,           y: py+size*0.5))
            pin.closeSubpath()
            ctx.fill(pin, with: .color(col.opacity(opacity)))

        case .time:
            let s = CGRect(x: px-size*0.28, y: py-size*0.28,
                           width: size*0.56, height: size*0.56)
            ctx.fill(Path(ellipseIn: s), with: .color(col.opacity(opacity * 1.2)))

        case .warmth:
            let w = CGRect(x: px-size*0.75, y: py-size*0.75,
                           width: size*1.5, height: size*1.5)
            ctx.fill(Path(ellipseIn: w), with: .color(col.opacity(opacity * 0.55)))

        default:
            ctx.fill(Path(ellipseIn: r), with: .color(col.opacity(opacity)))
        }
    }
}

// MARK: - 採取シート（テーマ付き）

struct SpecimenCaptureSheet: View {
    let category: SensoryCategory

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss)      private var dismiss

    @State private var title         = ""
    @State private var bodyText      = ""
    @State private var recordedDate  = Date()
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var uiImage:       UIImage?           = nil
    @State private var imageData:     Data?              = nil

    // 印章演出
    @State private var showSeal      = false
    @State private var sealScale:    CGFloat = 1.5
    @State private var sealOpacity:  Double  = 0
    @State private var dimOpacity:   Double  = 0

    var body: some View {
        ZStack {
            // 紙の余白色
            Color(hex: "EDE4D0").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {

                    // ── シートヘッダー ───────────────────
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(category.color.opacity(0.15))
                                .frame(width: 80, height: 80)
                            Image(systemName: category.icon)
                                .font(.system(size: 30))
                                .foregroundStyle(category.color)
                        }
                        Text("\(category.label)の標本を採取する")
                            .font(.system(size: 18, weight: .thin, design: .serif))
                            .foregroundStyle(Color(hex: "2A1808"))
                        Text(category.specimenPrompt)
                            .font(.system(size: 12, weight: .light))
                            .foregroundStyle(Color(hex: "6A4A28"))
                            .multilineTextAlignment(.center)
                            .lineSpacing(5)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 36)
                    .padding(.bottom, 8)

                    // ── タイトル ─────────────────────────
                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel("標本名")
                        TextField(
                            "",
                            text: $title,
                            prompt: Text(category.specimenPlaceholder)
                                .foregroundColor(Color(hex: "A09070"))
                        )
                        .font(.system(size: 19, weight: .thin, design: .serif))
                        .foregroundStyle(Color(hex: "2A1808"))
                        .padding(.vertical, 8)
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .fill(category.color.opacity(0.5))
                                .frame(height: 0.7)
                        }
                    }

                    // ── 日付 ─────────────────────────────
                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel("感覚を覚えた日")
                        DatePicker("", selection: $recordedDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .colorScheme(.light)
                            .tint(category.color)
                    }

                    // ── 本文 ─────────────────────────────
                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel("記憶")
                        ZStack(alignment: .topLeading) {
                            if bodyText.isEmpty {
                                Text("感覚の詳細を言葉にしてみる…")
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundStyle(Color(hex: "A09070"))
                                    .padding(.top, 10)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                            }
                            TextEditor(text: $bodyText)
                                .font(.system(size: 14, weight: .light))
                                .foregroundStyle(Color(hex: "2A1808"))
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 110)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(hex: "F0E8D4").opacity(0.55))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 3)
                                        .stroke(category.color.opacity(0.30), lineWidth: 1)
                                )
                        )
                    }

                    // ── 写真添付 ─────────────────────────
                    if let img = uiImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    uiImage    = nil
                                    imageData  = nil
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundStyle(Color(hex: "4A3018").opacity(0.8))
                                        .padding(6)
                                }
                            }
                    } else {
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            HStack(spacing: 8) {
                                Image(systemName: "camera")
                                Text("記憶の写真を添付する")
                                    .font(.system(size: 13, weight: .light))
                            }
                            .foregroundStyle(category.color)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .overlay(
                                RoundedRectangle(cornerRadius: 2)
                                    .stroke(category.color.opacity(0.4), lineWidth: 1)
                            )
                        }
                    }

                    // ── 採取ボタン ───────────────────────
                    Button(action: triggerSeal) {
                        Text("標本を封じる")
                            .font(.system(size: 15, weight: .light, design: .serif))
                            .foregroundStyle(Color(hex: "2A1808"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(category.color.opacity(0.18))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 3)
                                            .stroke(category.color.opacity(0.7), lineWidth: 1)
                                    )
                            )
                    }
                    .disabled(title.isEmpty)
                    .opacity(title.isEmpty ? 0.45 : 1.0)

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 36)
                .padding(.vertical, 8)
                .background(
                    GeometryReader { geo in
                        Image("paper_texture.png")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                    }
                )
                .padding(.horizontal, 10)
                .padding(.vertical, 14)
            }

            // ── 印章演出オーバーレイ ─────────────────
            if showSeal {
                Color.black.opacity(dimOpacity * 0.45)
                    .ignoresSafeArea()
                    .allowsHitTesting(true)

                Image("seal_stamp.png")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 260)
                    .colorMultiply(category.color)
                    .opacity(sealOpacity)
                    .scaleEffect(sealScale)
            }
        }
        .onChange(of: selectedPhoto) { _, item in
            Task {
                guard let data = try? await item?.loadTransferable(type: Data.self) else { return }
                await MainActor.run {
                    imageData = data
                    uiImage   = UIImage(data: data)
                }
            }
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .light))
            .foregroundStyle(category.color.opacity(0.8))
            .tracking(2)
    }

    private func triggerSeal() {
        guard !title.isEmpty else { return }
        showSeal = true

        // 暗幕フェードイン
        withAnimation(.easeOut(duration: 0.12)) {
            dimOpacity = 1
        }
        // 印章スタンプ（上から押しつける）
        withAnimation(.spring(response: 0.28, dampingFraction: 0.55)) {
            sealScale   = 1.0
            sealOpacity = 1.0
        }
        // ハプティクス
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

        // 余韻 → フェードアウト → 保存
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            withAnimation(.easeIn(duration: 0.35)) {
                sealOpacity = 0
                dimOpacity  = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                save()
            }
        }
    }

    private func save() {
        let entry = SensoryEntry(
            title:        title,
            body:         bodyText,
            category:     category,
            recordedDate: recordedDate
        )
        entry.imageData = imageData
        context.insert(entry)
        try? context.save()
        dismiss()
    }
}

// MARK: - カテゴリー一覧シート

struct CategorySpecimenListView: View {
    let category: SensoryCategory
    let entries:  [SensoryEntry]

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss)      private var dismiss
    @State private var editingEntry: SensoryEntry? = nil

    var body: some View {
        ZStack {
            Color(hex: "060810").ignoresSafeArea()
            category.dimColor.opacity(0.5).ignoresSafeArea()

            if entries.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: category.icon)
                        .font(.system(size: 40))
                        .foregroundStyle(category.color.opacity(0.4))
                    Text("まだ「\(category.label)」の標本がありません")
                        .font(.system(size: 13, weight: .light))
                        .foregroundStyle(Color(hex: "3A4A5A"))
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(entries) { entry in
                            SpecimenEntryRow(entry: entry) {
                                editingEntry = entry
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.bottom, 40)
                    .padding(.top, 8)
                }
            }
        }
        .navigationTitle("\(category.label)の標本")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("閉じる") { dismiss() }
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(Color(hex: "7A8FAA"))
            }
        }
        .sheet(item: $editingEntry) { entry in
            NavigationStack {
                EntryEditorView(entry: entry) {
                    context.delete(entry)
                    try? context.save()
                }
            }
            .presentationDetents([.large])
        }
    }
}

// MARK: - 最近の標本行

struct SpecimenEntryRow: View {
    let entry:  SensoryEntry
    let onTap:  () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // カテゴリーカラーバー
                RoundedRectangle(cornerRadius: 1)
                    .fill(entry.category.color)
                    .frame(width: 2, height: 50)

                VStack(alignment: .leading, spacing: 5) {
                    // カテゴリーバッジ
                    HStack(spacing: 4) {
                        Image(systemName: entry.category.icon)
                            .font(.system(size: 9))
                        Text(entry.category.label)
                            .font(.system(size: 9, weight: .light))
                    }
                    .foregroundStyle(entry.category.color)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)
                    .background(entry.category.color.opacity(0.12))
                    .clipShape(Capsule())

                    // タイトル
                    Text(entry.title.isEmpty ? "（無題）" : entry.title)
                        .font(.system(size: 14, weight: .light, design: .serif))
                        .foregroundStyle(Color(hex: "C8D8F0"))
                        .lineLimit(1)
                }

                Spacer()

                // 日付
                Text(entry.recordedDate.formatted(
                    .dateTime.month(.abbreviated).day()
                        .locale(Locale(identifier: "ja_JP"))
                ))
                .font(.system(size: 10, weight: .light))
                .foregroundStyle(Color(hex: "3A4A5A"))

                // サムネイル
                if let data = entry.imageData, let img = UIImage(data: data) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(entry.category.dimColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(entry.category.color.opacity(0.15), lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 背景アンビエンス

private struct SpecimenAmbience: View {
    @State private var particles: [AP] = []

    struct AP: Identifiable {
        let id = UUID()
        var x, y, size, speed, phase: CGFloat
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate
                for p in particles {
                    let wave    = (sin(Double(t) * Double(p.speed) + Double(p.phase)) + 1) * 0.5
                    let opacity = 0.04 + wave * 0.08
                    let dy      = CGFloat(t) * p.speed * 7
                    let py      = (p.y - dy).truncatingRemainder(dividingBy: size.height + 20)
                    let ay      = py < -10 ? py + size.height + 20 : py
                    ctx.fill(
                        Path(ellipseIn: CGRect(x: p.x - p.size/2, y: ay - p.size/2,
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
            particles = (0..<35).map { _ in
                AP(
                    x:     .random(in: 0...s.width),
                    y:     .random(in: 0...s.height),
                    size:  .random(in: 1...2.5),
                    speed: .random(in: 0.006...0.016),
                    phase: .random(in: 0...(.pi * 2))
                )
            }
        }
    }
}


// MARK: - 浮遊デコ画像（汎用）

private struct FloatingDecoImage: View {
    let name:     String
    let width:    CGFloat
    let driftY:   CGFloat
    let rotFrom:  Double
    let rotTo:    Double
    let duration: Double
    let delay:    Double

    @State private var offsetY:  CGFloat = 0
    @State private var rotation: Double  = 0

    var body: some View {
        Image(name)
            .resizable()
            .scaledToFit()
            .frame(width: width)
            .offset(y: offsetY)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(
                    .easeInOut(duration: duration)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    offsetY  = driftY
                    rotation = rotTo
                }
                withAnimation(
                    .easeInOut(duration: duration * 0.8)
                    .repeatForever(autoreverses: true)
                    .delay(delay + 0.4)
                ) {
                    rotation = rotFrom
                }
            }
    }
}

// MARK: - 浮かぶトランク

private struct FloatingTrunkView: View {
    @State private var offsetY: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var glowOpacity: Double = 0.4

    var body: some View {
        ZStack {
            // 足元グロー
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [Color(red: 0.3, green: 0.5, blue: 0.8).opacity(glowOpacity), .clear],
                        center: .center, startRadius: 0, endRadius: 80
                    )
                )
                .frame(width: 180, height: 40)
                .blur(radius: 16)
                .offset(y: 80)

            // トランク画像
            Image("sensory_trunk.png")
                .resizable()
                .scaledToFit()
                .frame(height: 170)
                .offset(y: offsetY)
                .rotationEffect(.degrees(rotation))
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 3.2)
                .repeatForever(autoreverses: true)
            ) {
                offsetY   = -10
                rotation  = 1.5
            }
            withAnimation(
                .easeInOut(duration: 2.4)
                .repeatForever(autoreverses: true)
                .delay(0.6)
            ) {
                glowOpacity = 0.7
            }
        }
    }
}

// MARK: - 標本箱ビュー（画像＋コンパートメントオーバーレイ）

private struct SpecimenBoxView: View {
    let entries:     [SensoryEntry]
    let onTapEntry:  (SensoryEntry) -> Void
    let onTapEmpty:  () -> Void
    let onTapFixed:  (SensoryCategory) -> Void  // 固定カテゴリースロット空タップ

    /// 標本箱.png のおおよそのアスペクト比（横長）
    private let aspect: CGFloat = 1540.0 / 690.0

    /// 空きスロットに表示する装飾画像（スロットIndex → 画像名）
    private let decoSlots: [Int: String] = [
        2: "sensory_crystal.png",   // 小・中左下（鉱石）
        8: "sensory_feather.png",   // 中・左下（羽）
    ]

    /// スロットに固定カテゴリーを対応付け（イラストの雰囲気に合わせる）
    /// 対応するカテゴリーのエントリのみ表示するスロット
    private let fixedCategorySlots: [Int: SensoryCategory] = [
        0:  .sound,    // 大・左上  → 音
        5:  .taste,    // 大・右上  → 味
        6:  .scent,    // 小・左上  → 香
        7:  .scent,    // 小・左下  → 香
        9:  .texture,  // 大・中央下 → 触感
        11: .scenery,  // 小・右端  → 視覚（景色）
    ]

    /// 12コンパートメントの正規化座標 (x, y, w, h) — 画像サイズ基準 0〜1
    private let slots: [CGRect] = [
        // 上段
        CGRect(x: 0.025, y: 0.05, width: 0.245, height: 0.43), // 0 大・左
        CGRect(x: 0.278, y: 0.05, width: 0.107, height: 0.21), // 1 小・中左上
        CGRect(x: 0.278, y: 0.26, width: 0.107, height: 0.22), // 2 小・中左下
        CGRect(x: 0.393, y: 0.05, width: 0.177, height: 0.43), // 3 中・中央
        CGRect(x: 0.578, y: 0.05, width: 0.097, height: 0.43), // 4 細・瓶列
        CGRect(x: 0.683, y: 0.05, width: 0.287, height: 0.43), // 5 大・右
        // 下段
        CGRect(x: 0.025, y: 0.48, width: 0.095, height: 0.20), // 6 小・左上
        CGRect(x: 0.025, y: 0.68, width: 0.095, height: 0.20), // 7 小・左下
        CGRect(x: 0.128, y: 0.48, width: 0.257, height: 0.40), // 8 中・左
        CGRect(x: 0.393, y: 0.48, width: 0.282, height: 0.40), // 9 大・中央
        CGRect(x: 0.683, y: 0.48, width: 0.137, height: 0.40), // 10 中・右
        CGRect(x: 0.828, y: 0.48, width: 0.142, height: 0.40), // 11 小・右端
    ]

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = w / aspect

            ZStack(alignment: .topLeading) {
                // 標本箱の背景画像
                Image("specimen_box.png")
                    .resizable()
                    .scaledToFit()
                    .frame(width: w)

                // コンパートメントオーバーレイ
                ForEach(0..<slots.count, id: \.self) { i in
                    let s    = slots[i]
                    let rect = CGRect(
                        x: s.minX * w, y: s.minY * h,
                        width: s.width * w, height: s.height * h
                    )
                    // 固定カテゴリーが指定されているスロットはそのカテゴリーの最新エントリを表示
                    let slotEntry: SensoryEntry?
                    if let fixedCat = fixedCategorySlots[i] {
                        slotEntry = entries.first { $0.category == fixedCat }
                    } else {
                        // 固定なしスロット：固定スロットで使われていないエントリを順番に割り当て
                        let usedEntries = Set(fixedCategorySlots.values
                            .compactMap { cat in entries.first { $0.category == cat }?.id })
                        let freeEntries = entries.filter { !usedEntries.contains($0.id) }
                        let freeIndex   = i - fixedCategorySlots.count
                        slotEntry = freeIndex >= 0 && freeIndex < freeEntries.count
                            ? freeEntries[freeIndex] : nil
                    }
                    let deco = slotEntry == nil ? decoSlots[i] : nil

                    BoxSlotView(entry: slotEntry, decoImageName: deco) {
                        if let e = slotEntry { onTapEntry(e) }
                        else if let fixedCat = fixedCategorySlots[i] {
                            onTapFixed(fixedCat)
                        } else {
                            onTapEmpty()
                        }
                    }
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)
                }
            }
            .frame(width: w, height: h)
        }
        .aspectRatio(aspect, contentMode: .fit)
    }
}

// MARK: - コンパートメント単体ビュー

private struct BoxSlotView: View {
    let entry:         SensoryEntry?
    let decoImageName: String?
    let onTap:         () -> Void

    @State private var isPressed = false
    @State private var glow      = false

    var body: some View {
        Button(action: onTap) {
            ZStack {
                if let e = entry {
                    // ── 標本瓶 ＋ 紙ラベル ──────────────
                    VStack(spacing: 0) {
                        MiniSpecimenJar(category: e.category, glow: glow)
                            .padding(.horizontal, 7)
                            .padding(.top, 3)
                        PaperSlotLabel(title: e.title, category: e.category)
                            .padding(.horizontal, 4)
                            .padding(.bottom, 3)
                            .frame(height: 20)
                    }
                } else if let deco = decoImageName {
                    // ── 装飾画像（鉱石・羽など）────────
                    Image(deco)
                        .resizable()
                        .scaledToFit()
                        .opacity(0.75)
                        .padding(6)
                } else {
                    // ── 空きスロット — 薄い ＋ ──────────
                    Image(systemName: "plus")
                        .font(.system(size: 9, weight: .ultraLight))
                        .foregroundStyle(Color(hex: "C8B890").opacity(0.20))
                }
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.93 : 1.0)
        .animation(.spring(response: 0.22, dampingFraction: 0.65), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded   { _ in isPressed = false }
        )
        .onAppear {
            guard entry != nil else { return }
            withAnimation(
                .easeInOut(duration: Double.random(in: 1.8...2.8))
                .repeatForever(autoreverses: true)
                .delay(Double.random(in: 0...0.6))
            ) { glow = true }
        }
    }
}

// MARK: - ミニ標本瓶（GeometryReader 不使用 — VStack で直接レイアウト）

private struct MiniSpecimenJar: View {
    let category: SensoryCategory
    let glow:     Bool

    var body: some View {
        VStack(spacing: 0) {
            // コルク
            RoundedRectangle(cornerRadius: 2)
                .fill(LinearGradient(
                    colors: [Color(hex: "9A7040"), Color(hex: "6A4820")],
                    startPoint: .top, endPoint: .bottom
                ))
                .frame(height: 5)
                .padding(.horizontal, 14)  // コルクを瓶より細くする

            // 瓶本体
            ZStack {
                // 液体（下半分）
                JarBodyShape()
                    .fill(LinearGradient(
                        colors: [category.color.opacity(0.60), category.color.opacity(0.15)],
                        startPoint: .bottom, endPoint: .top
                    ))
                    .scaleEffect(x: 1.0, y: 0.52, anchor: .bottom)
                // ガラス外枠
                JarBodyShape().fill(Color.white.opacity(0.04))
                JarBodyShape()
                    .stroke(category.color.opacity(glow ? 0.82 : 0.48), lineWidth: 0.9)
                // ハイライト
                JarBodyShape()
                    .fill(LinearGradient(
                        colors: [Color.white.opacity(0.14), Color.clear],
                        startPoint: UnitPoint(x: 0.15, y: 0.08),
                        endPoint:   UnitPoint(x: 0.5,  y: 0.55)
                    ))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - 紙ラベル（スロット内）

private struct PaperSlotLabel: View {
    let title:    String
    let category: SensoryCategory

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 1)
                .fill(Color(hex: "F2EAD8"))
                .overlay(
                    RoundedRectangle(cornerRadius: 1)
                        .stroke(category.color.opacity(0.35), lineWidth: 0.4)
                )
            Text(title.isEmpty ? "???" : title)
                .font(.system(size: 6.5, weight: .light, design: .serif))
                .foregroundStyle(Color(hex: "3A2A14"))
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 3)
                .padding(.vertical, 1.5)
        }
        .frame(height: 18)
    }
}

#Preview {
    NavigationStack {
        SensorySpecimenView()
    }
    .modelContainer(for: SensoryEntry.self, inMemory: true)
}
