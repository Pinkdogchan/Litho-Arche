# 画像ファイルの配置場所

このフォルダ（`public`）に画像ファイルを配置してください。

## 使用方法

### 1. 画像を配置
画像ファイルをこの`public`フォルダにコピーしてください。

例：
- `public/rufen.jpg`
- `public/crystal-vein.jpg`
- `public/lunar-moss.jpg`

### 2. Next.jsで画像を使用

#### 方法A: Next.jsのImageコンポーネント（推奨）
```tsx
import Image from 'next/image'

<Image
  src="/rufen.jpg"
  alt="ルーフェン"
  width={500}
  height={500}
  className="rounded-lg"
/>
```

#### 方法B: 通常のimgタグ
```tsx
<img src="/rufen.jpg" alt="ルーフェン" className="rounded-lg" />
```

### 3. パスの注意点
- `public`フォルダ内のファイルは、`/`から始まるパスで参照します
- 例：`public/rufen.jpg` → `/rufen.jpg`
- `public/images/rufen.jpg` → `/images/rufen.jpg`

## 推奨される画像フォルダ構造

```
public/
  ├── characters/     # キャラクター画像
  │   └── rufen.jpg
  ├── areas/          # エリア画像
  │   ├── crystal-vein.jpg
  │   ├── lunar-moss.jpg
  │   └── bios-nebula.jpg
  └── works/          # 作品画像
      └── ...
```
