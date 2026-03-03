import Link from 'next/link';
import { notFound } from 'next/navigation';
import { characters } from '../../lib/characters';
import CharacterProfile from '../../components/CharacterProfile';

export async function generateStaticParams() {
  return Object.keys(characters).map((slug) => ({ slug }));
}

export default function CharacterPage({ params }: { params: { slug: string } }) {
  const character = characters[params.slug];
  if (!character) notFound();

  return (
    <main className="min-h-screen bg-gradient-to-b from-deep-night-200 via-deep-night-100 to-deep-night-200 relative overflow-hidden">
      {/* 星空の背景 */}
      <div className="fixed inset-0 overflow-hidden pointer-events-none">
        {Array.from({ length: 50 }).map((_, i) => (
          <div
            key={i}
            className="absolute rounded-full bg-luminous-blue-300 animate-sparkle"
            style={{
              left: `${Math.random() * 100}%`,
              top: `${Math.random() * 100}%`,
              width: `${Math.random() * 3 + 1}px`,
              height: `${Math.random() * 3 + 1}px`,
              animationDelay: `${Math.random() * 2}s`,
              opacity: Math.random() * 0.5 + 0.3,
            }}
          />
        ))}
      </div>

      <div className="relative z-10 min-h-screen px-4 py-16">
        <div className="max-w-4xl mx-auto">
          <Link href="/" className="inline-flex items-center text-luminous-blue-300 hover:text-luminous-blue-200 mb-8 transition-colors">
            <span className="mr-2">←</span>
            博物誌のトップへ戻る
          </Link>

          <div className="text-center mb-12 space-y-3">
            <h1 className="text-5xl md:text-7xl font-bold glow-luminous text-luminous-blue-200" style={{ fontFamily: "'Kaisei HarunoUmi', cursive" }}>
              {character.name}
            </h1>
            <div className="w-32 h-1 bg-gradient-to-r from-transparent via-luminous-blue-400 to-transparent mx-auto" />
            <p className="text-lg text-luminous-blue-100/70 tracking-widest">{character.nameEn}</p>
            <p className="text-base text-luminous-blue-300/80 tracking-wider" style={{ fontFamily: "'Caveat', cursive" }}>{character.title}</p>
          </div>

          <CharacterProfile character={character} />

          <div className="text-center mt-12">
            <Link href="/" className="inline-flex items-center text-luminous-blue-300 hover:text-luminous-blue-200 transition-colors">
              <span className="mr-2">←</span>
              博物誌のトップへ戻る
            </Link>
          </div>
        </div>
      </div>
    </main>
  );
}
