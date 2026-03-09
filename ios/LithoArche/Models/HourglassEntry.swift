import Foundation
import SwiftData

// MARK: - 自己問診エントリ（一日一回）

@Model
final class HourglassEntry {

    /// その日の日付（0時0分に正規化して保存）
    var date:            Date
    var sleepScore:      Int       // 睡眠  1-5
    var energyScore:     Int       // 活力  1-5
    var moodScore:       Int       // 心    1-5
    var connectionScore: Int       // つながり 1-5
    var creativityScore: Int       // 創造力 1-5
    /// 完了済み習慣名リスト（JSON文字列で保存）
    var habitsRaw:       String    // ["水を飲む","深呼吸 10回"]
    var note:            String

    init(date: Date = .now) {
        self.date            = Calendar.current.startOfDay(for: date)
        self.sleepScore      = 0
        self.energyScore     = 0
        self.moodScore       = 0
        self.connectionScore = 0
        self.creativityScore = 0
        self.habitsRaw       = "[]"
        self.note            = ""
    }

    // MARK: 平均スコア（0.0 〜 1.0）
    var averageScore: Double {
        let nonZero = [sleepScore, energyScore, moodScore, connectionScore, creativityScore]
            .filter { $0 > 0 }
        guard !nonZero.isEmpty else { return 0 }
        return Double(nonZero.reduce(0, +)) / Double(nonZero.count * 5)
    }

    // MARK: 完了済み習慣 (computed)
    var completedHabits: [String] {
        get {
            (try? JSONDecoder().decode([String].self,
                from: Data(habitsRaw.utf8))) ?? []
        }
        set {
            habitsRaw = (try? String(data: JSONEncoder().encode(newValue),
                encoding: .utf8)) ?? "[]"
        }
    }

    static func dayKey(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }
}
