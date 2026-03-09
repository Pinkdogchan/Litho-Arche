import SwiftUI
import SwiftData
import PencilKit
import Photos

// MARK: - Screen 6: 魂の受肉ワークショップ

struct WorkshopView: View {

    @Bindable var entry: DrawingEntry
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.undoManager) private var undoManager

    @State private var drawing        = PKDrawing()
    @State private var canvasSize: CGSize = .zero
    @State private var toolPicker     = PKToolPicker()

    @State private var selectedGuide: GuideTemplate = .none
    @State private var guideOpacity:  Double        = 0.28
    @State private var showGuidePanel    = false
    @State private var isRulerActive     = false
    @State private var showSaveConfirm   = false
    @State private var showExportSuccess = false
    @State private var showSummonOverlay = false  // 召喚完了オーバーレイ

    // フェーズ管理
    @State private var phase: AtelierPhase = .outline
    // スパークバースト（描画時の魔法火花）
    @State private var sparkBursts: [(pos: CGPoint, birth: Date)] = []

    var body: some View {
        ZStack {
            Color(hex: "060810").ignoresSafeArea()
            CanvasAmbience()

            // ── キャンバスエリア ──────────────────────
            GeometryReader { geo in
                ZStack {
                    // ガイドテンプレート（型紙フェーズのみ）
                    if phase == .outline, selectedGuide != .none {
                        GuideTemplateView(template: selectedGuide)
                            .opacity(guideOpacity)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .allowsHitTesting(false)
                    }

                    // 染色カラーオーバーレイ
                    if !chosenColors.isEmpty {
                        colorTintOverlay.allowsHitTesting(false)
                    }

                    // PencilKit キャンバス（型紙フェーズのみタッチ有効）
                    PencilCanvasView(
                        drawing:       $drawing,
                        canvasSize:    $canvasSize,
                        isRulerActive: isRulerActive,
                        toolPicker:    toolPicker,
                        onStrokeAdded: { pt in addSparkBurst(at: pt) }
                    )
                    .allowsHitTesting(phase == .outline)

                    // スパークエフェクト（型紙フェーズ）
                    if phase == .outline {
                        sparkCanvas.allowsHitTesting(false)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color(hex: "2A3A50"), lineWidth: 0.5)
                )
            }
            .padding(EdgeInsets(top: 60, leading: 0, bottom: phase == .outline ? CGFloat(110) : CGFloat(66), trailing: 0))
            .animation(.spring(response: 0.3), value: phase)

            // ── UI バー ───────────────────────────────
            VStack {
                topBar
                Spacer()
                bottomBar
            }

            // ── フェーズパネル ──────────────────────────
            if phase == .colors   { colorPhasePanel   }
            if phase == .textures { texturePhasePanel }
            if phase == .vow      { vowPhaseOverlay   }

            // ── 召喚完了オーバーレイ ──────────────────
            if showSummonOverlay { summonOverlay }
        }
        .onAppear {
            drawing = entry.loadDrawing()
            // エントリのガイドIDをセレクターに反映
            if let g = GuideTemplate(rawValue: entry.guideId), g != .none {
                selectedGuide = g
            }
        }
        .confirmationDialog("保存方法を選んでください", isPresented: $showSaveConfirm, titleVisibility: .visible) {
            Button("プロジェクトに保存") { saveToProject() }
            Button("カメラロールに書き出し") { exportToPhotos() }
            Button("キャンセル", role: .cancel) {}
        }
        .overlay(exportSuccessBanner)
    }

    // MARK: - 染色オーバーレイ

    @ViewBuilder
    private var colorTintOverlay: some View {
        let colors = chosenColors.map { Color(hex: $0) }
        if !colors.isEmpty {
            LinearGradient(
                colors: colors.count > 1 ? colors : [colors[0], colors[0].opacity(0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .blendMode(.softLight)
            .opacity(0.38)
        }
    }

    // MARK: - スパークキャンバス

    private var sparkCanvas: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { tl in
            Canvas { ctx, _ in
                let sparkHexes = ["FFD700", "C8D8FF", "7ACCE0", "B07AFF", "FF70A0", "4AFF7A", "FFFFFF", "FF8A00"]
                for burst in sparkBursts {
                    let age = tl.date.timeIntervalSince(burst.birth)
                    guard age >= 0, age < 0.85 else { continue }
                    let t     = CGFloat(age / 0.85)
                    let alpha = Double(1 - t) * 0.9
                    let dist  = t * 28
                    for i in 0..<8 {
                        let angle = Double(i) * .pi / 4
                        let hex   = sparkHexes[i]
                        let ex    = burst.pos.x + CGFloat(cos(angle)) * dist
                        let ey    = burst.pos.y + CGFloat(sin(angle)) * dist
                        var path  = Path()
                        path.move(to: burst.pos)
                        path.addLine(to: CGPoint(x: ex, y: ey))
                        ctx.stroke(path, with: .color(Color(hex: hex).opacity(alpha)),
                                   lineWidth: max(0.3, 1.4 * (1 - Double(t))))
                    }
                    let r = CGFloat(6 * (1 - t))
                    ctx.fill(
                        Path(ellipseIn: CGRect(x: burst.pos.x - r, y: burst.pos.y - r, width: r*2, height: r*2)),
                        with: .color(Color.white.opacity(alpha * 0.55))
                    )
                }
            }
        }
    }

    // MARK: - 染色フェーズパネル

    private let beautifulColors: [(hex: String, name: String)] = [
        ("4AFF7A", "蛍の緑"),   ("00FFB0", "深海の光"),  ("76FF03", "電光草"),   ("AFFF2A", "草原の朝"),
        ("7ACCE0", "水晶"),     ("B07AFF", "紫晶"),      ("FF70A0", "薔薇石英"), ("FFD700", "黄金"),
        ("2A4AFF", "深夜"),     ("FF4AD0", "オーロラ"),  ("4AFFD8", "極光"),     ("FF8A00", "琥珀炎"),
        ("00BFFF", "空の欠片"), ("1AFFB2", "海硝子"),    ("80D4FF", "氷晶"),     ("FF5080", "珊瑚")
    ]

    private var colorPhasePanel: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("染色 — 美しい色を流し込む")
                        .font(.system(size: 11, weight: .light))
                        .foregroundStyle(Color(hex: "7ACCE0"))
                        .tracking(1.5)
                    Spacer()
                    if !chosenColors.isEmpty {
                        Button { entry.chosenColorHexes = "" } label: {
                            Text("クリア")
                                .font(.system(size: 10, weight: .light))
                                .foregroundStyle(Color(hex: "7A4A4A"))
                        }
                    }
                }
                .padding(.horizontal, 20)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 8), spacing: 10) {
                    ForEach(beautifulColors, id: \.hex) { color in
                        let isChosen = chosenColors.contains(color.hex)
                        Button { toggleColor(color.hex) } label: {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: color.hex))
                                    .shadow(color: Color(hex: color.hex).opacity(isChosen ? 0.7 : 0.2),
                                            radius: isChosen ? 10 : 3)
                                if isChosen {
                                    Circle().stroke(Color.white.opacity(0.9), lineWidth: 2)
                                }
                            }
                            .frame(width: 34, height: 34)
                            .scaleEffect(isChosen ? 1.15 : 1.0)
                            .animation(.spring(response: 0.3), value: isChosen)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 20)
            .background(
                Color(hex: "060A14").opacity(0.97)
                    .overlay(Rectangle().fill(Color(hex: "1A2A3A")).frame(height: 0.5), alignment: .top)
            )
        }
        .ignoresSafeArea(edges: .bottom)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - 質感フェーズパネル

    private let textureOptions: [(id: String, name: String, desc: String, hex: String)] = [
        ("calcite", "カルサイト", "なめらかな乳白", "F0ECE4"),
        ("crystal", "水晶",      "透明な輝き",     "C0D8F0"),
        ("peach",   "桃の肌",    "やわらかく温かい", "FFD4B0"),
        ("plush",   "ぬいぐるみ", "もふもふの毛並み", "C8A880")
    ]

    private var texturePhasePanel: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(alignment: .leading, spacing: 16) {
                Text("質感 — 幻装の肌触りを選ぶ")
                    .font(.system(size: 11, weight: .light))
                    .foregroundStyle(Color(hex: "7ACCE0"))
                    .tracking(1.5)
                    .padding(.horizontal, 20)

                HStack(spacing: 10) {
                    ForEach(textureOptions, id: \.id) { tex in
                        let isChosen = entry.chosenTexture == tex.id
                        Button {
                            entry.chosenTexture = isChosen ? "none" : tex.id
                        } label: {
                            VStack(spacing: 6) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: tex.hex).opacity(0.28))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(isChosen ? Color(hex: "7ACCE0") : Color(hex: "2A3A50"),
                                                    lineWidth: isChosen ? 1.5 : 0.8)
                                    )
                                    .frame(height: 50)
                                    .overlay(
                                        VStack(spacing: 3) {
                                            Text(tex.name)
                                                .font(.system(size: 11, weight: .light, design: .serif))
                                                .foregroundStyle(Color(hex: isChosen ? "C8D8F0" : "5A7A8A"))
                                            Text(tex.desc)
                                                .font(.system(size: 8, weight: .thin))
                                                .foregroundStyle(Color(hex: "3A5A6A"))
                                        }
                                    )
                            }
                            .frame(maxWidth: .infinity)
                            .scaleEffect(isChosen ? 1.04 : 1.0)
                            .animation(.spring(response: 0.3), value: isChosen)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 20)
            .background(
                Color(hex: "060A14").opacity(0.97)
                    .overlay(Rectangle().fill(Color(hex: "1A2A3A")).frame(height: 0.5), alignment: .top)
            )
        }
        .ignoresSafeArea(edges: .bottom)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - 誓約フェーズオーバーレイ

    private var vowPhaseOverlay: some View {
        ZStack {
            Color(hex: "030508").opacity(0.85).ignoresSafeArea()
                .onTapGesture {}  // タップ貫通を防ぐ

            VStack(spacing: 0) {
                Spacer()
                VStack(alignment: .leading, spacing: 20) {

                    // 問い
                    VStack(alignment: .leading, spacing: 10) {
                        Image(systemName: "scroll")
                            .font(.system(size: 16))
                            .foregroundStyle(Color(hex: "7ACCE0").opacity(0.7))

                        Text("その新しい幻装に袖を通した君は、\nまずどこへ行きたい？\nどんな魔法を使って、誰を笑顔にしたい？")
                            .font(.system(size: 14, weight: .thin, design: .serif))
                            .foregroundStyle(Color(hex: "A8C0E0"))
                            .lineSpacing(7)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // 誓約テキストエディタ
                    TextEditor(text: Binding(get: { entry.vow }, set: { entry.vow = $0 }))
                        .font(.system(size: 14, weight: .light, design: .serif))
                        .foregroundStyle(Color(hex: "C8D8F0"))
                        .scrollContentBackground(.hidden)
                        .frame(height: 110)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: "080E18").opacity(0.8))
                                .overlay(RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color(hex: "2A4060"), lineWidth: 0.8))
                        )

                    // 召喚ボタン
                    Button { summonToSanctuary() } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                            Text("この幻装を召喚する")
                                .font(.system(size: 14, weight: .light))
                        }
                        .foregroundStyle(Color(hex: "C8D8F0"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: "3A6B9E").opacity(0.25))
                                .overlay(RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color(hex: "3A6B9E"), lineWidth: 1))
                        )
                    }
                    .disabled(drawing.strokes.isEmpty)
                    .opacity(drawing.strokes.isEmpty ? 0.4 : 1)

                    Button { withAnimation(.spring(response: 0.3)) { phase = .outline } } label: {
                        Text("描画に戻る")
                            .font(.system(size: 11, weight: .light))
                            .foregroundStyle(Color(hex: "4A6A8A"))
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(26)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(hex: "060A14").opacity(0.98))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color(hex: "1A2A3A"), lineWidth: 0.8)
                        )
                        .padding(.bottom, -20)  // 角丸を下に隠す
                )
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(spacing: 0) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16))
                    .foregroundStyle(Color(hex: "7A8FAA"))
                    .frame(width: 44, height: 44)
            }

            TextField("作品名", text: $entry.title)
                .font(.system(size: 15, weight: .light, design: .serif))
                .foregroundStyle(Color(hex: "C8D8F0"))
                .multilineTextAlignment(.center)

            // 保存
            Button { showSaveConfirm = true } label: {
                Text("保存")
                    .font(.system(size: 13, weight: .light))
                    .foregroundStyle(Color(hex: "7A8FAA"))
                    .padding(.horizontal, 12)
                    .frame(height: 30)
                    .overlay(RoundedRectangle(cornerRadius: 2)
                        .stroke(Color(hex: "2A3A50"), lineWidth: 1))
            }
            .padding(.trailing, 8)

            // 召喚ボタン
            Button { summonToSanctuary() } label: {
                HStack(spacing: 5) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 11))
                    Text("召喚")
                        .font(.system(size: 13, weight: .light))
                }
                .foregroundStyle(Color(hex: "C8D8F0"))
                .padding(.horizontal, 12)
                .frame(height: 30)
                .background(
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: "3A6B9E").opacity(0.25))
                        .overlay(RoundedRectangle(cornerRadius: 2)
                            .stroke(Color(hex: "3A6B9E"), lineWidth: 1))
                )
            }
            .padding(.trailing, 14)
            .disabled(drawing.strokes.isEmpty)
            .opacity(drawing.strokes.isEmpty ? 0.4 : 1)
        }
        .frame(height: 52)
        .background(Color(hex: "060810").opacity(0.94))
    }

    // MARK: - Bottom Bar（フェーズセレクター）

    private var bottomBar: some View {
        VStack(spacing: 0) {
            // ── 型紙フェーズのツールバー ──────────────
            if phase == .outline {
                HStack(spacing: 0) {
                    Button {
                        withAnimation(.spring(duration: 0.3)) { showGuidePanel.toggle() }
                    } label: {
                        VStack(spacing: 3) {
                            Image(systemName: "square.on.square.dashed").font(.system(size: 16))
                            Text("ガイド").font(.system(size: 9, weight: .light))
                        }
                        .foregroundStyle(showGuidePanel ? Color(hex: "C8D8F0") : Color(hex: "4A6A8A"))
                        .frame(width: 58, height: 44)
                    }

                    if selectedGuide != .none {
                        HStack(spacing: 6) {
                            Image(systemName: "eye").font(.system(size: 11))
                                .foregroundStyle(Color(hex: "4A6A8A"))
                            Slider(value: $guideOpacity, in: 0.05...0.55)
                                .tint(Color(hex: "3A6B9E")).frame(width: 100)
                        }
                        .padding(.horizontal, 6)
                    }

                    Spacer()

                    Button { isRulerActive.toggle() } label: {
                        VStack(spacing: 3) {
                            Image(systemName: "ruler").font(.system(size: 16))
                            Text("定規").font(.system(size: 9, weight: .light))
                        }
                        .foregroundStyle(isRulerActive ? Color(hex: "C8D8F0") : Color(hex: "4A6A8A"))
                        .frame(width: 50, height: 44)
                    }

                    Button { undoManager?.undo() } label: {
                        Image(systemName: "arrow.uturn.backward").font(.system(size: 16))
                            .foregroundStyle(Color(hex: "4A6A8A"))
                            .frame(width: 46, height: 44)
                    }

                    Button { withAnimation { drawing = PKDrawing() } } label: {
                        VStack(spacing: 3) {
                            Image(systemName: "trash").font(.system(size: 16))
                            Text("クリア").font(.system(size: 9, weight: .light))
                        }
                        .foregroundStyle(Color(hex: "6A4A4A"))
                        .frame(width: 56, height: 44)
                    }
                }
                .frame(height: 44)
                .background(Color(hex: "080A18").opacity(0.96))
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // ── フェーズタブ ──────────────────────────
            HStack(spacing: 0) {
                ForEach(AtelierPhase.allCases) { ph in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) { phase = ph }
                    } label: {
                        VStack(spacing: 3) {
                            Image(systemName: ph.icon).font(.system(size: 15))
                            Text(ph.label).font(.system(size: 9, weight: .light))
                        }
                        .foregroundStyle(phase == ph ? Color(hex: "C8D8F0") : Color(hex: "3A5A7A"))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .frame(height: 52)
            .background(Color(hex: "060A12").opacity(0.98))
            .overlay(Rectangle().fill(Color(hex: "1A2A3A")).frame(height: 0.5), alignment: .top)
        }
        .overlay(alignment: .top) {
            if phase == .outline, showGuidePanel {
                guideTemplatePanel
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    // MARK: - Guide Panel

    private var guideTemplatePanel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(GuideTemplate.allCases) { template in
                    Button {
                        selectedGuide = template
                        withAnimation(.spring(duration: 0.3)) { showGuidePanel = false }
                    } label: {
                        VStack(spacing: 6) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(hex: "0A0F1E"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(
                                                selectedGuide == template
                                                    ? Color(hex: "3A6B9E")
                                                    : Color(hex: "1A2A3A"),
                                                lineWidth: 1
                                            )
                                    )
                                    .frame(width: 72, height: 72)

                                template.previewIcon
                                    .font(.system(size: 26))
                                    .foregroundStyle(Color(hex: "4A7A9A"))
                            }
                            Text(template.label)
                                .font(.system(size: 9, weight: .light))
                                .foregroundStyle(Color(hex: "5A7A8A"))
                        }
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
        }
        .frame(height: 108)
        .background(Color(hex: "060A14").opacity(0.98))
        .offset(y: -108)
    }

    // MARK: - 召喚完了オーバーレイ

    private var summonOverlay: some View {
        ZStack {
            Color(hex: "030508").opacity(0.92).ignoresSafeArea()

            VStack(spacing: 28) {
                // グロー
                ZStack {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(Color(hex: "3A6B9E").opacity(0.08 - Double(i) * 0.02))
                            .frame(width: CGFloat(120 + i * 50), height: CGFloat(120 + i * 50))
                            .blur(radius: CGFloat(10 + i * 8))
                    }
                    Image(systemName: "sparkles")
                        .font(.system(size: 52))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "C8D8F0"), Color(hex: "3A6B9E")],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                }

                VStack(spacing: 12) {
                    Text("召喚完了")
                        .font(.system(size: 30, weight: .thin, design: .serif))
                        .foregroundStyle(Color(hex: "C8D8F0"))

                    Text("この姿が聖域の広間を\n歩き始めます")
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(Color(hex: "4A6A8A"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(7)
                }
            }
        }
        .transition(.opacity)
    }

    // MARK: - Export Banner

    @ViewBuilder
    private var exportSuccessBanner: some View {
        if showExportSuccess {
            VStack {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("カメラロールに保存しました")
                }
                .font(.system(size: 13, weight: .light))
                .foregroundStyle(Color(hex: "C8D8F0"))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color(hex: "1A3050").opacity(0.95))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color(hex: "3A6B9E"), lineWidth: 1))
                .padding(.top, 80)
                Spacer()
            }
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    // MARK: - 染色ヘルパー

    private var chosenColors: [String] {
        entry.chosenColorHexes.isEmpty
            ? []
            : entry.chosenColorHexes.components(separatedBy: ",").filter { !$0.isEmpty }
    }

    private func toggleColor(_ hex: String) {
        var colors = chosenColors
        if let idx = colors.firstIndex(of: hex) {
            colors.remove(at: idx)
        } else {
            colors.append(hex)
        }
        entry.chosenColorHexes = colors.joined(separator: ",")
    }

    // MARK: - スパークエフェクト

    private func addSparkBurst(at point: CGPoint) {
        let now = Date()
        sparkBursts = sparkBursts.filter { now.timeIntervalSince($0.birth) < 0.85 }
        sparkBursts.append((pos: point, birth: now))
        if sparkBursts.count > 60 { sparkBursts.removeFirst() }
    }

    // MARK: - Actions

    private func canvasBounds() -> CGRect {
        CGRect(origin: .zero,
               size: canvasSize.width > 0 ? canvasSize : CGSize(width: 1024, height: 1366))
    }

    private func saveToProject() {
        entry.save(drawing: drawing, in: canvasBounds())
        try? context.save()
    }

    private func summonToSanctuary() {
        // 他の DrawingEntry の召喚フラグをすべて解除
        if let all = try? context.fetch(FetchDescriptor<DrawingEntry>()) {
            all.forEach { $0.isPlacedInSanctuary = false }
        }
        entry.summonToSanctuary(drawing: drawing, in: canvasBounds())
        try? context.save()

        withAnimation(.easeIn(duration: 0.35)) { showSummonOverlay = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
            withAnimation(.easeOut(duration: 0.4)) { showSummonOverlay = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { dismiss() }
        }
    }

    private func exportToPhotos() {
        saveToProject()
        let bounds = canvasBounds()
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        let composited = renderer.image { ctx in
            UIColor(Color(hex: "060810")).setFill()
            ctx.fill(bounds)
            if selectedGuide != .none, let guideImg = guideSnapshot(size: bounds.size) {
                guideImg.draw(in: bounds, blendMode: .normal, alpha: guideOpacity)
            }
            drawing.image(from: bounds, scale: UIScreen.main.scale).draw(in: bounds)
        }
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else { return }
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: composited)
            }) { success, _ in
                if success {
                    DispatchQueue.main.async {
                        withAnimation { showExportSuccess = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation { showExportSuccess = false }
                        }
                    }
                }
            }
        }
    }

    private func guideSnapshot(size: CGSize) -> UIImage? {
        let controller = UIHostingController(rootView:
            GuideTemplateView(template: selectedGuide)
                .frame(width: size.width, height: size.height))
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.backgroundColor = .clear
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

// MARK: - 仕立てフェーズ

enum AtelierPhase: Int, CaseIterable, Identifiable {
    case outline  = 0
    case colors   = 1
    case textures = 2
    case vow      = 3

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .outline:  return "型紙"
        case .colors:   return "染色"
        case .textures: return "質感"
        case .vow:      return "誓約"
        }
    }

    var icon: String {
        switch self {
        case .outline:  return "pencil.tip"
        case .colors:   return "drop.fill"
        case .textures: return "sparkles"
        case .vow:      return "scroll"
        }
    }
}

// MARK: - ガイドテンプレート定義

enum GuideTemplate: String, CaseIterable, Identifiable {
    case none           = "none"
    case humanSkeleton  = "humanSkeleton"
    case masculine      = "masculine"
    case feminine       = "feminine"
    case beastSkeleton  = "beastSkeleton"
    case wingedSkeleton = "wingedSkeleton"
    case ear            = "ear"
    case tail           = "tail"
    case face           = "face"
    case paw            = "paw"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .none:           return "なし"
        case .humanSkeleton:  return "中性体"
        case .masculine:      return "男性体"
        case .feminine:       return "女性体"
        case .beastSkeleton:  return "獣型"
        case .wingedSkeleton: return "翼型"
        case .ear:            return "耳"
        case .tail:           return "しっぽ"
        case .face:           return "顔"
        case .paw:            return "肉球"
        }
    }

    var previewIcon: Image {
        switch self {
        case .none:           return Image(systemName: "xmark")
        case .humanSkeleton:  return Image(systemName: "figure.arms.open")
        case .masculine:      return Image(systemName: "figure.stand")
        case .feminine:       return Image(systemName: "figure.wave")
        case .beastSkeleton:  return Image(systemName: "pawprint")
        case .wingedSkeleton: return Image(systemName: "bird")
        case .ear:            return Image(systemName: "waveform.path")
        case .tail:           return Image(systemName: "scribble.variable")
        case .face:           return Image(systemName: "face.dashed")
        case .paw:            return Image(systemName: "hand.raised")
        }
    }

    var icon: Image { previewIcon }
}

// MARK: - ガイドテンプレートビュー

struct GuideTemplateView: View {
    let template: GuideTemplate

    private let guideColor = Color(hex: "5AAAC8")
    private let dotColor   = Color(hex: "7ACCE0")
    private let style      = StrokeStyle(lineWidth: 0.9, dash: [4, 5])

    var body: some View {
        GeometryReader { geo in
            ZStack {
                switch template {
                case .humanSkeleton:
                    humanSkeletonCanvas(geo: geo)
                case .masculine:
                    masculineSkeletonCanvas(geo: geo)
                case .feminine:
                    feminineSkeletonCanvas(geo: geo)
                case .beastSkeleton:
                    beastSkeletonCanvas(geo: geo)
                case .wingedSkeleton:
                    wingedSkeletonCanvas(geo: geo)
                case .ear:
                    EarGuideShape()
                        .stroke(guideColor, style: style)
                        .frame(width: 200, height: 240)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                case .tail:
                    TailGuideShape()
                        .stroke(guideColor, style: style)
                        .frame(width: 160, height: 300)
                        .position(x: geo.size.width * 0.6, y: geo.size.height * 0.5)
                case .face:
                    Circle()
                        .stroke(guideColor, style: style)
                        .frame(width: 260, height: 260)
                        .position(x: geo.size.width / 2, y: geo.size.height * 0.45)
                case .paw:
                    PawGuideShape()
                        .stroke(guideColor, style: style)
                        .frame(width: 180, height: 200)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                case .none:
                    EmptyView()
                }
            }
        }
    }

    // MARK: Human Skeleton（中性体 — 均整のとれた少年らしいシルエット）

    private func humanSkeletonCanvas(geo: GeometryProxy) -> some View {
        Canvas { ctx, size in
            let gc = guideColor.opacity(0.9)
            let dc = dotColor
            let subtleStyle = StrokeStyle(lineWidth: 0.6, dash: [3, 6])

            func p(_ nx: CGFloat, _ ny: CGFloat) -> CGPoint {
                CGPoint(x: size.width * nx, y: size.height * ny)
            }
            func bone(_ a: CGPoint, _ b: CGPoint) {
                var path = Path(); path.move(to: a); path.addLine(to: b)
                ctx.stroke(path, with: .color(gc), style: style)
            }
            func joint(_ pt: CGPoint, r: CGFloat = 3.5) {
                ctx.fill(Path(ellipseIn: CGRect(x: pt.x-r, y: pt.y-r,
                                                width: r*2, height: r*2)), with: .color(dc))
            }

            // 頭（縦長楕円・中性的）
            let headC = p(0.50, 0.08)
            ctx.stroke(Path(ellipseIn: CGRect(x: headC.x-24, y: headC.y-28,
                                              width: 48, height: 56)),
                       with: .color(gc), style: style)

            // 首
            let neckTop  = p(0.50, 0.16)
            let neckBase = p(0.50, 0.21)
            bone(headC, neckTop); bone(neckTop, neckBase); joint(neckBase)

            // 鎖骨・肩（肩幅＝骨盤幅の均整型）
            let lShoulder = p(0.33, 0.24), rShoulder = p(0.67, 0.24)
            bone(lShoulder, rShoulder)          // 鎖骨
            bone(neckBase, lShoulder); bone(neckBase, rShoulder)
            joint(lShoulder); joint(rShoulder)

            // 胸郭（細身の楕円）
            let ribW = size.width * 0.22, ribH = size.height * 0.13
            let ribRect = CGRect(x: size.width*0.50 - ribW/2, y: size.height*0.33 - ribH/2,
                                 width: ribW, height: ribH)
            ctx.stroke(Path(ellipseIn: ribRect), with: .color(gc.opacity(0.45)), style: subtleStyle)

            // 脊椎
            let spineMid = p(0.50, 0.44)
            bone(neckBase, spineMid); joint(spineMid)

            // 骨盤（肩幅と揃えた均整型、バタフライ曲線）
            let lHip = p(0.36, 0.54), rHip = p(0.64, 0.54)
            var pelvis = Path()
            pelvis.move(to: lHip)
            pelvis.addQuadCurve(to: p(0.50, 0.51), control: p(0.38, 0.49))
            pelvis.addQuadCurve(to: rHip, control: p(0.62, 0.49))
            ctx.stroke(pelvis, with: .color(gc), style: style)
            var pelvisB = Path()
            pelvisB.move(to: lHip)
            pelvisB.addQuadCurve(to: rHip, control: p(0.50, 0.59))
            ctx.stroke(pelvisB, with: .color(gc.opacity(0.4)), style: subtleStyle)
            bone(spineMid, p(0.50, 0.52)); joint(lHip); joint(rHip)

            // 腕
            let lElbow = p(0.20, 0.44), rElbow = p(0.80, 0.44)
            let lWrist = p(0.14, 0.60), rWrist = p(0.86, 0.60)
            bone(lShoulder, lElbow); bone(lElbow, lWrist)
            bone(rShoulder, rElbow); bone(rElbow, rWrist)
            joint(lElbow); joint(rElbow); joint(lWrist); joint(rWrist)

            // 指
            for i in 0..<4 {
                let dx = (CGFloat(i) - 1.5) * 7
                bone(lWrist, CGPoint(x: lWrist.x + dx - 3, y: lWrist.y + 15))
                bone(rWrist, CGPoint(x: rWrist.x + dx + 3, y: rWrist.y + 15))
            }

            // 脚（長い）
            let lKnee = p(0.34, 0.72), rKnee = p(0.66, 0.72)
            let lAnkle = p(0.36, 0.90), rAnkle = p(0.64, 0.90)
            bone(lHip, lKnee); bone(lKnee, lAnkle)
            bone(rHip, rKnee); bone(rKnee, rAnkle)
            joint(lKnee); joint(rKnee); joint(lAnkle); joint(rAnkle)

            // 足
            bone(lAnkle, p(0.26, 0.93)); bone(rAnkle, p(0.74, 0.93))
        }
    }

    // MARK: Masculine Skeleton（男性体 — 広い肩・狭い骨盤・力強いシルエット）

    private func masculineSkeletonCanvas(geo: GeometryProxy) -> some View {
        Canvas { ctx, size in
            let gc = guideColor.opacity(0.9)
            let dc = dotColor
            let subtleStyle = StrokeStyle(lineWidth: 0.6, dash: [3, 6])

            func p(_ nx: CGFloat, _ ny: CGFloat) -> CGPoint {
                CGPoint(x: size.width * nx, y: size.height * ny)
            }
            func bone(_ a: CGPoint, _ b: CGPoint) {
                var path = Path(); path.move(to: a); path.addLine(to: b)
                ctx.stroke(path, with: .color(gc), style: style)
            }
            func joint(_ pt: CGPoint, r: CGFloat = 3.5) {
                ctx.fill(Path(ellipseIn: CGRect(x: pt.x-r, y: pt.y-r,
                                                width: r*2, height: r*2)), with: .color(dc))
            }

            // 頭（横広め、力強さ）
            let headC = p(0.50, 0.08)
            ctx.stroke(Path(ellipseIn: CGRect(x: headC.x-27, y: headC.y-26,
                                              width: 54, height: 52)),
                       with: .color(gc), style: style)

            // 首（やや太め）
            let neckTop  = p(0.50, 0.16)
            let neckBase = p(0.50, 0.20)
            bone(headC, neckTop); bone(neckTop, neckBase); joint(neckBase)

            // 肩（広い — ±0.23w）
            let lShoulder = p(0.27, 0.24), rShoulder = p(0.73, 0.24)
            bone(lShoulder, rShoulder)
            bone(neckBase, lShoulder); bone(neckBase, rShoulder)
            joint(lShoulder); joint(rShoulder)

            // 胸郭（広い台形型）
            let ribW = size.width * 0.28, ribH = size.height * 0.13
            let ribRect = CGRect(x: size.width*0.50 - ribW/2, y: size.height*0.33 - ribH/2,
                                 width: ribW, height: ribH)
            ctx.stroke(Path(ellipseIn: ribRect), with: .color(gc.opacity(0.45)), style: subtleStyle)

            // 脊椎
            let spineMid = p(0.50, 0.44)
            bone(neckBase, spineMid); joint(spineMid)

            // 骨盤（狭い — ±0.12w）
            let lHip = p(0.38, 0.54), rHip = p(0.62, 0.54)
            var pelvis = Path()
            pelvis.move(to: lHip)
            pelvis.addQuadCurve(to: p(0.50, 0.51), control: p(0.40, 0.50))
            pelvis.addQuadCurve(to: rHip, control: p(0.60, 0.50))
            ctx.stroke(pelvis, with: .color(gc), style: style)
            var pelvisB = Path()
            pelvisB.move(to: lHip)
            pelvisB.addQuadCurve(to: rHip, control: p(0.50, 0.57))
            ctx.stroke(pelvisB, with: .color(gc.opacity(0.4)), style: subtleStyle)
            bone(spineMid, p(0.50, 0.52)); joint(lHip); joint(rHip)

            // 腕（太め短め）
            let lElbow = p(0.18, 0.43), rElbow = p(0.82, 0.43)
            let lWrist = p(0.12, 0.58), rWrist = p(0.88, 0.58)
            bone(lShoulder, lElbow); bone(lElbow, lWrist)
            bone(rShoulder, rElbow); bone(rElbow, rWrist)
            joint(lElbow); joint(rElbow); joint(lWrist); joint(rWrist)

            for i in 0..<4 {
                let dx = (CGFloat(i) - 1.5) * 7
                bone(lWrist, CGPoint(x: lWrist.x + dx - 3, y: lWrist.y + 14))
                bone(rWrist, CGPoint(x: rWrist.x + dx + 3, y: rWrist.y + 14))
            }

            // 脚（やや短め力強い）
            let lKnee = p(0.35, 0.72), rKnee = p(0.65, 0.72)
            let lAnkle = p(0.37, 0.90), rAnkle = p(0.63, 0.90)
            bone(lHip, lKnee); bone(lKnee, lAnkle)
            bone(rHip, rKnee); bone(rKnee, rAnkle)
            joint(lKnee); joint(rKnee); joint(lAnkle); joint(rAnkle)

            bone(lAnkle, p(0.27, 0.93)); bone(rAnkle, p(0.73, 0.93))
        }
    }

    // MARK: Feminine Skeleton（女性体 — 狭い肩・くびれ・広い骨盤・優美な曲線）

    private func feminineSkeletonCanvas(geo: GeometryProxy) -> some View {
        Canvas { ctx, size in
            let gc = guideColor.opacity(0.9)
            let dc = dotColor
            let subtleStyle = StrokeStyle(lineWidth: 0.6, dash: [3, 6])

            func p(_ nx: CGFloat, _ ny: CGFloat) -> CGPoint {
                CGPoint(x: size.width * nx, y: size.height * ny)
            }
            func bone(_ a: CGPoint, _ b: CGPoint) {
                var path = Path(); path.move(to: a); path.addLine(to: b)
                ctx.stroke(path, with: .color(gc), style: style)
            }
            func joint(_ pt: CGPoint, r: CGFloat = 3.5) {
                ctx.fill(Path(ellipseIn: CGRect(x: pt.x-r, y: pt.y-r,
                                                width: r*2, height: r*2)), with: .color(dc))
            }

            // 頭（縦長楕円・繊細）
            let headC = p(0.50, 0.08)
            ctx.stroke(Path(ellipseIn: CGRect(x: headC.x-22, y: headC.y-28,
                                              width: 44, height: 56)),
                       with: .color(gc), style: style)

            // 首（長くしなやか）
            let neckTop  = p(0.50, 0.16)
            let neckBase = p(0.50, 0.22)
            bone(headC, neckTop); bone(neckTop, neckBase); joint(neckBase)

            // 肩（狭い — ±0.14w）
            let lShoulder = p(0.36, 0.25), rShoulder = p(0.64, 0.25)
            bone(lShoulder, rShoulder)
            bone(neckBase, lShoulder); bone(neckBase, rShoulder)
            joint(lShoulder); joint(rShoulder)

            // 胸郭（小さめ楕円）
            let ribW = size.width * 0.19, ribH = size.height * 0.13
            let ribRect = CGRect(x: size.width*0.50 - ribW/2, y: size.height*0.34 - ribH/2,
                                 width: ribW, height: ribH)
            ctx.stroke(Path(ellipseIn: ribRect), with: .color(gc.opacity(0.45)), style: subtleStyle)

            // ウエストのくびれ（サイドカーブ）
            var waistL = Path()
            waistL.move(to: p(0.31, 0.32))
            waistL.addQuadCurve(to: p(0.38, 0.50), control: p(0.27, 0.42))
            ctx.stroke(waistL, with: .color(gc.opacity(0.30)), style: subtleStyle)
            var waistR = Path()
            waistR.move(to: p(0.69, 0.32))
            waistR.addQuadCurve(to: p(0.62, 0.50), control: p(0.73, 0.42))
            ctx.stroke(waistR, with: .color(gc.opacity(0.30)), style: subtleStyle)

            // 脊椎
            let spineMid = p(0.50, 0.44)
            bone(neckBase, spineMid); joint(spineMid)

            // 骨盤（広い — ±0.19w、優美な曲線）
            let lHip = p(0.31, 0.55), rHip = p(0.69, 0.55)
            var pelvis = Path()
            pelvis.move(to: lHip)
            pelvis.addQuadCurve(to: p(0.50, 0.51), control: p(0.34, 0.48))
            pelvis.addQuadCurve(to: rHip, control: p(0.66, 0.48))
            ctx.stroke(pelvis, with: .color(gc), style: style)
            var pelvisB = Path()
            pelvisB.move(to: lHip)
            pelvisB.addQuadCurve(to: rHip, control: p(0.50, 0.63))
            ctx.stroke(pelvisB, with: .color(gc.opacity(0.4)), style: subtleStyle)
            bone(spineMid, p(0.50, 0.52)); joint(lHip); joint(rHip)

            // 腕（細く長い）
            let lElbow = p(0.22, 0.44), rElbow = p(0.78, 0.44)
            let lWrist = p(0.16, 0.61), rWrist = p(0.84, 0.61)
            bone(lShoulder, lElbow); bone(lElbow, lWrist)
            bone(rShoulder, rElbow); bone(rElbow, rWrist)
            joint(lElbow); joint(rElbow); joint(lWrist); joint(rWrist)

            for i in 0..<4 {
                let dx = (CGFloat(i) - 1.5) * 6
                bone(lWrist, CGPoint(x: lWrist.x + dx - 2, y: lWrist.y + 15))
                bone(rWrist, CGPoint(x: rWrist.x + dx + 2, y: rWrist.y + 15))
            }

            // 脚（長く優美）
            let lKnee = p(0.33, 0.72), rKnee = p(0.67, 0.72)
            let lAnkle = p(0.35, 0.91), rAnkle = p(0.65, 0.91)
            bone(lHip, lKnee); bone(lKnee, lAnkle)
            bone(rHip, rKnee); bone(rKnee, rAnkle)
            joint(lKnee); joint(rKnee); joint(lAnkle); joint(rAnkle)

            bone(lAnkle, p(0.25, 0.94)); bone(rAnkle, p(0.75, 0.94))
        }
    }

    // MARK: Beast Skeleton（四足歩行）

    private func beastSkeletonCanvas(geo: GeometryProxy) -> some View {
        Canvas { ctx, size in
            let gc = guideColor.opacity(0.9)
            let dc = dotColor

            func p(_ nx: CGFloat, _ ny: CGFloat) -> CGPoint {
                CGPoint(x: size.width * nx, y: size.height * ny)
            }
            func bone(_ a: CGPoint, _ b: CGPoint) {
                var path = Path(); path.move(to: a); path.addLine(to: b)
                ctx.stroke(path, with: .color(gc), style: style)
            }
            func joint(_ pt: CGPoint, r: CGFloat = 4) {
                ctx.fill(Path(ellipseIn: CGRect(x: pt.x-r, y: pt.y-r,
                                                width: r*2, height: r*2)), with: .color(dc))
            }

            // 頭（楕円）
            let headCenter = p(0.18, 0.40)
            ctx.stroke(
                Path(ellipseIn: CGRect(x: headCenter.x-32, y: headCenter.y-22,
                                       width: 64, height: 44)),
                with: .color(gc), style: style
            )
            // 耳
            bone(p(0.14, 0.30), p(0.10, 0.20)); bone(p(0.22, 0.30), p(0.26, 0.20))

            // 首
            let neckBase = p(0.30, 0.42), neckTop = p(0.22, 0.37)
            bone(neckTop, neckBase); joint(neckBase)

            // 脊椎（S字）
            let shoulder = p(0.38, 0.37)
            let midSpine  = p(0.54, 0.34)
            let hip        = p(0.72, 0.37)
            do {
                var sp = Path()
                sp.move(to: neckBase)
                sp.addCurve(to: hip,
                             control1: CGPoint(x: shoulder.x, y: shoulder.y - 6),
                             control2: CGPoint(x: midSpine.x,  y: midSpine.y - 6))
                ctx.stroke(sp, with: .color(gc), style: style)
            }
            joint(shoulder); joint(midSpine); joint(hip)

            // 肋骨（省略形）
            for i in 0..<4 {
                let nx = 0.36 + CGFloat(i) * 0.075
                let ribTop = p(nx, 0.37)
                bone(ribTop, p(nx - 0.02, 0.50))
                bone(ribTop, p(nx + 0.02, 0.50))
            }

            // 前脚（左・右）
            let fLS = p(0.35, 0.38), fRS = p(0.44, 0.38)
            let fLK = p(0.32, 0.58), fRK = p(0.42, 0.58)
            let fLA = p(0.30, 0.73), fRA = p(0.40, 0.73)
            bone(fLS, fLK); bone(fLK, fLA); joint(fLK); joint(fLA)
            bone(fRS, fRK); bone(fRK, fRA); joint(fRK); joint(fRA)
            // 爪
            bone(fLA, p(0.25, 0.77)); bone(fLA, p(0.29, 0.77)); bone(fLA, p(0.33, 0.77))
            bone(fRA, p(0.35, 0.77)); bone(fRA, p(0.39, 0.77)); bone(fRA, p(0.43, 0.77))

            // 後脚（左・右）
            let rLS = p(0.68, 0.38), rRS = p(0.76, 0.38)
            let rLK = p(0.65, 0.56), rRK = p(0.74, 0.56)
            let rLA = p(0.67, 0.72), rRA = p(0.76, 0.72)
            bone(rLS, rLK); bone(rLK, rLA); joint(rLK); joint(rLA)
            bone(rRS, rRK); bone(rRK, rRA); joint(rRK); joint(rRA)
            bone(rLA, p(0.62, 0.76)); bone(rLA, p(0.66, 0.76)); bone(rLA, p(0.70, 0.76))
            bone(rRA, p(0.71, 0.76)); bone(rRA, p(0.75, 0.76)); bone(rRA, p(0.79, 0.76))

            // しっぽ
            do {
                var tail = Path()
                tail.move(to: hip)
                tail.addCurve(
                    to: p(0.96, 0.22),
                    control1: p(0.82, 0.32),
                    control2: p(0.92, 0.30)
                )
                ctx.stroke(tail, with: .color(gc), style: style)
            }
        }
    }

    // MARK: Winged Skeleton（人型＋翼）

    private func wingedSkeletonCanvas(geo: GeometryProxy) -> some View {
        Canvas { ctx, size in
            let gc = guideColor.opacity(0.9)
            let dc = dotColor
            let wingColor = guideColor.opacity(0.5)
            let wingStyle = StrokeStyle(lineWidth: 0.7, dash: [3, 6])

            func p(_ nx: CGFloat, _ ny: CGFloat) -> CGPoint {
                CGPoint(x: size.width * nx, y: size.height * ny)
            }
            func bone(_ a: CGPoint, _ b: CGPoint) {
                var path = Path(); path.move(to: a); path.addLine(to: b)
                ctx.stroke(path, with: .color(gc), style: style)
            }
            func wingBone(_ a: CGPoint, _ b: CGPoint) {
                var path = Path(); path.move(to: a); path.addLine(to: b)
                ctx.stroke(path, with: .color(wingColor), style: wingStyle)
            }
            func joint(_ pt: CGPoint, r: CGFloat = 4) {
                ctx.fill(Path(ellipseIn: CGRect(x: pt.x-r, y: pt.y-r,
                                                width: r*2, height: r*2)), with: .color(dc))
            }

            // ── 体（人型と同じ、少し上に詰める）──
            let headC    = p(0.50, 0.07)
            ctx.stroke(Path(ellipseIn: CGRect(x: headC.x-24, y: headC.y-24,
                                              width: 48, height: 48)),
                       with: .color(gc), style: style)

            let neck      = p(0.50, 0.16)
            let lShoulder = p(0.32, 0.23)
            let rShoulder = p(0.68, 0.23)
            bone(headC, neck)
            bone(lShoulder, rShoulder)
            joint(neck); joint(lShoulder); joint(rShoulder)

            let lElbow = p(0.20, 0.40), rElbow = p(0.80, 0.40)
            let lWrist = p(0.14, 0.55), rWrist = p(0.86, 0.55)
            bone(lShoulder, lElbow); bone(lElbow, lWrist)
            bone(rShoulder, rElbow); bone(rElbow, rWrist)
            joint(lElbow); joint(rElbow); joint(lWrist); joint(rWrist)

            let spineMid = p(0.50, 0.44)
            bone(neck, spineMid); joint(spineMid)

            let lHip  = p(0.38, 0.54), rHip  = p(0.62, 0.54)
            bone(spineMid, lHip); bone(spineMid, rHip); bone(lHip, rHip)
            joint(lHip); joint(rHip)

            let lKnee = p(0.36, 0.70), rKnee = p(0.64, 0.70)
            let lAnkle = p(0.38, 0.87), rAnkle = p(0.62, 0.87)
            bone(lHip, lKnee); bone(lKnee, lAnkle)
            bone(rHip, rKnee); bone(rKnee, rAnkle)
            joint(lKnee); joint(rKnee); joint(lAnkle); joint(rAnkle)
            bone(lAnkle, p(0.29, 0.90)); bone(rAnkle, p(0.71, 0.90))

            // ── 翼（肩甲骨から展開）──
            // 左翼
            let lWingRoot = p(0.36, 0.24)
            let lWingMid  = p(0.08, 0.14)
            let lWingTip  = p(-0.04, 0.06)
            let lWingSec  = p(0.04, 0.36)
            let lWingThird = p(0.20, 0.48)
            wingBone(lWingRoot, lWingMid)
            wingBone(lWingMid,  lWingTip)
            wingBone(lWingRoot, lWingSec)
            wingBone(lWingRoot, lWingThird)
            joint(lWingMid, r: 3)

            // 左翼膜（ベジェ曲線）
            var lMembrane = Path()
            lMembrane.move(to: lWingRoot)
            lMembrane.addQuadCurve(to: lWingMid,   control: p(0.12, 0.10))
            lMembrane.addQuadCurve(to: lWingSec,   control: p(0.02, 0.30))
            lMembrane.addQuadCurve(to: lWingThird, control: p(0.18, 0.46))
            lMembrane.addLine(to: lWingRoot)
            ctx.stroke(lMembrane, with: .color(wingColor), style: wingStyle)

            // 右翼（左翼の左右対称）
            let rWingRoot  = p(0.64, 0.24)
            let rWingMid   = p(0.92, 0.14)
            let rWingTip   = p(1.04, 0.06)
            let rWingSec   = p(0.96, 0.36)
            let rWingThird = p(0.80, 0.48)
            wingBone(rWingRoot, rWingMid)
            wingBone(rWingMid,  rWingTip)
            wingBone(rWingRoot, rWingSec)
            wingBone(rWingRoot, rWingThird)
            joint(rWingMid, r: 3)

            var rMembrane = Path()
            rMembrane.move(to: rWingRoot)
            rMembrane.addQuadCurve(to: rWingMid,   control: p(0.88, 0.10))
            rMembrane.addQuadCurve(to: rWingSec,   control: p(0.98, 0.30))
            rMembrane.addQuadCurve(to: rWingThird, control: p(0.82, 0.46))
            rMembrane.addLine(to: rWingRoot)
            ctx.stroke(rMembrane, with: .color(wingColor), style: wingStyle)
        }
    }
}

// MARK: - 既存ガイドシェイプ

private struct EarGuideShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let mx = rect.midX
        p.move(to: CGPoint(x: mx - 60, y: rect.maxY))
        p.addCurve(to: CGPoint(x: mx - 20, y: rect.minY + 20),
                   control1: CGPoint(x: mx - 80, y: rect.maxY * 0.3),
                   control2: CGPoint(x: mx - 50, y: rect.minY))
        p.addCurve(to: CGPoint(x: mx - 10, y: rect.maxY),
                   control1: CGPoint(x: mx - 10, y: rect.minY + 10),
                   control2: CGPoint(x: mx - 10, y: rect.maxY * 0.5))
        p.move(to: CGPoint(x: mx + 10, y: rect.maxY))
        p.addCurve(to: CGPoint(x: mx + 20, y: rect.minY + 20),
                   control1: CGPoint(x: mx + 10, y: rect.maxY * 0.5),
                   control2: CGPoint(x: mx + 10, y: rect.minY + 10))
        p.addCurve(to: CGPoint(x: mx + 60, y: rect.maxY),
                   control1: CGPoint(x: mx + 50, y: rect.minY),
                   control2: CGPoint(x: mx + 80, y: rect.maxY * 0.3))
        return p
    }
}

private struct TailGuideShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX + 20, y: rect.minY))
        p.addCurve(to: CGPoint(x: rect.maxX - 10, y: rect.midY),
                   control1: CGPoint(x: rect.maxX + 30, y: rect.minY + 40),
                   control2: CGPoint(x: rect.maxX + 20, y: rect.midY - 40))
        p.addCurve(to: CGPoint(x: rect.midX, y: rect.maxY - 20),
                   control1: CGPoint(x: rect.maxX - 10, y: rect.midY + 60),
                   control2: CGPoint(x: rect.midX + 30, y: rect.maxY - 10))
        p.addEllipse(in: CGRect(x: rect.midX - 25, y: rect.maxY - 50, width: 50, height: 50))
        return p
    }
}

private struct PawGuideShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addEllipse(in: CGRect(x: rect.midX - 40, y: rect.midY, width: 80, height: 70))
        let positions: [(CGFloat, CGFloat)] = [(-45, -10), (-15, -30), (15, -30), (45, -10)]
        for (dx, dy) in positions {
            p.addEllipse(in: CGRect(x: rect.midX + dx - 16, y: rect.midY + dy, width: 32, height: 28))
        }
        return p
    }
}

// MARK: - キャンバス背景アンビエンス

private struct CanvasAmbience: View {
    @State private var particles: [CA] = []
    struct CA: Identifiable {
        let id = UUID()
        var x, y, size, speed, phase: CGFloat
    }
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate
                for p in particles {
                    let wave    = (sin(Double(t) * Double(p.speed) + Double(p.phase)) + 1) * 0.5
                    let opacity = 0.03 + wave * 0.05
                    let dy      = CGFloat(t) * p.speed * 6
                    let py      = (p.y - dy).truncatingRemainder(dividingBy: size.height + 20)
                    let ay      = py < -10 ? py + size.height + 20 : py
                    ctx.fill(
                        Path(ellipseIn: CGRect(x: p.x - p.size/2, y: ay - p.size/2,
                                              width: p.size, height: p.size)),
                        with: .color(Color(hex: "5AAAC8").opacity(opacity))
                    )
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onAppear {
            let s = UIScreen.main.bounds
            particles = (0..<25).map { _ in
                CA(x: .random(in: 0...s.width), y: .random(in: 0...s.height),
                   size: .random(in: 1...2.5), speed: .random(in: 0.005...0.014),
                   phase: .random(in: 0...(.pi * 2)))
            }
        }
    }
}

#Preview {
    WorkshopView(entry: DrawingEntry(title: "テスト", guideId: "humanSkeleton"))
        .modelContainer(for: DrawingEntry.self, inMemory: true)
}
