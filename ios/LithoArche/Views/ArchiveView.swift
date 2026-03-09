import SwiftUI
import SwiftData

/// 感覚のアーカイブ — カテゴリー別一覧ビュー
struct ArchiveView: View {

    @Environment(\.modelContext) private var context
    @Query(sort: \SensoryEntry.updatedAt, order: .reverse) private var allEntries: [SensoryEntry]

    @State private var selectedCategory: SensoryCategory? = nil   // nil = すべて
    @State private var searchText   = ""
    @State private var showEditor   = false
    @State private var editingEntry: SensoryEntry? = nil

    // フィルタ済みエントリ
    private var filtered: [SensoryEntry] {
        allEntries.filter { entry in
            let matchCat    = selectedCategory == nil || entry.category == selectedCategory
            let matchSearch = searchText.isEmpty
                           || entry.title.localizedCaseInsensitiveContains(searchText)
                           || entry.body.localizedCaseInsensitiveContains(searchText)
            return matchCat && matchSearch
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(hex: "080A1A").ignoresSafeArea()

            VStack(spacing: 0) {

                // ── ヘッダー ─────────────────────────────
                header

                // ── カテゴリーフィルター ──────────────────
                categoryFilter
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                // ── 検索バー ─────────────────────────────
                searchBar
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)

                // ── エントリ一覧 ──────────────────────────
                if filtered.isEmpty {
                    emptyState
                } else {
                    entryList
                }
            }

            // ── 新規追加ボタン ─────────────────────────
            addButton
                .padding(28)
        }
        .sheet(item: $editingEntry) { entry in
            NavigationStack {
                EntryEditorView(entry: entry) {
                    context.delete(entry)
                    try? context.save()
                }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("感覚のアーカイブ")
                    .font(.system(size: 22, weight: .thin, design: .serif))
                    .foregroundStyle(Color(hex: "C8D8F0"))
                Text("\(allEntries.count) の記憶")
                    .font(.system(size: 11, weight: .light))
                    .foregroundStyle(Color(hex: "3A4A5A"))
                    .tracking(1)
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 8)
    }

    // MARK: - Category Filter

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // 「すべて」タブ
                filterChip(
                    label: "すべて",
                    icon:  "square.grid.2x2",
                    color: Color(hex: "3A6B9E"),
                    isSelected: selectedCategory == nil
                ) {
                    withAnimation(.spring(duration: 0.25)) { selectedCategory = nil }
                }

                ForEach(SensoryCategory.allCases, id: \.self) { cat in
                    let count = allEntries.filter { $0.category == cat }.count
                    filterChip(
                        label:      cat.label,
                        icon:       cat.icon,
                        color:      cat.color,
                        count:      count,
                        isSelected: selectedCategory == cat
                    ) {
                        withAnimation(.spring(duration: 0.25)) {
                            selectedCategory = selectedCategory == cat ? nil : cat
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func filterChip(
        label: String, icon: String,
        color: Color, count: Int? = nil,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                Text(label)
                    .font(.system(size: 12, weight: .light))
                if let count, count > 0 {
                    Text("\(count)")
                        .font(.system(size: 10, weight: .light))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(color.opacity(0.25))
                        .clipShape(Capsule())
                }
            }
            .foregroundStyle(isSelected ? Color(hex: "C8D8F0") : color)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 2)
                    .fill(isSelected ? color.opacity(0.2) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(color.opacity(isSelected ? 0.8 : 0.3), lineWidth: 1)
                    )
            )
        }
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 13))
                .foregroundStyle(Color(hex: "3A4A5A"))

            TextField("", text: $searchText,
                      prompt: Text("記憶を検索…").foregroundColor(Color(hex: "2A3A50")))
                .font(.system(size: 14, weight: .light))
                .foregroundStyle(Color(hex: "C8D8F0"))

            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(hex: "3A4A5A"))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: "0A0F1E"))
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color(hex: "1A2A3A"), lineWidth: 1)
                )
        )
    }

    // MARK: - Entry List

    private var entryList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(filtered) { entry in
                    EntryRowView(entry: entry)
                        .onTapGesture { editingEntry = entry }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                }
            }
            .padding(.bottom, 100)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: selectedCategory?.icon ?? "archivebox")
                .font(.system(size: 40))
                .foregroundStyle(Color(hex: "2A3A4A"))

            Text(selectedCategory == nil
                 ? "まだ記憶がありません\n感覚を言葉にして残しましょう"
                 : "「\(selectedCategory!.label)」の記憶はまだありません")
                .font(.system(size: 13, weight: .light))
                .foregroundStyle(Color(hex: "3A4A5A"))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
            Spacer()
        }
    }

    // MARK: - Add Button

    private var addButton: some View {
        Button {
            let entry = SensoryEntry(
                category: selectedCategory ?? .happiness
            )
            context.insert(entry)
            try? context.save()
            editingEntry = entry
        } label: {
            ZStack {
                Circle()
                    .fill(Color(hex: "0F1A2E"))
                    .overlay(Circle().stroke(Color(hex: "3A6B9E"), lineWidth: 1))
                    .frame(width: 56, height: 56)
                    .shadow(color: Color(hex: "3A6B9E").opacity(0.3), radius: 12)

                Image(systemName: "plus")
                    .font(.system(size: 20))
                    .foregroundStyle(Color(hex: "C8D8F0"))
            }
        }
    }
}

// MARK: - エントリ行

struct EntryRowView: View {
    let entry: SensoryEntry

    var body: some View {
        HStack(alignment: .top, spacing: 14) {

            // カテゴリーカラーのアクセントバー
            RoundedRectangle(cornerRadius: 1)
                .fill(entry.category.color)
                .frame(width: 2, height: 60)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    // カテゴリーバッジ
                    HStack(spacing: 4) {
                        Image(systemName: entry.category.icon)
                            .font(.system(size: 10))
                        Text(entry.category.label)
                            .font(.system(size: 10, weight: .light))
                    }
                    .foregroundStyle(entry.category.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(entry.category.color.opacity(0.12))
                    .clipShape(Capsule())

                    Spacer()

                    // ピン・日付
                    if entry.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(entry.category.color.opacity(0.7))
                    }

                    Text(entry.recordedDate.formatted(.dateTime.year().month().day()))
                        .font(.system(size: 10, weight: .light))
                        .foregroundStyle(Color(hex: "3A4A5A"))
                }

                // タイトル
                Text(entry.title.isEmpty ? "（無題）" : entry.title)
                    .font(.system(size: 15, weight: .light, design: .serif))
                    .foregroundStyle(Color(hex: "C8D8F0"))
                    .lineLimit(1)

                // 本文プレビュー
                if !entry.body.isEmpty {
                    Text(entry.body)
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(Color(hex: "5A6A7A"))
                        .lineLimit(2)
                        .lineSpacing(3)
                }
            }

            // 添付画像サムネイル
            if let data = entry.imageData, let img = UIImage(data: data) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 52, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 3))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(entry.category.dimColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(entry.category.color.opacity(0.15), lineWidth: 0.5)
                )
        )
    }
}

#Preview {
    ArchiveView()
        .modelContainer(for: SensoryEntry.self, inMemory: true)
}
