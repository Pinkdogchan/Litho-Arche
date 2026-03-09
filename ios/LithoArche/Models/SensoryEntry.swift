import Foundation
import SwiftData
import SwiftUI

// MARK: - カテゴリー定義

enum SensoryCategory: String, CaseIterable, Codable, Identifiable {
    case sound      = "sound"
    case taste      = "taste"
    case scent      = "scent"
    case texture    = "texture"
    case happiness  = "happiness"
    case dream      = "dream"
    case scenery    = "scenery"
    case words      = "words"
    case place      = "place"
    case time       = "time"
    case warmth     = "warmth"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .sound:     return "音"
        case .taste:     return "味わい"
        case .scent:     return "匂い"
        case .texture:   return "触感"
        case .happiness: return "小さな幸せ"
        case .dream:     return "夢"
        case .scenery:   return "景色"
        case .words:     return "言葉"
        case .place:     return "場所"
        case .time:      return "時"
        case .warmth:    return "ぬくもり"
        }
    }

    var icon: String {
        switch self {
        case .sound:     return "waveform"
        case .taste:     return "drop.fill"
        case .scent:     return "wind"
        case .texture:   return "hand.raised"
        case .happiness: return "sparkle"
        case .dream:     return "moon.stars"
        case .scenery:   return "mountain.2"
        case .words:     return "text.quote"
        case .place:     return "mappin.circle.fill"
        case .time:      return "hourglass"
        case .warmth:    return "flame.fill"
        }
    }

    /// Litho-Arche 世界観に沿ったカテゴリーカラー
    var color: Color {
        switch self {
        case .sound:     return Color(hex: "2A7A8A")   // 水青
        case .taste:     return Color(hex: "8A5A1A")   // 琥珀
        case .scent:     return Color(hex: "3A6A4A")   // 苔緑
        case .texture:   return Color(hex: "7A3A5A")   // 深紅
        case .happiness: return Color(hex: "8A6A2A")   // 金
        case .dream:     return Color(hex: "6A3A8A")   // 星雲紫
        case .scenery:   return Color(hex: "2A4A8A")   // 深青
        case .words:     return Color(hex: "3A6B9E")   // フローライト青
        case .place:     return Color(hex: "3A7A3A")   // 深緑（大地）
        case .time:      return Color(hex: "9A7A2A")   // 琥珀金（古い時計）
        case .warmth:    return Color(hex: "9A4A1A")   // 珊瑚橙（炎・体温）
        }
    }

    /// カードの背景色（color より暗め）
    var dimColor: Color {
        switch self {
        case .sound:     return Color(hex: "0A1E22")
        case .taste:     return Color(hex: "1E1008")
        case .scent:     return Color(hex: "0C1A10")
        case .texture:   return Color(hex: "1E0A12")
        case .happiness: return Color(hex: "1E1608")
        case .dream:     return Color(hex: "160A22")
        case .scenery:   return Color(hex: "0A1222")
        case .words:     return Color(hex: "0A1428")
        case .place:     return Color(hex: "0A1A0A")
        case .time:      return Color(hex: "1E1806")
        case .warmth:    return Color(hex: "1E0C06")
        }
    }

    // 標本箱ワーク専用のテキスト
    var specimenPrompt: String {
        switch self {
        case .sound:
            return "耳に焼き付いたあの音。\n記憶に刻まれた響きを瓶に封じ込める。"
        case .taste:
            return "舌が覚えているあの味。\n記憶に宿る風味を標本として残す。"
        case .scent:
            return "鼻が覚えているあの香り。\n空気の中に宿る記憶を採取する。"
        case .texture:
            return "指先が覚えているあの感触。\n皮膚の記憶を言葉で封じ込める。"
        case .dream:
            return "まどろみの中に宿った夢。\n目覚めとともに消えかける幻を採取する。"
        case .place:
            return "あの場所の空気ごと封じ込める。\n足跡と記憶を標本として残す。"
        case .time:
            return "流れ去ったあの瞬間。\n二度と戻らない時の砂粒を封じ込める。"
        case .warmth:
            return "心に残る誰かの温もり、陽だまり。\n失いたくない体温の記憶を残す。"
        default:
            return "この感覚を言葉にして、標本として保存する。"
        }
    }

    var specimenPlaceholder: String {
        switch self {
        case .sound:    return "例：雨が屋根を叩く音、古い時計の秒針…"
        case .taste:    return "例：ベルガモットの紅茶、祖母の手料理…"
        case .scent:    return "例：雨上がりの土、古い本のページ…"
        case .texture:  return "例：冷たい石の感触、毛布の温もり…"
        case .dream:    return "例：空を飛んでいた夢、会いたい人が出てきた朝…"
        case .place:    return "例：あの角の古い本屋、夕暮れの公園…"
        case .time:     return "例：あの夏の午後、時が止まったような一瞬…"
        case .warmth:   return "例：手を握られた感触、陽だまりの縁側…"
        default:        return "この感覚を言葉にしてみる…"
        }
    }
}

// MARK: - SwiftData モデル

@Model
final class SensoryEntry {
    var title:        String
    var body:         String
    var categoryRaw:  String          // SensoryCategory.rawValue
    var imageData:    Data?           // 添付画像（任意）
    var recordedDate: Date            // 感覚を覚えた日
    var createdAt:    Date
    var updatedAt:    Date
    var isPinned:     Bool

    init(
        title:        String          = "",
        body:         String          = "",
        category:     SensoryCategory = .happiness,
        recordedDate: Date            = .now
    ) {
        self.title        = title
        self.body         = body
        self.categoryRaw  = category.rawValue
        self.recordedDate = recordedDate
        self.createdAt    = .now
        self.updatedAt    = .now
        self.isPinned     = false
    }

    var category: SensoryCategory {
        get { SensoryCategory(rawValue: categoryRaw) ?? .happiness }
        set { categoryRaw = newValue.rawValue }
    }
}
