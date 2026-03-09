import SwiftUI
import SwiftData

/// ワーク01: 未完成の観測ログ
/// ルーフェンが書きかけた記録に、ユーザーが続きを書いて完成させる
struct UnfinishedLogView: View {

    @Query private var responses: [LogResponse]
    @Environment(\.modelContext) private var context

    @State private var selectedPrompt: ObservationPrompt? = nil

    var body: some View {
        ZStack {
            Color(hex: "080A1A").ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    pageHeader

                    VStack(spacing: 14) {
                        ForEach(ObservationPrompt.seeds) { prompt in
                            let response = responses.first(where: { $0.promptId == prompt.id })
                            PromptCard(prompt: prompt, response: response) {
                                selectedPrompt = prompt
                            }
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.bottom, 60)
                }
            }
        }
        .navigationTitle("未完成の観測ログ")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(item: $selectedPrompt) { prompt in
            UnfinishedLogEditorSheet(
                prompt: prompt,
                existing: responses.first(where: { $0.promptId == prompt.id })
            ) { text in
                saveResponse(promptId: prompt.id, text: text)
            }
        }
    }

    // MARK: - Header

    private var pageHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "doc.text")
                    .font(.system(size: 11))
                    .foregroundStyle(Color(hex: "3A6B9E"))
                Text("OBSERVATION LOG — INCOMPLETE")
                    .font(.system(size: 10, weight: .light))
                    .foregroundStyle(Color(hex: "3A6B9E"))
                    .tracking(2)
            }

            Text("ルーフェンは記録を中断した。\n続きはあなたが書いてください。")
                .font(.system(size: 14, weight: .light))
                .foregroundStyle(Color(hex: "5A7A9A"))
                .lineSpacing(6)

            // 完了数インジケーター
            let done = responses.filter(\.isSaved).count
            let total = ObservationPrompt.seeds.count
            VStack(alignment: .leading, spacing: 6) {
                Text("\(done) / \(total) 完成")
                    .font(.system(size: 10, weight: .light))
                    .foregroundStyle(Color(hex: "3A4A5A"))
                    .tracking(1)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Color(hex: "1A2A3A"))
                            .frame(height: 2)
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Color(hex: "3A6B9E"))
                            .frame(width: total > 0
                                   ? geo.size.width * CGFloat(done) / CGFloat(total)
                                   : 0,
                                   height: 2)
                            .animation(.spring(duration: 0.5), value: done)
                    }
                }
                .frame(height: 2)
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 24)
        .padding(.bottom, 28)
    }

    // MARK: - Actions

    private func saveResponse(promptId: String, text: String) {
        if let existing = responses.first(where: { $0.promptId == promptId }) {
            existing.responseText = text
            existing.completedAt  = .now
            existing.isSaved      = !text.trimmingCharacters(in: .whitespaces).isEmpty
        } else {
            let resp = LogResponse(promptId: promptId, responseText: text)
            resp.isSaved = !text.trimmingCharacters(in: .whitespaces).isEmpty
            context.insert(resp)
        }
        try? context.save()
    }
}

// MARK: - プロンプトカード

private struct PromptCard: View {
    let prompt:   ObservationPrompt
    let response: LogResponse?
    let onTap:    () -> Void

    var isCompleted: Bool { response?.isSaved == true }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {

                // カテゴリー + 状態
                HStack {
                    Text(prompt.category)
                        .font(.system(size: 10, weight: .light))
                        .foregroundStyle(prompt.accentColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(prompt.accentColor.opacity(0.12))
                        .clipShape(Capsule())

                    Spacer()

                    if isCompleted {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 11))
                            Text("記録完了")
                                .font(.system(size: 10, weight: .light))
                        }
                        .foregroundStyle(prompt.accentColor.opacity(0.8))
                    } else {
                        Text("未完成")
                            .font(.system(size: 10, weight: .light))
                            .foregroundStyle(Color(hex: "3A4A5A"))
                    }
                }

                // ルーフェンの書きかけ文
                Text(prompt.fragment + "……")
                    .font(.system(size: 14, weight: .light, design: .serif))
                    .foregroundStyle(Color(hex: "A0B0C0"))
                    .lineSpacing(6)
                    .lineLimit(3)

                // ユーザーの回答プレビュー（完了済みのみ）
                if isCompleted, let text = response?.responseText, !text.isEmpty {
                    Divider().background(prompt.accentColor.opacity(0.2))
                    Text(text)
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(Color(hex: "6A8AAA"))
                        .lineSpacing(4)
                        .lineLimit(2)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: "0A0D1E"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(
                                isCompleted
                                    ? prompt.accentColor.opacity(0.35)
                                    : Color(hex: "1A2A3A"),
                                lineWidth: 0.5
                            )
                    )
            )
            // 完了済みは左端にアクセントバー
            .overlay(alignment: .leading) {
                if isCompleted {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(prompt.accentColor)
                        .frame(width: 2)
                        .padding(.vertical, 12)
                }
            }
        }
    }
}

// MARK: - ログ編集シート

private struct UnfinishedLogEditorSheet: View {
    let prompt:    ObservationPrompt
    let existing:  LogResponse?
    let onSave:    (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var text: String = ""
    @State private var showCompletionFlash = false

    var body: some View {
        ZStack {
            Color(hex: "080A1A").ignoresSafeArea()
            prompt.accentColor.opacity(0.04).ignoresSafeArea()

            VStack(spacing: 0) {
                // バー
                Capsule()
                    .fill(Color(hex: "2A3A50"))
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)
                    .padding(.bottom, 20)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        // ルーフェンの書きかけ
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 6) {
                                Image(systemName: "pencil.slash")
                                    .font(.system(size: 11))
                                    .foregroundStyle(prompt.accentColor.opacity(0.6))
                                Text("観測記録 — 中断")
                                    .font(.system(size: 10, weight: .light))
                                    .foregroundStyle(prompt.accentColor.opacity(0.6))
                                    .tracking(2)
                            }

                            Text(prompt.fragment)
                                .font(.system(size: 15, weight: .light, design: .serif))
                                .foregroundStyle(Color(hex: "A0B8D0"))
                                .lineSpacing(8)

                            // カーソル点滅（未完成の象徴）
                            BlinkingCursor(color: prompt.accentColor)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(hex: "0A0F1E"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 3)
                                        .stroke(prompt.accentColor.opacity(0.2), lineWidth: 0.5)
                                )
                        )

                        // ヒント
                        Text(prompt.hint)
                            .font(.system(size: 12, weight: .light))
                            .foregroundStyle(Color(hex: "3A5A7A"))
                            .padding(.horizontal, 4)

                        // ユーザー入力
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 11))
                                    .foregroundStyle(prompt.accentColor)
                                Text("あなたの観測記録")
                                    .font(.system(size: 10, weight: .light))
                                    .foregroundStyle(prompt.accentColor)
                                    .tracking(2)
                            }

                            ZStack(alignment: .topLeading) {
                                if text.isEmpty {
                                    Text("ここに続きを書く…")
                                        .font(.system(size: 15, weight: .light, design: .serif))
                                        .foregroundStyle(Color(hex: "2A3A50"))
                                        .padding(.top, 10)
                                        .padding(.leading, 4)
                                        .allowsHitTesting(false)
                                }
                                TextEditor(text: $text)
                                    .font(.system(size: 15, weight: .light, design: .serif))
                                    .foregroundStyle(Color(hex: "C8D8F0"))
                                    .scrollContentBackground(.hidden)
                                    .frame(minHeight: 160)
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color(hex: "0A0F1E"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 3)
                                            .stroke(prompt.accentColor.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.bottom, 40)
                }

                // 保存ボタン
                Button {
                    onSave(text)
                    withAnimation(.easeInOut(duration: 0.3)) { showCompletionFlash = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { dismiss() }
                } label: {
                    Text(text.trimmingCharacters(in: .whitespaces).isEmpty ? "後で書く" : "記録を完成させる")
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(Color(hex: "C8D8F0"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 2)
                                .fill(text.isEmpty
                                      ? Color.clear
                                      : prompt.accentColor.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2)
                                        .stroke(prompt.accentColor.opacity(text.isEmpty ? 0.2 : 0.7), lineWidth: 1)
                                )
                        )
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 32)
            }
            // 完了フラッシュ
            .overlay(
                Color(hex: "C8D8F0").opacity(showCompletionFlash ? 0.06 : 0)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .animation(.easeInOut(duration: 0.3), value: showCompletionFlash)
            )
        }
        .onAppear { text = existing?.responseText ?? "" }
    }
}

// MARK: - カーソル点滅

private struct BlinkingCursor: View {
    let color: Color
    @State private var visible = true

    var body: some View {
        Rectangle()
            .fill(color.opacity(0.8))
            .frame(width: 2, height: 16)
            .opacity(visible ? 1 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    visible = false
                }
            }
    }
}

#Preview {
    NavigationStack { UnfinishedLogView() }
        .modelContainer(for: LogResponse.self, inMemory: true)
}
