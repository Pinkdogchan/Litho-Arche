import SwiftUI
import SwiftData

// MARK: - Screen 4: 断片の収集ワーク

struct FragmentWorkView: View {

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    // ── 状態 ──────────────────────────────────────────
    @State private var messages:     [FragmentMessage] = []
    @State private var inputText     = ""
    @State private var spikyness:    CGFloat = 1.0      // クリーチャーの状態
    @State private var isPurified    = false
    @State private var purificationDone = false
    @State private var archiveReady  = false
    @State private var sessionId     = UUID().uuidString
    @State private var turnCount     = 0
    @State private var canInput      = false
    @State private var isLoading     = false

    // ── 音声 ─────────────────────────────────────────
    @State private var speech        = SpeechRecognizer()
    @State private var isListening   = false

    // ── AI ───────────────────────────────────────────
    @State private var aiService     = RuufenAIService()

    // ── UI ───────────────────────────────────────────
    @State private var bgLightness:  Double = 0   // 0=暗 → 1=浄化後の明るさ
    @State private var appeared      = false

    // 断片収集専用のシステムプロンプト（aiService に注入）
    private let fragmentSystemOverride = """
    あなたはLitho-Archeの主席記録官ルーフェンです。
    今、「断片の収集ワーク」という特別なセッションを行っています。

    【このワークの目的】
    ユーザーの心の中にある未処理の感情や痛みを「観測し、記録する」ことで、
    それを「存在する何か」として扱い、少し距離を取れるようにする。

    【質問の進め方】
    - 全部で3問のみ。急がせない。
    - 第1問: 最近心にある「モヤモヤ」や「トゲのある感情」を一つ選んでもらう
    - 第2問: その感情が一番大きくなる瞬間や状況を聞く
    - 第3問: その感情に形や色や生き物があるとしたら、どんなものか想像してもらう
    - 各問の後は、ユーザーの答えを短く受け取ったことを示してから次に進む

    【口調と態度】
    - 静かで、温かく、急かさない
    - 答えを評価しない。「正しい」「間違い」はない
    - 答えが返ってきたら、その言葉を一つだけ拾って短く応答してから次の問いへ
    - 3問終わったら「記録の準備ができました。断片を封じる準備ができたら、ボタンを押してください」と伝える
    - その後は何も追加しない

    【返答の長さ】
    各返答は2〜3文以内。余白を大切に。
    """

    var body: some View {
        ZStack {
            // ── 背景グラデーション ────────────────────
            // 感情の解放に合わせて暗→明へ
            LinearGradient(
                colors: [
                    Color(
                        red:   0.04 + bgLightness * 0.04,
                        green: 0.03 + bgLightness * 0.06,
                        blue:  0.08 + bgLightness * 0.14
                    ),
                    Color(hex: "07091A")
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1.5), value: bgLightness)

            VStack(spacing: 0) {

                // ── クリーチャーエリア（上半分） ──────
                creatureArea

                // ── 対話エリア（下半分） ──────────────
                dialogueArea
            }

            // ── 浄化完了オーバーレイ ──────────────────
            if purificationDone {
                purificationCompleteOverlay
                    .transition(.opacity)
            }
        }
        .navigationTitle("断片の収集")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear(perform: startSession)
        .onChange(of: speech.state) { _, s in
            if case .matched = s { /* 音声認識は transcript で取得 */ return }
        }
    }

    // MARK: - クリーチャーエリア

    private var creatureArea: some View {
        ZStack {
            // クリーチャー
            FragmentCreatureView(
                spikyness:  spikyness,
                isPurified: isPurified
            ) {
                // バースト完了 → 浄化完了画面へ
                withAnimation(.easeIn(duration: 0.6)) { purificationDone = true }
            }

            // ステータステキスト（クリーチャーの下）
            VStack {
                Spacer()
                creatureStatusLabel
                    .padding(.bottom, 12)
            }
        }
        .frame(maxHeight: UIScreen.main.bounds.height * 0.44)
        .opacity(appeared ? 1 : 0)
    }

    private var creatureStatusLabel: some View {
        VStack(spacing: 4) {
            // 感情ゲージ（spikyness の逆数）
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(hex: "1A2A3A"))
                        .frame(height: 3)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "7A3A4A"), Color(hex: "3A6B9E")],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(1 - spikyness), height: 3)
                        .animation(.spring(response: 0.8), value: spikyness)
                }
            }
            .frame(width: 160, height: 3)

            Text(creatureStateText)
                .font(.system(size: 10, weight: .light))
                .foregroundStyle(Color(hex: "3A4A5A"))
                .tracking(2)
        }
    }

    private var creatureStateText: String {
        switch spikyness {
        case 0.8...1.0: return "断片体 — 未記録"
        case 0.5..<0.8: return "断片体 — 観測中"
        case 0.2..<0.5: return "断片体 — 変容中"
        default:        return "断片体 — 封印準備完了"
        }
    }

    // MARK: - 対話エリア

    private var dialogueArea: some View {
        VStack(spacing: 0) {
            // メッセージリスト
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(messages) { msg in
                            FragmentBubble(message: msg)
                                .id(msg.id)
                        }
                        if isLoading { loadingDots }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .onChange(of: messages.count) { _, _ in
                    withAnimation { proxy.scrollTo(messages.last?.id, anchor: .bottom) }
                }
                .onChange(of: isLoading) { _, v in
                    if v { withAnimation { proxy.scrollTo("loading", anchor: .bottom) } }
                }
            }

            Divider().background(Color(hex: "1A2A3A"))

            // 入力バー + アーカイブボタン
            if archiveReady && !isPurified {
                archiveButton
            } else if canInput && !archiveReady {
                fragmentInputBar
            }
        }
        .background(Color(hex: "07091A").opacity(0.95))
        .frame(maxHeight: UIScreen.main.bounds.height * 0.56)
    }

    // MARK: - 入力バー

    private var fragmentInputBar: some View {
        HStack(alignment: .bottom, spacing: 10) {
            // テキスト入力
            ZStack(alignment: .topLeading) {
                if inputText.isEmpty && !isListening {
                    Text("ここに答えを書く…")
                        .font(.system(size: 14, weight: .light, design: .serif))
                        .foregroundStyle(Color(hex: "2A3A50"))
                        .padding(.top, 10).padding(.leading, 4)
                        .allowsHitTesting(false)
                }
                if isListening {
                    Text(speech.transcript.isEmpty ? "聴いています…" : speech.transcript)
                        .font(.system(size: 14, weight: .light, design: .serif))
                        .foregroundStyle(Color(hex: "5A7A9A"))
                        .padding(.top, 10).padding(.leading, 4)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $inputText)
                    .font(.system(size: 14, weight: .light, design: .serif))
                    .foregroundStyle(Color(hex: "C8D8F0"))
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 40, maxHeight: 90)
                    .opacity(isListening ? 0.3 : 1)
            }
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(hex: "0A0F1E"))
                    .overlay(RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(hex: "1A2A3A"), lineWidth: 1))
            )

            // 音声ボタン
            Button { toggleVoice() } label: {
                Circle()
                    .fill(isListening ? Color(hex: "1A3050") : Color(hex: "0A0F1E"))
                    .overlay(Circle().stroke(
                        isListening ? Color(hex: "3A6B9E") : Color(hex: "1A2A3A"),
                        lineWidth: 1)
                    )
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: isListening ? "mic.fill" : "mic")
                            .font(.system(size: 15))
                            .foregroundStyle(isListening
                                             ? Color(hex: "C8D8F0")
                                             : Color(hex: "3A4A5A"))
                    )
            }

            // 送信ボタン
            Button { sendUserReply() } label: {
                Circle()
                    .fill(canSend ? Color(hex: "1A3050") : Color(hex: "0A0F1E"))
                    .overlay(Circle().stroke(
                        canSend ? Color(hex: "3A6B9E") : Color(hex: "1A2A3A"),
                        lineWidth: 1)
                    )
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "arrow.up")
                            .font(.system(size: 14))
                            .foregroundStyle(canSend
                                             ? Color(hex: "C8D8F0")
                                             : Color(hex: "2A3A50"))
                    )
            }
            .disabled(!canSend)
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
    }

    private var canSend: Bool {
        !isLoading && (
            !inputText.trimmingCharacters(in: .whitespaces).isEmpty ||
            (!speech.transcript.isEmpty && isListening == false)
        )
    }

    // MARK: - アーカイブボタン

    private var archiveButton: some View {
        Button { beginPurification() } label: {
            HStack(spacing: 12) {
                DiamondShape()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "6AAAD0"), Color(hex: "2A5A80")],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 20, height: 20)
                    .shadow(color: Color(hex: "3A6B9E").opacity(0.8), radius: 8)

                Text("断片を封じる")
                    .font(.system(size: 15, weight: .light, design: .serif))
                    .foregroundStyle(Color(hex: "C8D8F0"))
                    .tracking(1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: "0A1428"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color(hex: "3A6B9E").opacity(0.7), lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    // MARK: - ローディングドット

    private var loadingDots: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Color(hex: "3A6B9E").opacity(0.6))
                    .frame(width: 5, height: 5)
            }
        }
        .padding(.leading, 20)
        .id("loading")
    }

    // MARK: - 浄化完了オーバーレイ

    private var purificationCompleteOverlay: some View {
        ZStack {
            Color(hex: "07091A").opacity(0.92).ignoresSafeArea()

            VStack(spacing: 28) {
                // 浄化された結晶体
                ZStack {
                    Circle()
                        .fill(Color(hex: "3A6B9E").opacity(0.2))
                        .frame(width: 140, height: 140)
                        .blur(radius: 30)

                    ForEach(0..<8, id: \.self) { i in
                        DiamondShape()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "8ACAE8"), Color(hex: "2A5A80")],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                            .frame(width: CGFloat([14, 10, 14, 10, 14, 10, 14, 10][i]),
                                   height: CGFloat([14, 10, 14, 10, 14, 10, 14, 10][i]))
                            .offset(
                                x: cos(.pi * 2 / 8 * CGFloat(i)) * 44,
                                y: sin(.pi * 2 / 8 * CGFloat(i)) * 44
                            )
                            .opacity(0.7)
                    }

                    DiamondShape()
                        .fill(
                            RadialGradient(
                                colors: [Color(hex: "C8E8FF"), Color(hex: "3A6B9E")],
                                center: .center, startRadius: 0, endRadius: 24
                            )
                        )
                        .frame(width: 48, height: 48)
                        .shadow(color: Color(hex: "3A6B9E").opacity(0.9), radius: 20)
                }

                VStack(spacing: 12) {
                    Text("断片は記録されました")
                        .font(.system(size: 20, weight: .thin, design: .serif))
                        .foregroundStyle(Color(hex: "C8D8F0"))

                    Text("この感情は、もう「無かったこと」にはなりません。\nアーカイブの中で、静かに存在し続けます。")
                        .font(.system(size: 13, weight: .light))
                        .foregroundStyle(Color(hex: "5A7A9A"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                }

                Button {
                    dismiss()
                } label: {
                    Text("聖域に戻る")
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(Color(hex: "C8D8F0"))
                        .frame(width: 180, height: 46)
                        .overlay(
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(Color(hex: "3A6B9E").opacity(0.5), lineWidth: 1)
                        )
                }
            }
            .padding(32)
        }
    }

    // MARK: - セッション開始

    private func startSession() {
        // aiService のシステムプロンプトを断片収集専用に設定
        aiService.apiKey = Bundle.main.object(forInfoDictionaryKey: "GeminiAPIKey") as? String ?? ""

        withAnimation(.easeIn(duration: 0.8).delay(0.3)) { appeared = true }

        // 最初のルーフェンメッセージ
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            appendMessage(role: "rufen",
                          text: "……あなたがここへ来てくれました。\nこの場所では、急ぐ必要はありません。")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            appendMessage(role: "rufen",
                          text: "断片の収集を始める前に、一つだけ確認させてください。\n今この瞬間、あなたの心の中に「トゲのある何か」はありますか？")
            canInput = true
        }
    }

    // MARK: - ユーザー回答送信

    private func sendUserReply() {
        var text = inputText.trimmingCharacters(in: .whitespaces)
        if text.isEmpty { text = speech.transcript }
        guard !text.isEmpty else { return }

        inputText = ""
        speech.stopListening()
        isListening = false
        canInput    = false
        isLoading   = true

        // ユーザー発言を追加
        appendMessage(role: "user", text: text)

        // 断片エントリを保存
        let entry = FragmentEntry(sessionId: sessionId,
                                  promptText: messages.filter { $0.role == "rufen" }.last?.text ?? "",
                                  turnIndex: turnCount)
        entry.responseText = text
        context.insert(entry)
        try? context.save()

        turnCount += 1

        // spikyness を段階的に下げる（3問で0.2まで）
        let targetSpikyness = max(0.15, 1.0 - CGFloat(turnCount) * 0.28)
        withAnimation(.spring(response: 1.0, dampingFraction: 0.7)) {
            spikyness    = targetSpikyness
            bgLightness  = Double(1.0 - targetSpikyness) * 0.5
        }

        // Gemini に断片収集専用コンテキストで送信
        Task {
            do {
                let systemPrompt = fragmentSystemOverride
                let prompt = buildFragmentPrompt(userText: text, turn: turnCount)
                let reply  = try await callFragmentAI(systemPrompt: systemPrompt, userText: prompt)

                await MainActor.run {
                    isLoading = false
                    appendMessage(role: "rufen", text: reply)
                    canInput = turnCount < 3

                    // 3問完了でアーカイブボタン表示
                    if turnCount >= 3 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation(.spring(duration: 0.5)) { archiveReady = true }
                            withAnimation(.spring(response: 0.8)) { spikyness = 0.12 }
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    appendMessage(role: "rufen",
                                  text: "……記録の転送が途切れました。もう一度話しかけてください。")
                    canInput = true
                }
            }
        }
    }

    // MARK: - 浄化シーケンス

    private func beginPurification() {
        archiveReady = false
        canInput     = false

        appendMessage(role: "rufen",
                      text: "記録します。\nこの断片は、もう「無かったこと」にはなりません。")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                spikyness   = 0.0
                bgLightness = 0.8
            }
            // isPurified = true でバースト開始
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                isPurified = true

                // 全断片エントリを封印済みに更新
                let sid = sessionId
                let req = FetchDescriptor<FragmentEntry>(
                    predicate: #Predicate { $0.sessionId == sid }
                )
                if let entries = try? context.fetch(req) {
                    entries.forEach { e in
                        e.isArchived = true
                        e.archivedAt = .now
                    }
                    try? context.save()
                }
            }
        }
    }

    // MARK: - 音声トグル

    private func toggleVoice() {
        if isListening {
            speech.stopListening()
            isListening = false
            if !speech.transcript.isEmpty {
                inputText   = speech.transcript
            }
        } else {
            speech.magicWord = ""  // 魔法の言葉照合は不要
            speech.startListening()
            isListening = true
        }
    }

    // MARK: - Helpers

    private func appendMessage(role: String, text: String) {
        withAnimation {
            messages.append(FragmentMessage(role: role, text: text))
        }
    }

    private func buildFragmentPrompt(userText: String, turn: Int) -> String {
        "【\(turn)問目への回答】\(userText)"
    }

    /// 断片収集専用のGemini呼び出し（シンプルなシングルターン）
    private func callFragmentAI(systemPrompt: String, userText: String) async throws -> String {
        // RuufenAIService の send を断片専用プロンプトで呼ぶ
        // (hapinessNotes は不要、trigger も不要)
        return try await aiService.send(
            userText:       userText,
            happinessNotes: [],
            trigger:        nil
        )
    }
}

// MARK: - メッセージモデル（一時的、SwiftData非使用）

struct FragmentMessage: Identifiable {
    let id   = UUID()
    let role: String  // "rufen" or "user"
    let text: String
}

// MARK: - 対話バブル

private struct FragmentBubble: View {
    let message: FragmentMessage

    var isUser: Bool { message.role == "user" }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isUser { Spacer(minLength: 50) }

            if !isUser {
                ZStack {
                    Circle()
                        .fill(Color(hex: "0F1A2E"))
                        .overlay(Circle().stroke(Color(hex: "7A3A4A").opacity(0.5), lineWidth: 1))
                        .frame(width: 28, height: 28)
                    Image(systemName: "sparkles")
                        .font(.system(size: 11))
                        .foregroundStyle(Color(hex: "7A3A4A"))
                }
            }

            Text(message.text)
                .font(.system(size: 14, weight: .light,
                              design: isUser ? .default : .serif))
                .foregroundStyle(isUser ? Color(hex: "C8D8F0") : Color(hex: "B0C4D8"))
                .lineSpacing(6)
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: isUser ? 14 : 4,
                                     style: .continuous)
                        .fill(isUser ? Color(hex: "1A2A3E") : Color(hex: "0C1020"))
                        .overlay(
                            RoundedRectangle(cornerRadius: isUser ? 14 : 4,
                                             style: .continuous)
                                .stroke(
                                    (isUser ? Color(hex: "2A4060") : Color(hex: "7A3A4A"))
                                        .opacity(0.35),
                                    lineWidth: 0.5
                                )
                        )
                )

            if !isUser { Spacer(minLength: 40) }
        }
    }
}

#Preview {
    NavigationStack {
        FragmentWorkView()
    }
    .modelContainer(for: [FragmentEntry.self, ChatMessage.self, SensoryEntry.self], inMemory: true)
}
