import Foundation
import SwiftData

/// 断片の収集ワークで記録されたひとつのセッション
@Model
final class FragmentEntry {
    var sessionId:    String    // 同じ問答セッションをグループ化
    var promptText:   String    // ルーフェンの問い
    var responseText: String    // ユーザーの回答
    var turnIndex:    Int       // 何問目か（0始まり）
    var isArchived:   Bool      // 浄化・封印済みか
    var archivedAt:   Date?
    var createdAt:    Date

    init(sessionId: String, promptText: String, turnIndex: Int) {
        self.sessionId    = sessionId
        self.promptText   = promptText
        self.responseText = ""
        self.turnIndex    = turnIndex
        self.isArchived   = false
        self.createdAt    = .now
    }
}
