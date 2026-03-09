import Foundation
import SwiftData

/// ユーザーの内的聖域プロファイル
@Model
final class UserProfile {
    var magicWord:              String
    var sanctuaryName:          String
    var createdAt:              Date
    /// Chapter 1 を完了し、聖域の広間に入ったことがあるか
    var hasCompletedOnboarding: Bool

    init(magicWord: String, sanctuaryName: String = "") {
        self.magicWord              = magicWord
        self.sanctuaryName          = sanctuaryName
        self.createdAt              = .now
        self.hasCompletedOnboarding = false
    }
}
