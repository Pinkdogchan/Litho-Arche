import SwiftUI
import SwiftData

/// 初回起動: ユーザーが「魔法の言葉」を設定するビュー
struct MagicWordSetupView: View {
    @Environment(\.modelContext) private var context

    @State private var magicWord      = ""
    @State private var sanctuaryName  = ""
    @State private var step: SetupStep = .intro
    @State private var contentOpacity: Double = 0

    enum SetupStep { case intro, inputWord, inputName, complete }

    var body: some View {
        ZStack {
            Color(hex: "080A1A").ignoresSafeArea()

            // 背景の霧（薄く常駐）
            Ellipse()
                .fill(Color(hex: "0F1530"))
                .frame(width: 600, height: 280)
                .blur(radius: 80)
                .offset(y: 100)
                .opacity(0.6)

            VStack(spacing: 0) {
                Spacer()
                stepContent
                    .opacity(contentOpacity)
                    .animation(.easeInOut(duration: 0.6), value: step)
                Spacer()
            }
            .padding(.horizontal, 48)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 1.2)) { contentOpacity = 1 }
        }
    }

    // MARK: - Step Contents

    @ViewBuilder
    private var stepContent: some View {
        switch step {

        case .intro:
            VStack(spacing: 32) {
                ornament
                Text("ようこそ、\n内的聖域へ")
                    .font(.system(size: 28, weight: .thin, design: .serif))
                    .foregroundStyle(Color(hex: "C8D8F0"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)

                Text("あなただけのアーカイブを始める前に\nひとつだけ聞かせてください")
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(Color(hex: "7A8FAA"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)

                ArchButton(title: "続ける") {
                    transition(to: .inputWord)
                }
            }

        case .inputWord:
            VStack(spacing: 32) {
                ornament
                Text("あなたの\n魔法の言葉は？")
                    .font(.system(size: 26, weight: .thin, design: .serif))
                    .foregroundStyle(Color(hex: "C8D8F0"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)

                Text("自分を守り、前へ進むための\nたったひとつの言葉")
                    .font(.system(size: 13, weight: .light))
                    .foregroundStyle(Color(hex: "7A8FAA"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)

                StoneTextField(placeholder: "例: しずか、星、courage …", text: $magicWord)

                ArchButton(title: "刻む", isDisabled: magicWord.trimmingCharacters(in: .whitespaces).isEmpty) {
                    transition(to: .inputName)
                }
            }

        case .inputName:
            VStack(spacing: 32) {
                ornament
                Text("この聖域に\n名前をつけますか？")
                    .font(.system(size: 26, weight: .thin, design: .serif))
                    .foregroundStyle(Color(hex: "C8D8F0"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)

                Text("空欄でも構いません\nいつでも変えられます")
                    .font(.system(size: 13, weight: .light))
                    .foregroundStyle(Color(hex: "7A8FAA"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)

                StoneTextField(placeholder: "聖域の名前（任意）", text: $sanctuaryName)

                ArchButton(title: "扉を開く") {
                    saveAndFinish()
                }
            }

        case .complete:
            VStack(spacing: 24) {
                Text("✦")
                    .font(.system(size: 40))
                    .foregroundStyle(Color(hex: "3A6B9E"))

                Text("「\(magicWord)」")
                    .font(.system(size: 32, weight: .thin, design: .serif))
                    .foregroundStyle(Color(hex: "C8D8F0"))

                Text("石に刻まれました")
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(Color(hex: "7A8FAA"))
            }
        }
    }

    // MARK: - Actions

    private func transition(to next: SetupStep) {
        withAnimation(.easeInOut(duration: 0.4)) { contentOpacity = 0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            step = next
            withAnimation(.easeInOut(duration: 0.5)) { contentOpacity = 1 }
        }
    }

    private func saveAndFinish() {
        let profile = UserProfile(
            magicWord:     magicWord.trimmingCharacters(in: .whitespaces),
            sanctuaryName: sanctuaryName.trimmingCharacters(in: .whitespaces)
        )
        context.insert(profile)

        transition(to: .complete)
    }

    // MARK: - Ornament

    private var ornament: some View {
        HStack(spacing: 16) {
            line
            Image(systemName: "diamond.fill")
                .font(.system(size: 8))
                .foregroundStyle(Color(hex: "3A6B9E"))
            line
        }
    }

    private var line: some View {
        Rectangle()
            .fill(Color(hex: "2A3A50"))
            .frame(width: 60, height: 0.5)
    }
}

// MARK: - 共通UIコンポーネント

/// 石造りテイストのテキストフィールド
private struct StoneTextField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField("", text: $text, prompt:
            Text(placeholder).foregroundColor(Color(hex: "3A4A5A"))
        )
        .font(.system(size: 18, weight: .light, design: .serif))
        .foregroundStyle(Color(hex: "C8D8F0"))
        .multilineTextAlignment(.center)
        .padding(.vertical, 14)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: "0F1428"))
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color(hex: "2A3A50"), lineWidth: 1)
                )
        )
        .autocorrectionDisabled()
    }
}

/// アーチ型ボタン
private struct ArchButton: View {
    let title: String
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .light, design: .serif))
                .foregroundStyle(isDisabled ? Color(hex: "2A3A50") : Color(hex: "C8D8F0"))
                .frame(width: 160, height: 44)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(isDisabled ? Color(hex: "2A3A50") : Color(hex: "3A6B9E"), lineWidth: 1)
                )
        }
        .disabled(isDisabled)
    }
}

#Preview {
    MagicWordSetupView()
        .modelContainer(for: UserProfile.self, inMemory: true)
}
