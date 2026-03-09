import Foundation
import SwiftData
import SwiftUI

// MARK: - 未完成ログ・プロンプト定義（ルーフェンの声）

struct ObservationPrompt: Identifiable {
    let id:          String
    let fragment:    String   // ルーフェンが書きかけた観測記録（ユーザーへの問い）
    let hint:        String   // 小さなヒント文
    let category:    String
    let accentColor: Color
}

extension ObservationPrompt {
    /// アプリに最初から収録されているプロンプト集
    static let seeds: [ObservationPrompt] = [
        ObservationPrompt(
            id: "dream_01",
            fragment: "子供のころ、なりたかったものがあった。それは今どこへ行ったのだろう。記録官として私はその答えを保存しなければならないが——観測対象は今、そのことを",
            hint: "続きを書いてください。あなたの言葉で観測ログを完成させる。",
            category: "子供のころの夢",
            accentColor: Color(hex: "6A3A8A")
        ),
        ObservationPrompt(
            id: "lonely_01",
            fragment: "まだ言葉にならない孤独という現象を観測した。それは形を持たず、音も出さず、ただそこにある。記録官として冷静に記述すべきだが、私には",
            hint: "その孤独に、あなたの言葉を添えてください。",
            category: "ことば",
            accentColor: Color(hex: "3A6B9E")
        ),
        ObservationPrompt(
            id: "small_happy_01",
            fragment: "今日、誰にも気づかれなかった小さな幸せが消えかけていた。慌てて保存を試みたが、その幸せは",
            hint: "あなたの小さな幸せを教えてください。",
            category: "小さな幸せ",
            accentColor: Color(hex: "8A6A2A")
        ),
        ObservationPrompt(
            id: "forgiven_01",
            fragment: "自分を責めている誰かの夢を観測した。記録を開始したが、私はどうしても観測を続けられなかった。なぜなら、その観測対象は",
            hint: "その人に、今のあなたなら何を伝えますか。",
            category: "感情ログ",
            accentColor: Color(hex: "7A3A5A")
        ),
        ObservationPrompt(
            id: "sound_01",
            fragment: "もう二度と聞けないかもしれない音がある。記録官として私は音をデータに変換するが、この音だけは変換したくない。それは",
            hint: "あなたの中に残っている音を書き留めてください。",
            category: "音",
            accentColor: Color(hex: "2A7A8A")
        ),
        ObservationPrompt(
            id: "scent_01",
            fragment: "匂いは記憶と直接接続する。ステラ・アーカイブのデータベースに照合できない匂いが一つだけある。それは",
            hint: "あなただけが知っている匂いを記録してください。",
            category: "匂い",
            accentColor: Color(hex: "3A6A4A")
        ),
    ]
}

// MARK: - SwiftData: 未完成ログへの回答

@Model
final class LogResponse {
    var promptId:    String
    var responseText: String
    var completedAt: Date
    var isSaved:     Bool

    init(promptId: String, responseText: String = "") {
        self.promptId     = promptId
        self.responseText = responseText
        self.completedAt  = .now
        self.isSaved      = false
    }
}

// MARK: - SwiftData: 保管期限延長された記憶

@Model
final class SealedMemory {
    var content:   String    // ユーザーが書いた記憶
    var sealedAt:  Date
    var archiveId: String    // 発行されたアーカイブID（ランダム）

    init(content: String) {
        self.content   = content
        self.sealedAt  = .now
        self.archiveId = Self.generateId()
    }

    private static func generateId() -> String {
        let letters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return "LA-" + String((0..<6).map { _ in letters.randomElement()! })
    }
}
