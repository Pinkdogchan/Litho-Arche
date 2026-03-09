import SwiftUI
import SwiftData

// MARK: - Screen 7: 時の砂時計

struct HourglassView: View {

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    // 全エントリを日付降順で取得
    @Query(sort: \HourglassEntry.date, order: .reverse)
    private var allEntries: [HourglassEntry]

    // 今日のエントリ（または新規）
    @State private var todayEntry: HourglassEntry?
    @State private var sandLevel:  CGFloat = 0   // 0.0〜1.0（アニメーション用）
    @State private var appeared    = false

    // 習慣リスト（固定 + ユーザー追加可）
    private let defaultHabits = ["水を飲む", "深呼吸 10回", "日記を書く", "外に出る", "感謝を1つ思う"]

    private var today: Date { HourglassEntry.dayKey(.now) }

    private var weekDays: [Date] {
        (0..<7).compactMap {
            Calendar.current.date(byAdding: .day, value: -$0, to: today)
        }.reversed()
    }

    var body: some View {
        ZStack {
            Color(hex: "060A0C").ignoresSafeArea()
            HourglassAmbience()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    hourglassHeader
                    Divider().background(Color(hex: "1E2A18")).padding(.vertical, 4)
                    diagnosticSection
                    Divider().background(Color(hex: "1E2A18")).padding(.vertical, 4)
                    habitsSection
                    Divider().background(Color(hex: "1E2A18")).padding(.vertical, 4)
                    weekCalendar
                }
                .padding(.bottom, 60)
            }
        }
        .navigationTitle("時の砂時計")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear(perform: loadOrCreateToday)
    }

    // MARK: - ヘッダー（砂時計ビジュアル）

    private var hourglassHeader: some View {
        VStack(spacing: 16) {
            // 日付
            Text(today.formatted(.dateTime.year().month().day().locale(Locale(identifier: "ja_JP"))))
                .font(.system(size: 11, weight: .light))
                .foregroundStyle(Color(hex: "5A7A4A"))
                .tracking(2)
                .padding(.top, 28)

            // タイトルバナー
            TitleBannerView(title: "時の砂時計", subtitle: "習慣と自己問診のレビュー")
                .padding(.bottom, 8)

            // 砂時計
            ZStack {
                // グロー
                Ellipse()
                    .fill(Color(hex: "4A6A2A").opacity(appeared ? 0.25 : 0))
                    .frame(width: 200, height: 80)
                    .blur(radius: 30)
                    .animation(.easeInOut(duration: 1.4), value: appeared)

                HourglassShape(sandLevel: sandLevel)
                    .frame(width: 100, height: 140)
            }

            // 完了率
            let pct = Int(sandLevel * 100)
            Text("\(pct)%")
                .font(.system(size: 28, weight: .thin, design: .monospaced))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "8AAA5A"), Color(hex: "4A6A2A")],
                        startPoint: .top, endPoint: .bottom
                    )
                )

            Text("今日の充実度")
                .font(.system(size: 11, weight: .light))
                .foregroundStyle(Color(hex: "3A4A2A"))
                .tracking(2)
                .padding(.bottom, 12)
        }
    }

    // MARK: - 今日の問診（5項目）

    private var diagnosticSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionHeader(title: "今日の問診", icon: "stethoscope")

            if let entry = todayEntry {
                DiagnosticRow(
                    icon: "moon.zzz", label: "睡眠",
                    score: Binding(
                        get: { entry.sleepScore },
                        set: { entry.sleepScore = $0; recalcSand() }
                    )
                )
                DiagnosticRow(
                    icon: "bolt", label: "活力",
                    score: Binding(
                        get: { entry.energyScore },
                        set: { entry.energyScore = $0; recalcSand() }
                    )
                )
                DiagnosticRow(
                    icon: "heart", label: "心",
                    score: Binding(
                        get: { entry.moodScore },
                        set: { entry.moodScore = $0; recalcSand() }
                    )
                )
                DiagnosticRow(
                    icon: "leaf", label: "つながり",
                    score: Binding(
                        get: { entry.connectionScore },
                        set: { entry.connectionScore = $0; recalcSand() }
                    )
                )
                DiagnosticRow(
                    icon: "sparkles", label: "創造力",
                    score: Binding(
                        get: { entry.creativityScore },
                        set: { entry.creativityScore = $0; recalcSand() }
                    )
                )
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(paperCard)
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }

    // MARK: - 習慣チェック

    private var habitsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "今日の習慣", icon: "checkmark.circle")

            if let entry = todayEntry {
                ForEach(defaultHabits, id: \.self) { habit in
                    let isDone = entry.completedHabits.contains(habit)
                    Button {
                        var habits = entry.completedHabits
                        if isDone {
                            habits.removeAll { $0 == habit }
                        } else {
                            habits.append(habit)
                        }
                        entry.completedHabits = habits
                        recalcSand()
                        saveEntry()
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(isDone
                                          ? Color(hex: "4A6A2A").opacity(0.25)
                                          : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(
                                                isDone
                                                ? Color(hex: "6A9A4A")
                                                : Color(hex: "8AAA5A").opacity(0.5),
                                                lineWidth: 1
                                            )
                                    )
                                    .frame(width: 22, height: 22)
                                if isDone {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(Color(hex: "4A7A2A"))
                                }
                            }

                            Text(habit)
                                .font(.system(size: 15, weight: .light, design: .serif))
                                .foregroundStyle(isDone
                                    ? Color(hex: "4A7A2A")
                                    : Color(hex: "3A5028"))
                                .strikethrough(isDone, color: Color(hex: "4A6A2A"))

                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(paperCard)
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }

    // MARK: - 今週のカレンダー

    private var weekCalendar: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "今週の記録", icon: "calendar")

            HStack(spacing: 0) {
                ForEach(weekDays, id: \.self) { day in
                    let entry = allEntries.first {
                        Calendar.current.isDate($0.date, inSameDayAs: day)
                    }
                    let isToday = Calendar.current.isDate(day, inSameDayAs: today)
                    let level   = entry?.averageScore ?? 0

                    VStack(spacing: 6) {
                        Text(day.formatted(.dateTime.weekday(.narrow)
                            .locale(Locale(identifier: "ja_JP"))))
                            .font(.system(size: 10, weight: .light))
                            .foregroundStyle(Color(hex: "3A5028"))

                        ZStack {
                            Circle()
                                .fill(Color(hex: "E8F2E0"))
                                .overlay(
                                    Circle().stroke(
                                        isToday
                                        ? Color(hex: "6A9A4A")
                                        : Color(hex: "8AAA5A").opacity(0.4),
                                        lineWidth: isToday ? 1.5 : 0.5
                                    )
                                )
                                .frame(width: 36, height: 36)

                            if level > 0 {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(hex: "8AAA5A").opacity(level * 0.9),
                                                Color(hex: "4A6A2A").opacity(level * 0.6)
                                            ],
                                            startPoint: .top, endPoint: .bottom
                                        )
                                    )
                                    .frame(width: CGFloat(36) * level, height: CGFloat(36) * level)
                                    .clipShape(Circle())
                            }

                            Text("\(Calendar.current.component(.day, from: day))")
                                .font(.system(size: 11, weight: .light))
                                .foregroundStyle(
                                    level > 0.5
                                    ? Color(hex: "F0F8E8")
                                    : Color(hex: "3A5028")
                                )
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(paperCard)
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }

    // MARK: - 紙カード背景

    private var paperCard: some View {
        GeometryReader { geo in
            Image("stardust_page.jpg")
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
                .opacity(0.90)
        }
    }

    // MARK: - ヘルパー

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(Color(hex: "5A7A4A"))
            Text(title)
                .font(.system(size: 13, weight: .light))
                .foregroundStyle(Color(hex: "8A9A7A"))
                .tracking(1)
        }
    }

    private func loadOrCreateToday() {
        let existing = allEntries.first {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }
        if let e = existing {
            todayEntry = e
        } else {
            let e = HourglassEntry(date: today)
            context.insert(e)
            try? context.save()
            todayEntry = e
        }
        withAnimation(.spring(response: 1.4, dampingFraction: 0.7).delay(0.3)) {
            appeared = true
            recalcSand()
        }
    }

    private func recalcSand() {
        guard let entry = todayEntry else { return }
        let diagScore  = entry.averageScore
        let habitScore = defaultHabits.isEmpty ? 0.0
            : Double(entry.completedHabits.count) / Double(defaultHabits.count)
        let combined   = diagScore * 0.6 + habitScore * 0.4
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            sandLevel = CGFloat(combined)
        }
        saveEntry()
    }

    private func saveEntry() {
        try? context.save()
    }
}

// MARK: - 問診スコア行

private struct DiagnosticRow: View {
    let icon:  String
    let label: String
    @Binding var score: Int

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Color(hex: "5A7A4A"))
                .frame(width: 20)

            Text(label)
                .font(.system(size: 14, weight: .light, design: .serif))
                .foregroundStyle(Color(hex: "8A9A7A"))
                .frame(width: 60, alignment: .leading)

            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { i in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            score = (score == i) ? 0 : i
                        }
                    } label: {
                        Circle()
                            .fill(i <= score
                                  ? Color(hex: "6A9A4A")
                                  : Color(hex: "E8F2E0"))
                            .overlay(
                                Circle().stroke(
                                    i <= score
                                    ? Color(hex: "8AAA5A")
                                    : Color(hex: "8AAA5A").opacity(0.4),
                                    lineWidth: 1
                                )
                            )
                            .frame(width: 22, height: 22)
                            .scaleEffect(i == score ? 1.15 : 1.0)
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()
        }
    }
}

// MARK: - 砂時計シェイプ（砂レベルアニメーション対応）

private struct HourglassShape: View {
    var sandLevel: CGFloat   // 0.0〜1.0

    var body: some View {
        ZStack {
            // 外枠（砂時計のガラス部分）
            HourglassOutline()
                .stroke(Color(hex: "3A5A2A"), lineWidth: 1.5)

            // 内部の砂（下半分に溜まる）
            HourglassSand(level: sandLevel)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "8AAA5A").opacity(0.7),
                            Color(hex: "4A6A2A").opacity(0.9)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .clipShape(HourglassOutline())

            // 上半分（残り砂）
            HourglassTopSand(level: 1 - sandLevel)
                .fill(Color(hex: "2A4A1A").opacity(0.5))
                .clipShape(HourglassOutline())

            // 中央くびれ点（砂が落ちる演出）
            if sandLevel > 0 && sandLevel < 1 {
                Circle()
                    .fill(Color(hex: "AACC7A").opacity(0.6))
                    .frame(width: 3, height: 3)
                    .blur(radius: 1)
                    .offset(y: 0)
            }

            // アウトライングロー
            HourglassOutline()
                .stroke(Color(hex: "6A9A4A").opacity(0.3), lineWidth: 4)
                .blur(radius: 4)
        }
    }
}

/// 砂時計の外形パス（上下対称の台形が中心でくびれた形）
private struct HourglassOutline: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let mx = rect.midX
        let neckW: CGFloat = w * 0.06   // くびれ幅
        let topW:  CGFloat = w * 0.44   // 上下の幅

        var p = Path()
        // 上フレーム（逆台形）
        p.move(to: CGPoint(x: mx - topW, y: rect.minY + 4))
        p.addLine(to: CGPoint(x: mx + topW, y: rect.minY + 4))
        p.addLine(to: CGPoint(x: mx + neckW, y: rect.midY))
        p.addLine(to: CGPoint(x: mx - neckW, y: rect.midY))
        p.closeSubpath()

        // 下フレーム（台形）
        p.move(to: CGPoint(x: mx - neckW, y: rect.midY))
        p.addLine(to: CGPoint(x: mx + neckW, y: rect.midY))
        p.addLine(to: CGPoint(x: mx + topW, y: rect.maxY - 4))
        p.addLine(to: CGPoint(x: mx - topW, y: rect.maxY - 4))
        p.closeSubpath()

        return p
    }
}

/// 下半分の砂（level: 充填率 0-1）
private struct HourglassSand: Shape {
    var level: CGFloat
    var animatableData: CGFloat {
        get { level }
        set { level = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let w    = rect.width
        let mx   = rect.midX
        let mid  = rect.midY
        let bot  = rect.maxY - 4
        let topW: CGFloat = w * 0.44
        let neckW: CGFloat = w * 0.06

        // 下半分の高さに対する充填高さ
        let halfH   = bot - mid
        let sandTop = bot - halfH * level

        // 砂の上辺の幅（線形補間）
        let t     = min(max(level, 0), 1)
        let sandW = neckW + (topW - neckW) * t

        var p = Path()
        p.move(to: CGPoint(x: mx - sandW, y: sandTop))
        p.addLine(to: CGPoint(x: mx + sandW, y: sandTop))
        p.addLine(to: CGPoint(x: mx + topW,  y: bot))
        p.addLine(to: CGPoint(x: mx - topW,  y: bot))
        p.closeSubpath()
        return p
    }
}

/// 上半分の残り砂
private struct HourglassTopSand: Shape {
    var level: CGFloat
    var animatableData: CGFloat {
        get { level }
        set { level = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let w    = rect.width
        let mx   = rect.midX
        let top  = rect.minY + 4
        let mid  = rect.midY
        let topW: CGFloat = w * 0.44
        let neckW: CGFloat = w * 0.06

        let halfH   = mid - top
        let sandBot = top + halfH * level
        let t       = min(max(level, 0), 1)
        let sandW   = neckW + (topW - neckW) * t

        var p = Path()
        p.move(to: CGPoint(x: mx - topW,  y: top))
        p.addLine(to: CGPoint(x: mx + topW,  y: top))
        p.addLine(to: CGPoint(x: mx + sandW, y: sandBot))
        p.addLine(to: CGPoint(x: mx - sandW, y: sandBot))
        p.closeSubpath()
        return p
    }
}

// MARK: - 背景アンビエンス（緑系）

private struct HourglassAmbience: View {
    @State private var particles: [AmbP] = []

    struct AmbP: Identifiable {
        let id = UUID()
        var x, y, size, speed, phase: CGFloat
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate
                for p in particles {
                    let wave    = (sin(Double(t) * Double(p.speed) + Double(p.phase)) + 1) * 0.5
                    let opacity = 0.03 + wave * 0.07
                    let dy      = CGFloat(t) * p.speed * 7
                    let py      = (p.y - dy).truncatingRemainder(dividingBy: size.height + 20)
                    let ay      = py < -10 ? py + size.height + 20 : py
                    ctx.fill(
                        Path(ellipseIn: CGRect(x: p.x - p.size/2, y: ay - p.size/2,
                                              width: p.size, height: p.size)),
                        with: .color(Color(hex: "8AAA5A").opacity(opacity))
                    )
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onAppear {
            let s = UIScreen.main.bounds
            particles = (0..<30).map { _ in
                AmbP(
                    x: .random(in: 0...s.width),
                    y: .random(in: 0...s.height),
                    size:  .random(in: 1...2.5),
                    speed: .random(in: 0.006...0.018),
                    phase: .random(in: 0...(.pi * 2))
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        HourglassView()
    }
    .modelContainer(for: HourglassEntry.self, inMemory: true)
}
