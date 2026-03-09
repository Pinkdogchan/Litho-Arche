import SwiftUI
import SwiftData

/// Chapter 3 ― 生き抜いてきた君へ
/// 「〜しなければ価値がない」パターン検知時に自動提示されるワーク
struct Chapter3View: View {

    @Environment(\.modelContext) private var context
    @Query private var responses: [LogResponse]
    @State private var selectedPrompt: Chapter3Prompt? = nil

    // Chapter 3 専用プロンプト
    private let prompts: [Chapter3Prompt] = [
        Chapter3Prompt(
            id: "c3_01",
            fragment: "「今日、生き抜いた」という事実だけで、あなたはすでに何かを成し遂げている。記録官として私はそれを観測してきた。今日、あなたが乗り越えたことは",
            hint: "どんなに小さなことでも構いません。"
        ),
        Chapter3Prompt(
            id: "c3_02",
            fragment: "価値というものは、何かを「する」ことで生まれるのではなく、すでに「在る」ことに宿っている——これは記録官としての観測ではなく、私個人の見解だ。それでも、あなたが今ここにいることに意味があると感じる瞬間があるとしたら、それは",
            hint: "思い浮かばなくても大丈夫です。「わからない」も立派な答えです。"
        ),
        Chapter3Prompt(
            id: "c3_03",
            fragment: "あなたが自分に課しているルールを一つ、ここに書いてください。次に、そのルールを「誰かの大切な友人」に適用したとしたら——あなたはその友人に何と言うでしょうか。私はそれを記録したい。ルール：",
            hint: "ルーフェンはあなたの言葉を批判しません。"
        ),
        Chapter3Prompt(
            id: "c3_04",
            fragment: "過去に「これは無理だ」と思ったのに、乗り越えた出来事がある。小さくてもいい。記録官として私はあなたの強さの目録を作りたい。一つ教えてほしい：",
            hint: "「乗り越えた」は大げさじゃなくていい。「なんとかなった」で十分です。"
        ),
        Chapter3Prompt(
            id: "c3_05",
            fragment: "もし今のあなたに、10年前の自分から手紙が届いたとしたら、10年前のあなたはきっとこう言う：",
            hint: "過去の自分の声を想像してみてください。"
        ),
    ]

    var body: some View {
        ZStack {
            Color(hex: "080A1A").ignoresSafeArea()
            Color(hex: "1A0A12").opacity(0.3).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // ── ヘッダー ──────────────────────────
                    chapterHeader

                    // ── ワーク一覧 ─────────────────────
                    VStack(spacing: 14) {
                        ForEach(prompts) { prompt in
                            let resp = responses.first(where: { $0.promptId == prompt.id })
                            Chapter3Card(prompt: prompt, response: resp) {
                                selectedPrompt = prompt
                            }
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.bottom, 60)
                }
            }
        }
        .navigationTitle("Chapter 3")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(item: $selectedPrompt) { prompt in
            LogEditorSheet(
                promptId:   prompt.id,
                fragment:   prompt.fragment,
                hint:       prompt.hint,
                accentColor: Color(hex: "7A3A5A"),
                existing:   responses.first(where: { $0.promptId == prompt.id })
            ) { text in
                saveResponse(promptId: prompt.id, text: text)
            }
        }
    }

    // MARK: - Header

    private var chapterHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "heart.text.square")
                    .font(.system(size: 13))
                    .foregroundStyle(Color(hex: "7A3A5A"))
                Text("CHAPTER 3 / OBSERVATION LOG")
                    .font(.system(size: 10, weight: .light))
                    .foregroundStyle(Color(hex: "7A3A5A").opacity(0.7))
                    .tracking(2)
            }

            Text("生き抜いてきた\n君へ")
                .font(.system(size: 28, weight: .thin, design: .serif))
                .foregroundStyle(Color(hex: "C8D8F0"))
                .lineSpacing(8)

            Text("これは命令でも、励ましでもありません。\nあなたがこれまで生き抜いてきたという事実を、\n記録として残すための場所です。")
                .font(.system(size: 13, weight: .light))
                .foregroundStyle(Color(hex: "4A5A6A"))
                .lineSpacing(7)

            // 進捗
            let done = prompts.filter { p in responses.first(where: { $0.promptId == p.id })?.isSaved == true }.count
            progressBar(done: done, total: prompts.count)
        }
        .padding(.horizontal, 22)
        .padding(.top, 24)
        .padding(.bottom, 32)
    }

    private func progressBar(done: Int, total: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(done) / \(total) 記録完了")
                .font(.system(size: 10, weight: .light))
                .foregroundStyle(Color(hex: "3A4A5A"))
                .tracking(1)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 1).fill(Color(hex: "1A2A3A")).frame(height: 2)
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color(hex: "7A3A5A"))
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

// MARK: - Chapter3 専用プロンプト型

struct Chapter3Prompt: Identifiable {
    let id:       String
    let fragment: String
    let hint:     String
}

// MARK: - Chapter3 カード

private struct Chapter3Card: View {
    let prompt:   Chapter3Prompt
    let response: LogResponse?
    let onTap:    () -> Void

    var isCompleted: Bool { response?.isSaved == true }
    private let accent = Color(hex: "7A3A5A")

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    if isCompleted {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill").font(.system(size: 11))
                            Text("記録完了")
                                .font(.system(size: 10, weight: .light))
                        }
                        .foregroundStyle(accent.opacity(0.8))
                    } else {
                        Text("未記録")
                            .font(.system(size: 10, weight: .light))
                            .foregroundStyle(Color(hex: "3A4A5A"))
                    }
                    Spacer()
                }

                Text(prompt.fragment + "……")
                    .font(.system(size: 14, weight: .light, design: .serif))
                    .foregroundStyle(Color(hex: "A0B0C0"))
                    .lineSpacing(6)
                    .lineLimit(3)

                if isCompleted, let text = response?.responseText, !text.isEmpty {
                    Divider().background(accent.opacity(0.2))
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
                    .fill(Color(hex: "0A0810"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(isCompleted ? accent.opacity(0.35) : Color(hex: "1A2A3A"), lineWidth: 0.5)
                    )
            )
            .overlay(alignment: .leading) {
                if isCompleted {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(accent)
                        .frame(width: 2)
                        .padding(.vertical, 12)
                }
            }
        }
    }
}

// MARK: - 汎用ログ編集シート（Chapter3 / UnfinishedLog 共用）

struct LogEditorSheet: View {
    let promptId:    String
    let fragment:    String
    let hint:        String
    let accentColor: Color
    let existing:    LogResponse?
    let onSave:      (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var text = ""

    var body: some View {
        ZStack {
            Color(hex: "080A1A").ignoresSafeArea()

            VStack(spacing: 0) {
                Capsule()
                    .fill(Color(hex: "2A3A50"))
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)
                    .padding(.bottom, 20)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // ルーフェンの書きかけ
                        Text(fragment)
                            .font(.system(size: 15, weight: .light, design: .serif))
                            .foregroundStyle(Color(hex: "A0B8D0"))
                            .lineSpacing(8)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color(hex: "0A0F1E"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 3)
                                            .stroke(accentColor.opacity(0.2), lineWidth: 0.5)
                                    )
                            )

                        Text(hint)
                            .font(.system(size: 12, weight: .light))
                            .foregroundStyle(Color(hex: "3A5A7A"))
                            .padding(.horizontal, 4)

                        ZStack(alignment: .topLeading) {
                            if text.isEmpty {
                                Text("ここに書く…")
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
                                        .stroke(accentColor.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.horizontal, 22)
                    .padding(.bottom, 40)
                }

                Button {
                    onSave(text)
                    dismiss()
                } label: {
                    Text(text.trimmingCharacters(in: .whitespaces).isEmpty ? "後で書く" : "記録を残す")
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(Color(hex: "C8D8F0"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 2)
                                .fill(text.isEmpty ? Color.clear : accentColor.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2)
                                        .stroke(accentColor.opacity(text.isEmpty ? 0.2 : 0.7), lineWidth: 1)
                                )
                        )
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 32)
            }
        }
        .onAppear { text = existing?.responseText ?? "" }
    }
}

#Preview {
    NavigationStack { Chapter3View() }
        .modelContainer(for: LogResponse.self, inMemory: true)
}
