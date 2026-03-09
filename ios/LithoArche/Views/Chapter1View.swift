import SwiftUI
import SwiftData

/// Chapter 1: 記録官との出会い（オンボーディング）
/// 初回ユーザーが聖域の意味を理解し、最初の記録を残すための旅の章
struct Chapter1View: View {

    @Bindable var profile: UserProfile
    @Environment(\.modelContext) private var context
    var onComplete: () -> Void   // 完了 → Screen 3 聖域の広間へ

    @State private var step: Int = 0
    @State private var contentOpacity: Double = 0

    // オンボーディングのステップ定義
    private let steps: [(icon: String, color: String, title: String, body: String)] = [
        (
            icon:  "archivebox",
            color: "3A6B9E",
            title: "ステラ・アーカイブへようこそ",
            body:  "ここは、言葉にならなかった想いを記録する場所です。\n\n記録されなければ「無かったこと」になる——\nそれを防ぐために、私はここにいます。"
        ),
        (
            icon:  "sparkles",
            color: "6A3A8A",
            title: "感覚のアーカイブ",
            body:  "音、匂い、小さな幸せ、子供のころの夢。\n\nカテゴリーに分けて記録することで、\nあなたの内側の地図が少しずつ形になります。"
        ),
        (
            icon:  "pencil.tip",
            color: "8A6A2A",
            title: "魂の器・ワークショップ",
            body:  "ガイドラインの上に、あなた自身の形を描き込む場所。\n\n正解はありません。\nあなたの手の動きが、あなたの記録になります。"
        ),
        (
            icon:  "heart.text.square",
            color: "7A3A5A",
            title: "ルーフェンのことば",
            body:  "悩みや想いを話すと、ルーフェンがあなたの記録の中から\nことばを選んで返します。\n\n記録官は、ただ聴きます。"
        ),
    ]

    var body: some View {
        ZStack {
            Color(hex: "07091A").ignoresSafeArea()

            // 背景グロー
            Circle()
                .fill(Color(hex: steps[step].color).opacity(0.06))
                .frame(width: 500, height: 500)
                .blur(radius: 80)
                .allowsHitTesting(false)

            VStack(spacing: 0) {

                // プログレスドット
                progressDots
                    .padding(.top, 60)

                Spacer()

                // ステップコンテンツ
                stepContent
                    .opacity(contentOpacity)
                    .padding(.horizontal, 40)

                Spacer()

                // ナビゲーションボタン
                navigationButton
                    .padding(.bottom, 56)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.6)) { contentOpacity = 1 }
        }
    }

    // MARK: - Progress Dots

    private var progressDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<steps.count, id: \.self) { i in
                Capsule()
                    .fill(i == step
                          ? Color(hex: steps[step].color)
                          : Color(hex: "1A2A3A"))
                    .frame(width: i == step ? 20 : 6, height: 6)
                    .animation(.spring(duration: 0.3), value: step)
            }
        }
    }

    // MARK: - Step Content

    private var stepContent: some View {
        VStack(spacing: 28) {
            // アイコン
            ZStack {
                Circle()
                    .fill(Color(hex: steps[step].color).opacity(0.12))
                    .frame(width: 88, height: 88)
                Image(systemName: steps[step].icon)
                    .font(.system(size: 36))
                    .foregroundStyle(Color(hex: steps[step].color))
            }

            // タイトル
            Text(steps[step].title)
                .font(.system(size: 22, weight: .thin, design: .serif))
                .foregroundStyle(Color(hex: "C8D8F0"))
                .multilineTextAlignment(.center)

            // 本文
            Text(steps[step].body)
                .font(.system(size: 15, weight: .light))
                .foregroundStyle(Color(hex: "6A8AAA"))
                .multilineTextAlignment(.center)
                .lineSpacing(8)
        }
    }

    // MARK: - Navigation Button

    private var navigationButton: some View {
        Button(action: handleNext) {
            HStack(spacing: 10) {
                Text(step < steps.count - 1 ? "次へ" : "聖域へ入る")
                    .font(.system(size: 15, weight: .light, design: .serif))
                    .foregroundStyle(Color(hex: "C8D8F0"))

                Image(systemName: step < steps.count - 1 ? "arrow.right" : "sparkles")
                    .font(.system(size: 13))
                    .foregroundStyle(Color(hex: steps[step].color))
            }
            .frame(width: 200, height: 50)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color(hex: steps[step].color).opacity(0.6), lineWidth: 1)
            )
        }
    }

    // MARK: - Actions

    private func handleNext() {
        if step < steps.count - 1 {
            transition(to: step + 1)
        } else {
            // オンボーディング完了を記録
            profile.hasCompletedOnboarding = true
            try? context.save()
            onComplete()
        }
    }

    private func transition(to next: Int) {
        withAnimation(.easeOut(duration: 0.3)) { contentOpacity = 0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            step = next
            withAnimation(.easeIn(duration: 0.4)) { contentOpacity = 1 }
        }
    }
}

#Preview {
    Chapter1View(
        profile: UserProfile(magicWord: "しずか"),
        onComplete: {}
    )
    .modelContainer(for: UserProfile.self, inMemory: true)
}
