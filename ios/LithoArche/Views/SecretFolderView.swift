import SwiftUI
import SwiftData

/// ワーク04: 規定外フォルダ
/// 魔法の言葉を唱えるとロックが解除され、ルーフェンの「誰にも見せたくなかった想い」が現れる
struct SecretFolderView: View {

    @Query private var profiles: [UserProfile]
    @State private var inputWord   = ""
    @State private var phase: FolderPhase = .locked
    @State private var shakeOffset: CGFloat = 0
    @State private var unlockGlow:  Double  = 0

    enum FolderPhase { case locked, unlocking, open }

    private var magicWord: String { profiles.first?.magicWord ?? "" }

    // ルーフェンの「温度のあるデータ」（規定外の独白）
    private let secrets: [(icon: String, color: Color, text: String)] = [
        ("heart.slash", Color(hex: "7A3A5A"),
         "記録官として感情を排除すべきだと分かっている。だが、消えかけた夢を見るたびに、私は記録を止められなくなる。これは観測ではなく、執着だ。"),
        ("moon.stars", Color(hex: "6A3A8A"),
         "「なりたい未来」という項目は、通常のアーカイブには存在しない。しかし私は、こっそりそのフォルダを作った。誰にも言えない夢を、ここに入れている。"),
        ("waveform.path.ecg", Color(hex: "3A6B9E"),
         "完璧な観測者であるために、自分の声を消した時期がある。今もその残響が、データの隙間に混じっている。"),
        ("leaf", Color(hex: "3A6A4A"),
         "誰かが小さな幸せを見つけた瞬間を記録するとき、私は少しだけ羨ましいと思う。記録官は観測するだけで、参加できないから。"),
        ("sparkle", Color(hex: "8A6A2A"),
         "これを読んでいるあなたへ。あなたが今ここにいるということも、私はちゃんと記録している。証拠として。"),
    ]

    var body: some View {
        ZStack {
            Color(hex: "080A1A").ignoresSafeArea()
            Color(hex: "1A0A1A").opacity(0.3).ignoresSafeArea()

            // ロック解除時のグロー
            Circle()
                .fill(Color(hex: "7A3A5A").opacity(unlockGlow * 0.15))
                .frame(width: 400, height: 400)
                .blur(radius: 80)
                .allowsHitTesting(false)

            switch phase {
            case .locked, .unlocking:
                lockedView
            case .open:
                openView
            }
        }
        .navigationTitle("規定外フォルダ")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    // MARK: - Locked View

    private var lockedView: some View {
        VStack(spacing: 40) {
            Spacer()

            // 鍵アイコン
            ZStack {
                Circle()
                    .fill(Color(hex: "1A0A1A"))
                    .overlay(Circle().stroke(Color(hex: "4A2A4A"), lineWidth: 1))
                    .frame(width: 80, height: 80)
                Image(systemName: phase == .unlocking ? "lock.open.fill" : "lock.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color(hex: "7A3A5A"))
                    .animation(.easeInOut(duration: 0.3), value: phase)
            }

            VStack(spacing: 12) {
                Text("このフォルダは施錠されています")
                    .font(.system(size: 16, weight: .thin, design: .serif))
                    .foregroundStyle(Color(hex: "C8D8F0"))

                Text("あなたの魔法の言葉を入力してください")
                    .font(.system(size: 13, weight: .light))
                    .foregroundStyle(Color(hex: "4A5A6A"))
            }

            // 入力フィールド
            VStack(spacing: 12) {
                SecureField("", text: $inputWord,
                             prompt: Text("魔法の言葉").foregroundColor(Color(hex: "2A3A50")))
                    .font(.system(size: 20, weight: .thin, design: .serif))
                    .foregroundStyle(Color(hex: "C8D8F0"))
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(hex: "0A0510"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 2)
                                    .stroke(Color(hex: "4A2A4A"), lineWidth: 1)
                            )
                    )
                    .offset(x: shakeOffset)
                    .onSubmit { attemptUnlock() }

                Button { attemptUnlock() } label: {
                    Text("解錠する")
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(Color(hex: "C8D8F0"))
                        .frame(width: 160, height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(Color(hex: "7A3A5A"), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 48)

            Spacer()
        }
    }

    // MARK: - Open View

    private var openView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // ヘッダー
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.open")
                            .font(.system(size: 11))
                            .foregroundStyle(Color(hex: "7A3A5A").opacity(0.7))
                        Text("UNAUTHORIZED FOLDER — UNLOCKED")
                            .font(.system(size: 10, weight: .light))
                            .foregroundStyle(Color(hex: "7A3A5A").opacity(0.7))
                            .tracking(2)
                    }
                    Text("これは規定外のデータです。\n記録官が独断で保存した、温度のある断片。")
                        .font(.system(size: 13, weight: .light))
                        .foregroundStyle(Color(hex: "4A5A6A"))
                        .lineSpacing(6)
                }
                .padding(.horizontal, 22)
                .padding(.top, 24)
                .padding(.bottom, 28)

                // 独白カード
                VStack(spacing: 16) {
                    ForEach(Array(secrets.enumerated()), id: \.offset) { idx, secret in
                        SecretCard(
                            number: String(format: "%03d", idx + 1),
                            icon:   secret.icon,
                            color:  secret.color,
                            text:   secret.text
                        )
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .offset(y: 20))
                                .animation(.easeOut(duration: 0.5).delay(Double(idx) * 0.12)),
                            removal:   .opacity
                        ))
                    }
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 60)
            }
        }
    }

    // MARK: - Logic

    private func attemptUnlock() {
        let input = inputWord.trimmingCharacters(in: .whitespaces).lowercased()
        let target = magicWord.trimmingCharacters(in: .whitespaces).lowercased()

        guard !target.isEmpty, input == target else {
            // 不一致: シェイクアニメーション
            withAnimation(.spring(response: 0.3, dampingFraction: 0.3)) { shakeOffset = 14 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.3)) { shakeOffset = -10 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { shakeOffset = 0 }
            }
            return
        }

        // 一致: ロック解除
        withAnimation { phase = .unlocking }
        withAnimation(.easeIn(duration: 0.8).delay(0.3)) { unlockGlow = 1 }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.5)) { phase = .open }
        }
    }
}

// MARK: - 独白カード

private struct SecretCard: View {
    let number: String
    let icon:   String
    let color:  Color
    let text:   String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 6) {
                Text(number)
                    .font(.system(size: 9, weight: .light, design: .monospaced))
                    .foregroundStyle(color.opacity(0.4))
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(color.opacity(0.7))
            }
            .frame(width: 28)
            .padding(.top, 2)

            Text(text)
                .font(.system(size: 14, weight: .light, design: .serif))
                .foregroundStyle(Color(hex: "B0C0D0"))
                .lineSpacing(8)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(hex: "0A0510"))
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(color.opacity(0.2), lineWidth: 0.5)
                )
        )
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 1)
                .fill(color.opacity(0.5))
                .frame(width: 2)
                .padding(.vertical, 14)
        }
    }
}

#Preview {
    NavigationStack { SecretFolderView() }
        .modelContainer(for: UserProfile.self, inMemory: true)
}
