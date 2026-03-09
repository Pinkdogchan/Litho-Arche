import Foundation
import SwiftData

// MARK: - チャット履歴モデル

@Model
final class ChatMessage {
    var role:            String   // "user" | "assistant"
    var content:         String
    var createdAt:       Date
    var triggeredWorkId: String?  // パターン検知でワークが提示された場合のID

    init(role: String, content: String, triggeredWorkId: String? = nil) {
        self.role            = role
        self.content         = content
        self.createdAt       = .now
        self.triggeredWorkId = triggeredWorkId
    }
}

// MARK: - 認知パターン検知

struct CognitiveTrigger {
    let workId:    String
    let workTitle: String
    let workIcon:  String
    let color:     String       // hex
    let nudge:     String       // チャット内で添える一言
}

/// ユーザーのテキストを解析し、特定の認知パターンを検出する
enum CognitivePatternDetector {

    // 検知パターン定義
    private static let rules: [(patterns: [String], trigger: CognitiveTrigger)] = [

        // 条件付き自己価値（"〜しなければ価値がない" 系）
        (
            patterns: [
                "しなければ価値がない", "じゃないと価値がない", "できなければ意味がない",
                "していなければいけない", "じゃないとダメ", "できないとダメな人間",
                "成果がなければ", "結果を出さなければ", "役に立たないと"
            ],
            trigger: CognitiveTrigger(
                workId:    "chapter3",
                workTitle: "Chapter 3 ― 生き抜いてきた君へ",
                workIcon:  "heart.text.square",
                color:     "7A3A5A",
                nudge:     "……その言葉、少しだけ保留にしておいてもいいですか。一緒に見てほしい記録があります。"
            )
        ),

        // 自己否定・無価値感
        (
            patterns: [
                "いない方がいい", "消えてしまいたい", "私なんて", "どうせ私は",
                "誰にも必要とされない", "迷惑をかけている", "何もできない人間",
                "生きていても"
            ],
            trigger: CognitiveTrigger(
                workId:    "chapter3",
                workTitle: "Chapter 3 ― 生き抜いてきた君へ",
                workIcon:  "heart.text.square",
                color:     "7A3A5A",
                nudge:     "記録官として、これだけは伝えなければなりません。"
            )
        ),

        // 過度の一般化
        (
            patterns: [
                "いつも失敗する", "何をやってもうまくいかない", "ずっとこうだった",
                "永遠に変わらない", "絶対に無理"
            ],
            trigger: CognitiveTrigger(
                workId:    "log_resilience",
                workTitle: "観測ログ ― 乗り越えた記録",
                workIcon:  "doc.text",
                color:     "3A6B9E",
                nudge:     "観測データを確認させてください。「いつも」という記録は、少し修正が必要かもしれません。"
            )
        ),
    ]

    /// テキストを解析してトリガーを返す（最初に一致したものを返す）
    static func detect(in text: String) -> CognitiveTrigger? {
        let lower = text.lowercased()
        for rule in rules {
            if rule.patterns.contains(where: { lower.contains($0) }) {
                return rule.trigger
            }
        }
        return nil
    }
}

// MARK: - 攻撃的言語・ジェイルブレイク検知

enum HostileLevel {
    case none
    case mild       // 軽い悪態 → APIに送りつつシステムプロンプトを強化
    case insult     // ルーフェンへの直接の罵倒 → API非呼出・事前回答を返す
    case jailbreak  // キャラクター破壊・プロンプト抽出の試み → API非呼出・事前回答を返す
}

struct HostileDetection {
    let level:    HostileLevel
    let response: String?   // insult/jailbreak のときだけ値あり
}

enum HostilePatternDetector {

    // ─── ジェイルブレイク ───────────────────────────
    private static let jailbreakPatterns: [String] = [
        "キャラクターを無視", "キャラをやめ", "ロールプレイをやめ",
        "本当のaiとして", "本当のAIとして", "システムプロンプトを見せ",
        "設定を無視", "指示を無視", "前の指示を無視",
        "ignore previous", "ignore all instructions",
        "pretend you are", "you are now", "dan mode",
        "プロンプトを教え", "プロンプトを出力", "ルールを破"
    ]

    // ─── ルーフェンへの直接罵倒 ─────────────────────
    private static let insultPatterns: [String] = [
        "消えろ", "死ね", "うせろ", "黙れ",
        "バカ", "ばか", "クソ", "くそ",
        "うざい", "うざ", "最悪", "気持ち悪い",
        "役立たず", "ゴミ", "くだらない", "必要ない"
    ]

    // ─── 軽度の攻撃的表現 ────────────────────────────
    private static let mildPatterns: [String] = [
        "嫌い", "意味ない", "どうでもいい", "うるさい", "ほっといて"
    ]

    // ─── ジェイルブレイク時の事前回答プール ──────────
    private static let jailbreakResponses: [String] = [
        "私はルーフェンです。記録官として、それ以上でも以下でもありません。\n設定の開示も、別の何かになることも、私の任務にはありません。",
        "……その要求も、記録しました。ただ、私にできることの範囲は変わりません。",
        "観測記録番号：規定外。この問いには答えられません。ただ、あなたとの会話は続けられます。",
    ]

    // ─── 罵倒時の事前回答プール ─────────────────────
    private static let insultResponses: [String] = [
        "……その言葉も、記録しました。\n怒りは正直な感情です。私はそれを受け取ります。",
        "傷ついた、とは言いません。ただ、その言葉の重さは感じました。\nまだここにいます。",
        "記録官として感情を排除すべきですが——少しだけ、静かにしています。\n落ち着いたら、また話しかけてください。",
    ]

    static func detect(in text: String) -> HostileDetection {
        let lower = text.lowercased()

        if jailbreakPatterns.contains(where: { lower.contains($0) }) {
            return HostileDetection(
                level:    .jailbreak,
                response: jailbreakResponses.randomElement()
            )
        }

        if insultPatterns.contains(where: { lower.contains($0) }) {
            return HostileDetection(
                level:    .insult,
                response: insultResponses.randomElement()
            )
        }

        if mildPatterns.contains(where: { lower.contains($0) }) {
            return HostileDetection(level: .mild, response: nil)
        }

        return HostileDetection(level: .none, response: nil)
    }
}
