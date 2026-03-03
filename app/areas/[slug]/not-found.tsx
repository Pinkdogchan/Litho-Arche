import Link from 'next/link';

export default function NotFound() {
  return (
    <main className="min-h-screen bg-gradient-to-b from-deep-night-200 via-deep-night-100 to-deep-night-200 flex items-center justify-center px-4">
      <div className="text-center">
        <h1 className="text-4xl font-bold text-luminous-blue-200 mb-4">
          エリアが見つかりません
        </h1>
        <p className="text-luminous-blue-100/80 mb-8">
          指定されたエリアは存在しません。
        </p>
        <Link
          href="/"
          className="inline-flex items-center text-luminous-blue-300 hover:text-luminous-blue-200 transition-colors"
        >
          <span className="mr-2">←</span>
          博物誌のトップへ戻る
        </Link>
      </div>
    </main>
  );
}
