import Foundation
import Speech
import AVFoundation

/// マイク音声をリアルタイムで文字起こしし、魔法の言葉と照合する
@Observable
final class SpeechRecognizer {

    enum State {
        case idle
        case listening
        case matched       // 魔法の言葉を検出
        case denied        // 権限なし
        case error(String)
    }

    private(set) var state: State = .idle
    private(set) var transcript: String = ""

    private let recognizer  = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))
    private var audioEngine = AVAudioEngine()
    private var request:    SFSpeechAudioBufferRecognitionRequest?
    private var task:       SFSpeechRecognitionTask?

    // 照合対象の魔法の言葉（呼び出し側がセット）
    var magicWord: String = ""

    // MARK: - Public API

    func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                if status != .authorized { self?.state = .denied }
            }
        }
    }

    func startListening() {
        guard case .idle = state else { return }
        guard recognizer?.isAvailable == true else {
            state = .error("音声認識が利用できません")
            return
        }

        do {
            try startAudioSession()
            try startRecognition()
            state = .listening
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        request = nil
        task    = nil
        if case .matched = state { return } // 一致済みなら idle に戻さない
        state = .idle
    }

    func reset() {
        stopListening()
        transcript = ""
        state      = .idle
    }

    // MARK: - Private

    private func startAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try session.setActive(true, options: .notifyOthersOnDeactivation)
    }

    private func startRecognition() throws {
        request = SFSpeechAudioBufferRecognitionRequest()
        guard let request else { return }
        request.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let format    = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.request?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        task = recognizer?.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }

            if let result {
                let text = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    self.transcript = text
                    self.checkForMagicWord(in: text)
                }
            }

            if error != nil || result?.isFinal == true {
                DispatchQueue.main.async {
                    if case .matched = self.state { return }
                    self.state = .idle
                }
            }
        }
    }

    /// 書き起こしテキストに魔法の言葉が含まれるか確認（部分一致）
    private func checkForMagicWord(in text: String) {
        guard !magicWord.isEmpty else { return }
        let normalized = text.lowercased().trimmingCharacters(in: .whitespaces)
        let target     = magicWord.lowercased().trimmingCharacters(in: .whitespaces)

        if normalized.contains(target) {
            state = .matched
            stopListening()
        }
    }
}
