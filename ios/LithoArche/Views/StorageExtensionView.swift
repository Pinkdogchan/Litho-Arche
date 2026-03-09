import SwiftUI
import SwiftData

/// ワーク02: 保管期限延長の申請
/// 記憶を書いて「永久保管スタンプ」を押す封印儀式
struct StorageExtensionView: View {

    @Environment(\.modelContext) private var context
    @Query(sort: \SealedMemory.sealedAt, order: .reverse) private var memories: [SealedMemory]

    @State private var inputText    = ""
    @State private var phase: SealPhase = .write
    @State private var stampScale:  CGFloat = 0
    @State private var stampOpacity: Double = 0
    @State private var stampRotation: Double = -15
    @State private var newMemory:   SealedMemory? = nil

    enum SealPhase { case write, sealing, sealed }

    var body: some View {
        ZStack {
            Color(hex: "080A1A").ignoresSafeArea()
            Color(hex: "160A22").opacity(0.4).ignoresSafeArea()

            VStack(spacing: 0) {

                switch phase {
                case .write:
                    writePhase
                case .sealing, .sealed:
                    sealedPhase
                }

                // 過去の封印記憶
                if !memories.isEmpty && phase == .write {
                    sealedMemoryList
                }
            }
        }
        .navigationTitle("保管期限延長")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    // MARK: - Write Phase

    private var writePhase: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // 説明文（ルーフェンの口調）
                    VStack(alignment: .leading, spacing: 10) {
                        archiveLabel("FORM LA-7 / 保管期限延長申請")
                        Text("本来は廃棄されるはずのデータに対し、記録官の独断で保管期限の延長を申請する。申請が承認されると、このデータは永久保管フォルダに移送される。")
                            .font(.system(size: 13, weight: .light))
                            .foregroundStyle(Color(hex: "4A6A8A"))
                            .lineSpacing(6)
                    }
                    .padding(16)
                    .background(formBackground)

                    // 記憶入力
                    VStack(alignment: .leading, spacing: 10) {
                        archiveLabel("保管する記憶の内容")
                        ZStack(alignment: .topLeading) {
                            if inputText.isEmpty {
                                Text("忘れたくない記憶、忘れてはいけない感覚、消えかけている想い…")
                                    .font(.system(size: 15, weight: .light, design: .serif))
                                    .foregroundStyle(Color(hex: "2A3A50"))
                                    .padding(.top, 10)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                            }
                            TextEditor(text: $inputText)
                                .font(.system(size: 15, weight: .light, design: .serif))
                                .foregroundStyle(Color(hex: "C8D8F0"))
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 180)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(hex: "0A0D1E"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2)
                                        .stroke(Color(hex: "6A3A8A").opacity(0.3), lineWidth: 1)
                                )
                        )
                    }

                    // 封印ボタン
                    Button {
                        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        beginSealing()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "seal")
                                .font(.system(size: 16))
                            Text("記憶を永久封印する")
                                .font(.system(size: 14, weight: .light))
                        }
                        .foregroundStyle(
                            inputText.trimmingCharacters(in: .whitespaces).isEmpty
                                ? Color(hex: "2A3A50")
                                : Color(hex: "C8D8F0")
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(hex: "6A3A8A").opacity(
                                    inputText.isEmpty ? 0 : 0.2
                                ))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2)
                                        .stroke(
                                            Color(hex: "6A3A8A").opacity(inputText.isEmpty ? 0.15 : 0.7),
                                            lineWidth: 1
                                        )
                                )
                        )
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal, 22)
                .padding(.top, 28)
                .padding(.bottom, 32)
            }
        }
    }

    // MARK: - Sealed Phase

    private var sealedPhase: some View {
        VStack(spacing: 0) {
            Spacer()

            // 封印された記憶カード
            VStack(spacing: 20) {
                ZStack {
                    // 羊皮紙風カード
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "0E0A18"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(hex: "6A3A8A").opacity(0.5), lineWidth: 1)
                        )
                        .shadow(color: Color(hex: "6A3A8A").opacity(0.2), radius: 20)

                    VStack(spacing: 18) {
                        // アーカイブID
                        if let mem = newMemory {
                            Text(mem.archiveId)
                                .font(.system(size: 11, weight: .light, design: .monospaced))
                                .foregroundStyle(Color(hex: "6A3A8A").opacity(0.6))
                                .tracking(3)
                        }

                        // 記憶テキスト
                        Text(inputText)
                            .font(.system(size: 16, weight: .thin, design: .serif))
                            .foregroundStyle(Color(hex: "C8D8F0"))
                            .multilineTextAlignment(.center)
                            .lineSpacing(8)
                            .padding(.horizontal, 8)

                        // 封印日
                        if let mem = newMemory {
                            Text(mem.sealedAt.formatted(.dateTime.year().month().day()))
                                .font(.system(size: 10, weight: .light))
                                .foregroundStyle(Color(hex: "3A4A5A"))
                        }
                    }
                    .padding(28)

                    // スタンプ
                    SealStamp()
                        .scaleEffect(stampScale)
                        .opacity(stampOpacity)
                        .rotationEffect(.degrees(stampRotation))
                        .offset(x: 60, y: 50)
                }
                .frame(maxWidth: 340)
                .padding(.horizontal, 28)

                // メッセージ
                if phase == .sealed {
                    Text("この記憶は永久保管フォルダに移送されました。\nルーフェンが責任を持って守ります。")
                        .font(.system(size: 13, weight: .light))
                        .foregroundStyle(Color(hex: "4A6A8A"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .transition(.opacity)
                }
            }

            Spacer()

            // 新しい記憶を書くボタン
            if phase == .sealed {
                Button {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        inputText  = ""
                        newMemory  = nil
                        phase      = .write
                        stampScale = 0
                        stampOpacity = 0
                    }
                } label: {
                    Text("別の記憶を申請する")
                        .font(.system(size: 13, weight: .light))
                        .foregroundStyle(Color(hex: "7A8FAA"))
                        .padding(.bottom, 40)
                }
                .transition(.opacity)
            }
        }
    }

    // MARK: - Sealed Memory List

    private var sealedMemoryList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider().background(Color(hex: "1A2A3A")).padding(.horizontal, 22)

            archiveLabel("永久保管済みの記憶")
                .padding(.horizontal, 22)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(memories) { mem in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(mem.archiveId)
                                .font(.system(size: 9, weight: .light, design: .monospaced))
                                .foregroundStyle(Color(hex: "6A3A8A").opacity(0.6))
                                .tracking(2)
                            Text(mem.content)
                                .font(.system(size: 12, weight: .light, design: .serif))
                                .foregroundStyle(Color(hex: "A0B0C0"))
                                .lineSpacing(4)
                                .lineLimit(4)
                            Spacer()
                            Text(mem.sealedAt.formatted(.dateTime.month().day()))
                                .font(.system(size: 9, weight: .light))
                                .foregroundStyle(Color(hex: "2A3A4A"))
                        }
                        .padding(14)
                        .frame(width: 180, height: 140)
                        .background(
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(hex: "0E0A18"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 3)
                                        .stroke(Color(hex: "6A3A8A").opacity(0.2), lineWidth: 0.5)
                                )
                        )
                    }
                }
                .padding(.horizontal, 22)
            }
        }
        .padding(.bottom, 32)
    }

    // MARK: - Helpers

    private func archiveLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .light))
            .foregroundStyle(Color(hex: "6A3A8A").opacity(0.7))
            .tracking(2)
    }

    private var formBackground: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color(hex: "0A0810"))
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color(hex: "6A3A8A").opacity(0.15), lineWidth: 0.5)
            )
    }

    private func beginSealing() {
        let mem = SealedMemory(content: inputText.trimmingCharacters(in: .whitespaces))
        context.insert(mem)
        try? context.save()
        newMemory = mem

        withAnimation(.easeInOut(duration: 0.5)) { phase = .sealing }

        // スタンプアニメーション
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.55)) {
                stampScale    = 1.0
                stampOpacity  = 1.0
                stampRotation = -8
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeIn(duration: 0.4)) { phase = .sealed }
        }
    }
}

// MARK: - 封印スタンプ View

private struct SealStamp: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "6A3A8A").opacity(0.15))
                .frame(width: 90, height: 90)
            Circle()
                .stroke(Color(hex: "6A3A8A").opacity(0.6), lineWidth: 1.5)
                .frame(width: 90, height: 90)
            Circle()
                .stroke(Color(hex: "6A3A8A").opacity(0.3), lineWidth: 0.5)
                .frame(width: 78, height: 78)

            VStack(spacing: 2) {
                Text("SEALED")
                    .font(.system(size: 8, weight: .light, design: .monospaced))
                    .foregroundStyle(Color(hex: "6A3A8A"))
                    .tracking(2)
                Image(systemName: "seal.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color(hex: "6A3A8A").opacity(0.8))
                Text("永久保管")
                    .font(.system(size: 7, weight: .light))
                    .foregroundStyle(Color(hex: "6A3A8A"))
                    .tracking(1)
            }
        }
    }
}

#Preview {
    NavigationStack { StorageExtensionView() }
        .modelContainer(for: SealedMemory.self, inMemory: true)
}
