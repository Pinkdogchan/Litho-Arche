import SwiftUI

// MARK: - Color Hex Helper（プロジェクト全体で共有）

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >>  8) & 0xFF) / 255
        let b = Double( int        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - タイトルバナー（全画面共通）

/// deco_title_banner.png を背景にタイトル・サブタイトルを重ねる共通コンポーネント
struct TitleBannerView: View {
    let title:    String
    let subtitle: String

    var body: some View {
        ZStack {
            Image("deco_title_banner.png")
                .resizable()
                .scaledToFill()
                .opacity(0.55)
                .colorMultiply(Color(hex: "C8B890"))
                .clipped()

            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 20, weight: .thin, design: .serif))
                    .foregroundStyle(Color(hex: "1A1208"))
                Text(subtitle)
                    .font(.system(size: 10, weight: .light))
                    .foregroundStyle(Color(hex: "4A3A18"))
                    .tracking(1)
            }
            .padding(.vertical, 18)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
    }
}
