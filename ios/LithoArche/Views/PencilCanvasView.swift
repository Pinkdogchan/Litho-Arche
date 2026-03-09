import SwiftUI
import PencilKit

// MARK: - UIViewRepresentable ラッパー

/// PKCanvasView を SwiftUI に橋渡し
struct PencilCanvasView: UIViewRepresentable {

    @Binding var drawing:    PKDrawing
    @Binding var canvasSize: CGSize
    var isRulerActive: Bool = false

    // ToolPicker の表示制御（外から渡す）
    let toolPicker: PKToolPicker

    /// 新しいストロークが追加された時に呼ばれる（最終点座標）— スパークエフェクト用
    var onStrokeAdded: ((CGPoint) -> Void)? = nil

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawing           = drawing
        canvas.drawingPolicy     = .anyInput   // Pencil & 指どちらも可
        canvas.backgroundColor   = .clear
        canvas.isOpaque          = false
        canvas.overrideUserInterfaceStyle = .dark

        // ツールピッカーをキャンバスに接続
        toolPicker.setVisible(true, forFirstResponder: canvas)
        toolPicker.addObserver(canvas)
        canvas.becomeFirstResponder()

        canvas.delegate = context.coordinator
        return canvas
    }

    func updateUIView(_ canvas: PKCanvasView, context: Context) {
        // 外部から drawing が書き換わった場合（Undo/Clear など）に反映
        if canvas.drawing != drawing {
            canvas.drawing = drawing
        }
        canvas.isRulerActive = isRulerActive
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: PencilCanvasView

        init(parent: PencilCanvasView) {
            self.parent = parent
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawing    = canvasView.drawing
            parent.canvasSize = canvasView.bounds.size
            // スパークエフェクト：最新ストロークの最終点を通知
            if let lastStroke = canvasView.drawing.strokes.last,
               let lastPoint  = lastStroke.path.last {
                let pt = CGPoint(x: lastPoint.location.x, y: lastPoint.location.y)
                DispatchQueue.main.async { self.parent.onStrokeAdded?(pt) }
            }
        }
    }
}
