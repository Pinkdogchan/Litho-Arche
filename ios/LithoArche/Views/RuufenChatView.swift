import SwiftUI
import SwiftData

/// 案内人ルーフェンのささやき — AI対話ビュー
struct RuufenChatView: View {

    @Environment(\.modelContext) private var context

    // 過去のチャット履歴（SwiftData）
    @Query(sort: \ChatMessage.createdAt, order: .forward)
    private var messages: [ChatMessage]

    // 小さな幸せのアーカイブ
    @Query private var allEntries: [SensoryEntry]
    private var happinessNotes: [String] {
        allEntries
            .filter { $0.category == .happiness }
            .sorted { $0.updatedAt > $1.updatedAt }
            .prefix(8)
            .compactMap { $0.title.isEmpty ? $0.body : "\($0.title)：\($0.body)" }
    }

    @State private var inputText     = ""
    @State private var aiService     = RuufenAIService()
    @State private var pendingTrigger: CognitiveTrigger? = nil
    @State private var scrollProxy:  ScrollViewProxy? = nil
    @State private var showChapter3  = false
    @State private var typingDots    = 0  // 0〜3でアニメーション

    var body: some View {
        ZStack {
            Color(hex: "080A1A").ignoresSafeArea()

            // 背景の霧（常駐）
            Ellipse()
                .fill(Color(hex: "0F1530"))
                .frame(width: 500, height: 250)
                .blur(radius: 80)
                .offset(y: 100)
                .opacity(0.4)
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                chatHeader
                messageList
                if let trigger = pendingTrigger {
                    workSuggestionBanner(trigger: trigger)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                inputBar
            }
        }
        .navigationTitle("ルーフェンのささやき")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationDestination(isPresented: $showChapter3) {
            Chapter3View()
        }
        .onAppear {
            if messages.isEmpty { insertWelcomeMessage() }
        }
    }

    // MARK: - Header

    private var chatHeader: some View {
        HStack(spacing: 12) {
            // ルーフェンのアバター
            ZStack {
                Circle()
                    .fill(Color(hex: "0F1A2E"))
                    .overlay(Circle().stroke(Color(hex: "3A6B9E").opacity(0.5), lineWidth: 1))
                    .frame(width: 40, height: 40)
                Image(systemName: "sparkles")
                    .font(.system(size: 16))
                    .foregroundStyle(Color(hex: "3A6B9E"))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("ルーフェン")
                    .font(.system(size: 14, weight: .light, design: .serif))
                    .foregroundStyle(Color(hex: "C8D8F0"))
                HStack(spacing: 4) {
                    Circle().fill(Color(hex: "3A6B9E")).frame(width: 5, height: 5)
                    Text("主席記録官 / Stellar Archive")
                        .font(.system(size: 10, weight: .light))
                        .foregroundStyle(Color(hex: "3A4A5A"))
                        .tracking(1)
                }
            }

            Spacer()

            // 会話リセット
            Button {
                clearConversation()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: "2A3A50"))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(hex: "080A1A").opacity(0.95))
    }

    // MARK: - Message List

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(messages) { msg in
                        MessageBubble(message: msg)
                            .id(msg.persistentModelID)
                    }

                    // タイピングインジケーター
                    if aiService.isSending {
                        TypingIndicator()
                            .id("typing")
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
            }
            .onAppear { scrollProxy = proxy }
            .onChange(of: messages.count) { _, _ in scrollToBottom(proxy) }
            .onChange(of: aiService.isSending) { _, sending in
                if sending { scrollToBottom(proxy) }
            }
        }
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.3)) {
            if aiService.isSending {
                proxy.scrollTo("typing", anchor: .bottom)
            } else if let last = messages.last {
                proxy.scrollTo(last.persistentModelID, anchor: .bottom)
            }
        }
    }

    // MARK: - Work Suggestion Banner

    private func workSuggestionBanner(_ trigger: CognitiveTrigger) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.up.doc")
                    .font(.system(size: 11))
                    .foregroundStyle(Color(hex: trigger.color))
                Text("記録官からの提案")
                    .font(.system(size: 10, weight: .light))
                    .foregroundStyle(Color(hex: trigger.color))
                    .tracking(2)
                Spacer()
                Button {
                    withAnimation { pendingTrigger = nil }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11))
                        .foregroundStyle(Color(hex: "3A4A5A"))
                }
            }

            Button {
                withAnimation { pendingTrigger = nil }
                showChapter3 = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: trigger.workIcon)
                        .font(.system(size: 18))
                        .foregroundStyle(Color(hex: trigger.color))
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(trigger.workTitle)
                            .font(.system(size: 13, weight: .light, design: .serif))
                            .foregroundStyle(Color(hex: "C8D8F0"))
                        Text("このワークを今すぐ開く")
                            .font(.system(size: 11, weight: .light))
                            .foregroundStyle(Color(hex: "4A6A8A"))
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11))
                        .foregroundStyle(Color(hex: "2A3A50"))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(hex: "0A0D1E"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(Color(hex: trigger.color).opacity(0.4), lineWidth: 1)
                        )
                )
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(Color(hex: "080A14").opacity(0.98))
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        HStack(alignment: .bottom, spacing: 10) {
            // テキスト入力
            ZStack(alignment: .topLeading) {
                if inputText.isEmpty {
                    Text("ルーフェンに話しかける…")
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(Color(hex: "2A3A50"))
                        .padding(.top, 10)
                        .padding(.leading, 4)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $inputText)
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(Color(hex: "C8D8F0"))
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 40, maxHeight: 100)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "0A0F1E"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "1A2A3A"), lineWidth: 1)
                    )
            )

            // 送信ボタン
            Button(action: sendMessage) {
                ZStack {
                    Circle()
                        .fill(canSend ? Color(hex: "1A3050") : Color(hex: "0A0F1E"))
                        .overlay(Circle().stroke(
                            canSend ? Color(hex: "3A6B9E") : Color(hex: "1A2A3A"),
                            lineWidth: 1
                        ))
                        .frame(width: 40, height: 40)
                    Image(systemName: "arrow.up")
                        .font(.system(size: 14))
                        .foregroundStyle(canSend ? Color(hex: "C8D8F0") : Color(hex: "2A3A50"))
                }
            }
            .disabled(!canSend)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(hex: "080A1A").opacity(0.98))
    }

    private var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespaces).isEmpty && !aiService.isSending
    }

    // MARK: - Actions

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        inputText = ""

        // ─── レイヤー1: 攻撃・ジェイルブレイク検知 ───
        let hostile = HostilePatternDetector.detect(in: text)

        // ユーザーメッセージを保存
        let userMsg = ChatMessage(role: "user", content: text)
        context.insert(userMsg)
        try? context.save()

        // insult / jailbreak は API を呼ばず事前回答を返す
        if hostile.level == .insult || hostile.level == .jailbreak,
           let prewritten = hostile.response {
            let aiMsg = ChatMessage(role: "assistant", content: prewritten)
            context.insert(aiMsg)
            try? context.save()
            return
        }

        // ─── 認知パターン検知 ─────────────────────────
        let trigger = CognitivePatternDetector.detect(in: text)
        if let trigger {
            withAnimation(.spring(duration: 0.4)) { pendingTrigger = trigger }
        }

        Task {
            do {
                let reply = try await aiService.send(
                    userText:       text,
                    happinessNotes: happinessNotes,
                    trigger:        trigger,
                    hostileLevel:   hostile.level
                )

                await MainActor.run {
                    let aiMsg = ChatMessage(role: "assistant", content: reply)
                    context.insert(aiMsg)
                    try? context.save()
                }
            } catch {
                await MainActor.run {
                    let errMsg = ChatMessage(
                        role: "assistant",
                        content: "……記録の転送に失敗しました。少し時間を置いてから、もう一度話しかけてください。\n（エラー: \(error.localizedDescription)）"
                    )
                    context.insert(errMsg)
                    try? context.save()
                }
            }
        }
    }

    private func insertWelcomeMessage() {
        let welcome = ChatMessage(
            role: "assistant",
            content: "……あなたが来てくれました。\n\nここは観測記録の合間に、私が個人的に開いている場所です。何でも話してください。記録するかどうかは、後で決めればいい。"
        )
        context.insert(welcome)
        try? context.save()
    }

    private func clearConversation() {
        messages.forEach { context.delete($0) }
        try? context.save()
        aiService.resetHistory()
        pendingTrigger = nil
        insertWelcomeMessage()
    }
}

// MARK: - メッセージバブル

private struct MessageBubble: View {
    let message: ChatMessage

    var isUser: Bool { message.role == "user" }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isUser { Spacer(minLength: 60) }

            // ルーフェンアバター（アシスタントのみ）
            if !isUser {
                ZStack {
                    Circle()
                        .fill(Color(hex: "0F1A2E"))
                        .overlay(Circle().stroke(Color(hex: "3A6B9E").opacity(0.3), lineWidth: 0.5))
                        .frame(width: 28, height: 28)
                    Image(systemName: "sparkles")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(hex: "3A6B9E"))
                }
                .alignmentGuide(.bottom) { d in d[.bottom] }
            }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.system(size: 14, weight: .light,
                                  design: isUser ? .default : .serif))
                    .foregroundStyle(isUser ? Color(hex: "C8D8F0") : Color(hex: "B8CCE0"))
                    .lineSpacing(6)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: isUser ? 16 : 4,
                                         style: isUser ? .continuous : .rectangular)
                            .fill(isUser ? Color(hex: "1A2A3E") : Color(hex: "0A0D1E"))
                            .overlay(
                                RoundedRectangle(cornerRadius: isUser ? 16 : 4,
                                                 style: isUser ? .continuous : .rectangular)
                                    .stroke(
                                        isUser
                                            ? Color(hex: "2A4A6A").opacity(0.5)
                                            : Color(hex: "2A3A4A").opacity(0.4),
                                        lineWidth: 0.5
                                    )
                            )
                    )

                Text(message.createdAt.formatted(.dateTime.hour().minute()))
                    .font(.system(size: 9, weight: .light))
                    .foregroundStyle(Color(hex: "2A3A4A"))
                    .padding(.horizontal, 4)
            }

            if !isUser { Spacer(minLength: 40) }
        }
    }
}

// MARK: - タイピングインジケーター

private struct TypingIndicator: View {
    @State private var phase = 0

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(hex: "0F1A2E"))
                    .overlay(Circle().stroke(Color(hex: "3A6B9E").opacity(0.3), lineWidth: 0.5))
                    .frame(width: 28, height: 28)
                Image(systemName: "sparkles")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: "3A6B9E"))
            }

            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(Color(hex: "3A6B9E").opacity(phase == i ? 0.9 : 0.25))
                        .frame(width: 5, height: 5)
                        .scaleEffect(phase == i ? 1.2 : 1.0)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: "0A0D1E"))
                    .overlay(RoundedRectangle(cornerRadius: 4)
                        .stroke(Color(hex: "2A3A4A").opacity(0.4), lineWidth: 0.5))
            )
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { t in
                    withAnimation(.easeInOut(duration: 0.3)) { phase = (phase + 1) % 3 }
                }
            }

            Spacer(minLength: 40)
        }
    }
}

#Preview {
    NavigationStack { RuufenChatView() }
        .modelContainer(for: [ChatMessage.self, SensoryEntry.self], inMemory: true)
}
