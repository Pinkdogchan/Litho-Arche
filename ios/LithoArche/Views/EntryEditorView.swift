import SwiftUI
import SwiftData
import PhotosUI

/// 感覚アーカイブ エントリの新規作成 / 編集シート
struct EntryEditorView: View {

    @Bindable var entry: SensoryEntry
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var uiImage: UIImage?                = nil
    @State private var showDeleteConfirm = false
    var onDelete: (() -> Void)? = nil

    var body: some View {
        ZStack {
            Color(hex: "EDE4D0").ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {

                    // ── カテゴリー選択 ──────────────────
                    categoryPicker

                    // ── タイトル ────────────────────────
                    VStack(alignment: .leading, spacing: 6) {
                        label("タイトル")
                        TextField("", text: $entry.title,
                                  prompt: Text("この感覚に名前をつける")
                                    .foregroundColor(Color(hex: "A09070")))
                            .font(.system(size: 22, weight: .thin, design: .serif))
                            .foregroundStyle(Color(hex: "2A1808"))
                            .padding(.vertical, 10)
                            .overlay(alignment: .bottom) {
                                Rectangle()
                                    .fill(entry.category.color.opacity(0.5))
                                    .frame(height: 0.7)
                            }
                    }

                    // ── 感覚を覚えた日 ──────────────────
                    VStack(alignment: .leading, spacing: 6) {
                        label("感覚を覚えた日")
                        DatePicker("", selection: $entry.recordedDate,
                                   displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .colorScheme(.light)
                            .tint(entry.category.color)
                    }

                    // ── 本文 ────────────────────────────
                    VStack(alignment: .leading, spacing: 6) {
                        label("記憶")
                        ZStack(alignment: .topLeading) {
                            if entry.body.isEmpty {
                                Text("その感覚を言葉にしてみる…")
                                    .font(.system(size: 16, weight: .light))
                                    .foregroundStyle(Color(hex: "A09070"))
                                    .padding(.top, 8)
                                    .allowsHitTesting(false)
                            }
                            TextEditor(text: $entry.body)
                                .font(.system(size: 16, weight: .light))
                                .foregroundStyle(Color(hex: "2A1808"))
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 160)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(hex: "F0E8D4").opacity(0.55))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 3)
                                        .stroke(entry.category.color.opacity(0.35), lineWidth: 1)
                                )
                        )
                    }

                    // ── 画像添付 ────────────────────────
                    VStack(alignment: .leading, spacing: 10) {
                        label("画像（任意）")

                        if let img = uiImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                                .overlay(alignment: .topTrailing) {
                                    Button {
                                        uiImage        = nil
                                        entry.imageData = nil
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 22))
                                            .foregroundStyle(Color(hex: "4A3018").opacity(0.8))
                                            .padding(6)
                                    }
                                }
                        } else {
                            PhotosPicker(selection: $selectedPhoto,
                                         matching: .images) {
                                HStack(spacing: 10) {
                                    Image(systemName: "photo")
                                    Text("写真を選ぶ")
                                        .font(.system(size: 13, weight: .light))
                                }
                                .foregroundStyle(entry.category.color)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 3)
                                        .stroke(entry.category.color.opacity(0.4), lineWidth: 1)
                                )
                            }
                        }
                    }

                    // ── ピン留め ────────────────────────
                    Toggle(isOn: $entry.isPinned) {
                        HStack(spacing: 6) {
                            Image(systemName: "pin")
                                .font(.system(size: 13))
                                .foregroundStyle(entry.category.color)
                            Text("ピン留め（一覧の先頭に表示）")
                                .font(.system(size: 13, weight: .light))
                                .foregroundStyle(Color(hex: "5A3A18"))
                        }
                    }
                    .tint(entry.category.color)

                    // ── 削除ボタン ──────────────────────
                    if onDelete != nil {
                        Button(role: .destructive) {
                            showDeleteConfirm = true
                        } label: {
                            Label("この記憶を消去する", systemImage: "trash")
                                .font(.system(size: 13, weight: .light))
                                .foregroundStyle(Color(hex: "8A2A2A"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2)
                                        .stroke(Color(hex: "8A2A2A").opacity(0.5), lineWidth: 1)
                                )
                        }
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 36)
                .padding(.vertical, 20)
                .background(
                    GeometryReader { geo in
                        Image("paper_texture.png")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                    }
                )
                .padding(.horizontal, 10)
                .padding(.vertical, 14)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("閉じる") { dismiss() }
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(Color(hex: "6A4A28"))
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("保存") { save() }
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(Color(hex: "2A1808"))
            }
        }
        .onChange(of: selectedPhoto) { _, item in
            loadPhoto(item)
        }
        .onAppear {
            if let data = entry.imageData {
                uiImage = UIImage(data: data)
            }
        }
        .confirmationDialog("記憶を消去しますか？", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("消去する", role: .destructive) {
                onDelete?()
                dismiss()
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("この操作は取り消せません")
        }
    }

    // MARK: - Category Picker

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(SensoryCategory.allCases, id: \.self) { cat in
                    Button {
                        withAnimation(.spring(duration: 0.25)) { entry.category = cat }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: cat.icon)
                                .font(.system(size: 11))
                            Text(cat.label)
                                .font(.system(size: 12, weight: .light))
                        }
                        .foregroundStyle(
                            entry.category == cat ? Color(hex: "2A1808") : cat.color
                        )
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 2)
                                .fill(entry.category == cat ? cat.color.opacity(0.25) : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2)
                                        .stroke(cat.color.opacity(entry.category == cat ? 0.8 : 0.3), lineWidth: 1)
                                )
                        )
                    }
                }
            }
            .padding(.horizontal, 2)
            .padding(.vertical, 4)
        }
    }

    // MARK: - Helpers

    private func label(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .light))
            .foregroundStyle(entry.category.color.opacity(0.8))
            .tracking(2)
    }

    private func save() {
        entry.updatedAt = .now
        try? context.save()
        dismiss()
    }

    private func loadPhoto(_ item: PhotosPickerItem?) {
        Task {
            guard let data = try? await item?.loadTransferable(type: Data.self) else { return }
            await MainActor.run {
                entry.imageData = data
                uiImage = UIImage(data: data)
            }
        }
    }
}
