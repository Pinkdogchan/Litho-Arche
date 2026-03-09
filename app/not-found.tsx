import Image from 'next/image';
import Link from 'next/link';

export default function NotFound() {
  return (
    <main className="min-h-screen bg-gradient-to-b from-deep-night-200 via-deep-night-100 to-deep-night-200 flex items-center justify-center px-4">
      <div className="text-center max-w-lg mx-auto">

        <div className="flex justify-center mb-6">
          <Image
            src="/rufen-404.png"
            alt="あわわ..."
            width={480}
            height={600}
            className="w-64 md:w-80 drop-shadow-2xl animate-float"
            style={{ animationDuration: '6s' }}
          />
        </div>

        <h1 className="text-6xl font-bold text-luminous-blue-200 glow-luminous mb-4" style={{ fontFamily: "'Kaisei HarunoUmi', cursive" }}>
          404
        </h1>

        <p className="text-luminous-blue-100/80 text-lg mb-2 tracking-widest">
          このページは観測されませんでした
        </p>

        <p className="text-luminous-blue-100/50 text-sm mb-10 italic" style={{ fontFamily: "'Caveat', cursive", fontSize: '1rem' }}>
          「あわわ……もしかしてブラックホールに吸い込まれた……？」
        </p>

        <Link
          href="/"
          className="inline-flex items-center text-luminous-blue-300 hover:text-luminous-blue-200 transition-colors tracking-widest"
        >
          <span className="mr-2">←</span>
          博物誌のトップへ戻る
        </Link>

      </div>
    </main>
  );
}
