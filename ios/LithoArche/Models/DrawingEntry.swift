import Foundation
import SwiftData
import PencilKit

/// ワークショップで作成した描画データを保存するモデル
@Model
final class DrawingEntry {
    var title:               String
    var guideId:             String      // 使用したガイドテンプレートの識別子
    var drawingData:         Data        // PKDrawing をシリアライズしたもの
    var thumbnailData:       Data?       // プレビュー用 PNG（小）
    var isPlacedInSanctuary: Bool        // 聖域の広間で歩いているか
    var sanctuaryImageData:  Data?       // 聖域表示用 PNG（半透過）
    var createdAt:           Date
    var updatedAt:           Date
    var chosenColorHexes:    String      // コンマ区切り hex e.g. "4AFF7A,B07AFF"
    var chosenTexture:       String      // "calcite"|"crystal"|"peach"|"plush"|"none"
    var vow:                 String      // 誓約テキスト

    init(title: String = "新しい作品", guideId: String = "none") {
        self.title               = title
        self.guideId             = guideId
        self.drawingData         = PKDrawing().dataRepresentation()
        self.isPlacedInSanctuary = false
        self.chosenColorHexes    = ""
        self.chosenTexture       = "none"
        self.vow                 = ""
        self.createdAt           = .now
        self.updatedAt           = .now
    }

    /// PKDrawing を復元する
    func loadDrawing() -> PKDrawing {
        (try? PKDrawing(data: drawingData)) ?? PKDrawing()
    }

    /// 描画を保存し、サムネイルを生成する
    func save(drawing: PKDrawing, in bounds: CGRect) {
        drawingData   = drawing.dataRepresentation()
        updatedAt     = .now

        // サムネイル生成 (200pt)
        let scale: CGFloat = 200 / max(bounds.width, 1)
        let img    = drawing.image(from: bounds, scale: scale)
        thumbnailData = img.pngData()
    }

    /// 聖域に召喚する（描画を PNG で保存し、フラグを立てる）
    func summonToSanctuary(drawing: PKDrawing, in bounds: CGRect) {
        save(drawing: drawing, in: bounds)
        let img = drawing.image(from: bounds, scale: 1.0)
        sanctuaryImageData  = img.pngData()
        isPlacedInSanctuary = true
        updatedAt           = .now
    }
}
