import SwiftUI
import SwiftData

struct HomeView: View {
    let profile: UserProfile

    @Environment(\.modelContext) private var context
    @Query(sort: \DrawingEntry.updatedAt, order: .reverse) private var drawings: [DrawingEntry]

    @State private var activeEntry:   DrawingEntry? = nil
    @State private var showArchive    = false
    @State private var showWorkbook   = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "080A1A").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {

                        // ── 魔法の言葉 ────────────────────────
                        VStack(spacing: 10) {
                            Text("あなたの言葉")
                                .font(.system(size: 11, weight: .light))
                                .foregroundStyle(Color(hex: "3A4A5A"))
                                .tracking(3)
                            Text("「\(profile.magicWord)」")
                                .font(.system(size: 28, weight: .thin, design: .serif))
                                .foregroundStyle(Color(hex: "C8D8F0"))
                        }
                        .padding(.top, 56)
                        .padding(.bottom, 40)

                        // ── ナビゲーションカード ──────────────
                        VStack(spacing: 14) {

                            // 観測ワークブック
                            sectionCard(
                                title:    "観測ワークブック",
                                subtitle: "未完成の記録・封印儀式・星屑の標本・規定外フォルダ",
                                icon:     "book.pages",
                                color:    Color(hex: "6A3A8A")
                            ) { showWorkbook = true }

                            // 感覚のアーカイブ
                            sectionCard(
                                title:    "感覚のアーカイブ",
                                subtitle: "音・匂い・小さな幸せ・夢の記録",
                                icon:     "archivebox",
                                color:    Color(hex: "8A6A2A")
                            ) { showArchive = true }
                        }
                        .padding(.horizontal, 22)
                        .padding(.bottom, 32)

                        // ── 魂の器ワークショップ ─────────────
                        sectionHeader(title: "魂の器・ワークショップ", icon: "pencil.tip")
                            .padding(.horizontal, 22)
                            .padding(.bottom, 14)

                        if drawings.isEmpty {
                            emptyWorkshop.padding(.bottom, 24)
                        } else {
                            drawingGrid.padding(.bottom, 24)
                        }

                        Button { createNewEntry() } label: {
                            Label("新しい器を作る", systemImage: "plus")
                                .font(.system(size: 14, weight: .light))
                                .foregroundStyle(Color(hex: "C8D8F0"))
                                .frame(width: 220, height: 48)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2)
                                        .stroke(Color(hex: "3A6B9E"), lineWidth: 1)
                                )
                        }
                        .padding(.bottom, 60)
                    }
                }
            }
            .navigationDestination(isPresented: $showArchive) { ArchiveView() }
            .navigationDestination(isPresented: $showWorkbook) { WorkbookView() }
            .fullScreenCover(item: $activeEntry) { entry in WorkshopView(entry: entry) }
        }
    }

    // MARK: - Subviews

    private func sectionCard(
        title: String, subtitle: String,
        icon: String, color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundStyle(color)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 15, weight: .light, design: .serif))
                        .foregroundStyle(Color(hex: "C8D8F0"))
                    Text(subtitle)
                        .font(.system(size: 11, weight: .light))
                        .foregroundStyle(Color(hex: "4A6A8A"))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: "2A3A50"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: "0A0D1E"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(color.opacity(0.2), lineWidth: 0.5)
                    )
            )
        }
    }

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).font(.system(size: 11)).foregroundStyle(Color(hex: "3A6B9E"))
            Text(title).font(.system(size: 11, weight: .light)).foregroundStyle(Color(hex: "4A6A8A")).tracking(2)
            Spacer()
            Rectangle().fill(Color(hex: "1A2A3A")).frame(height: 0.5).frame(maxWidth: 120)
        }
    }

    private var emptyWorkshop: some View {
        VStack(spacing: 14) {
            Image(systemName: "scribble.variable").font(.system(size: 36)).foregroundStyle(Color(hex: "2A3A4A"))
            Text("まだ作品がありません").font(.system(size: 13, weight: .light)).foregroundStyle(Color(hex: "3A4A5A"))
        }
        .padding(.vertical, 24)
    }

    private var drawingGrid: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(drawings.prefix(6)) { entry in
                    DrawingThumbnailCard(entry: entry).frame(width: 160)
                        .onTapGesture { activeEntry = entry }
                }
            }
            .padding(.horizontal, 22)
        }
    }

    private func createNewEntry() {
        let entry = DrawingEntry(title: "新しい器")
        context.insert(entry)
        try? context.save()
        activeEntry = entry
    }
}

private struct DrawingThumbnailCard: View {
    let entry: DrawingEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(hex: "0F1428"))
                    .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color(hex: "2A3A50"), lineWidth: 0.5))
                if let data = entry.thumbnailData, let img = UIImage(data: data) {
                    Image(uiImage: img).resizable().scaledToFit().padding(6)
                } else {
                    Image(systemName: "scribble.variable").font(.system(size: 24)).foregroundStyle(Color(hex: "2A3A4A"))
                }
            }
            .frame(height: 120)
            Text(entry.title)
                .font(.system(size: 12, weight: .light, design: .serif))
                .foregroundStyle(Color(hex: "C8D8F0"))
                .lineLimit(1)
                .padding(.horizontal, 4)
        }
        .background(Color(hex: "0A0D1E"))
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

#Preview {
    HomeView(profile: UserProfile(magicWord: "しずか", sanctuaryName: "星の記録庫"))
        .modelContainer(for: [UserProfile.self, DrawingEntry.self, SensoryEntry.self,
                               LogResponse.self, SealedMemory.self], inMemory: true)
}
