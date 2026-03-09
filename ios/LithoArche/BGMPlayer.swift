import AVFoundation
import Combine

// MARK: - BGM シングルトン

final class BGMPlayer: ObservableObject {
    static let shared = BGMPlayer()

    @Published var isPlaying = false
    private var player: AVAudioPlayer?

    private init() {
        // ファイル名: bgm_theme.mp3（Playgroundsに追加するMP3の名前）
        guard let url = Bundle.main.url(forResource: "bgm_theme", withExtension: "mp3") else {
            return
        }
        player = try? AVAudioPlayer(contentsOf: url)
        player?.numberOfLoops = -1   // 無限ループ
        player?.volume = 0.45
        player?.prepareToPlay()
    }

    func toggle() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying.toggle()
    }
}

// MARK: - BGM ボタン UI

import SwiftUI

struct BGMToggleButton: View {
    @ObservedObject var bgm: BGMPlayer
    @State private var pulse = false

    var body: some View {
        Button(action: { bgm.toggle() }) {
            ZStack {
                // 外側グロー（再生中のみ）
                if bgm.isPlaying {
                    Circle()
                        .fill(Color(hex: "C89040").opacity(pulse ? 0.18 : 0.06))
                        .frame(width: 44, height: 44)
                        .blur(radius: 8)
                        .animation(
                            .easeInOut(duration: 1.6).repeatForever(autoreverses: true),
                            value: pulse
                        )
                }

                Circle()
                    .fill(Color(hex: "0D0A06").opacity(0.75))
                    .overlay(
                        Circle().stroke(
                            Color(hex: bgm.isPlaying ? "C89040" : "3A3020").opacity(0.7),
                            lineWidth: 1
                        )
                    )
                    .frame(width: 36, height: 36)

                Image(systemName: bgm.isPlaying ? "music.note" : "speaker.slash")
                    .font(.system(size: 14))
                    .foregroundStyle(
                        Color(hex: bgm.isPlaying ? "D4A860" : "4A4030")
                    )
            }
        }
        .frame(width: 44, height: 44)
        .onAppear {
            pulse = true
        }
    }
}
