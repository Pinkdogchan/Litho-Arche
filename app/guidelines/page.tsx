'use client';

import Link from 'next/link';
import StarsBackground from '../components/StarsBackground';
import { useLanguage } from '../context/LanguageContext';
import { useTranslations } from '../i18n';

export default function GuidelinesPage() {
  const { lang } = useLanguage();
  const t = useTranslations(lang);
  const g = t.guidelines;

  return (
    <main className="min-h-screen bg-gradient-to-b from-deep-night-200 via-deep-night-100 to-deep-night-200 relative overflow-hidden">
      {/* 星空の背景 */}
      <StarsBackground count={40} />

      <div className="relative z-10 min-h-screen px-4 py-16">
        <div className="max-w-3xl mx-auto">
          <Link href="/" className="inline-flex items-center text-luminous-blue-300 hover:text-luminous-blue-200 mb-8 transition-colors">
            <span className="mr-2">←</span>
            {t.backToTop}
          </Link>

          <div className="text-center mb-12 space-y-3">
            <h1 className="text-4xl md:text-5xl font-bold glow-luminous text-luminous-blue-200" style={{ fontFamily: "'Kaisei HarunoUmi', cursive" }}>
              {g.title}
            </h1>
            <div className="w-32 h-1 bg-gradient-to-r from-transparent via-luminous-blue-400 to-transparent mx-auto" />
            <p className="text-luminous-blue-100/60 tracking-widest text-sm">{g.subtitle}</p>
          </div>

          {/* はじめに */}
          <section className="bg-deep-night-100/50 backdrop-blur-sm border border-luminous-blue-500/20 rounded-lg p-8 md:p-12 glow-soft mb-8">
            <p className="text-luminous-blue-100/90 leading-relaxed" style={{ fontFamily: "'Caveat', cursive", fontSize: '1.1rem' }}>
              {g.intro1}
            </p>
            <p className="text-luminous-blue-100/80 leading-relaxed mt-4 text-sm md:text-base">
              {g.intro2}
            </p>
          </section>

          {/* 許可していること */}
          <section className="bg-deep-night-100/30 backdrop-blur-sm border border-luminous-blue-400/10 rounded-lg p-8 md:p-12 mb-8">
            <h2 className="text-xl font-semibold text-luminous-blue-200 mb-6 tracking-widest" style={{ fontFamily: "'Kaisei HarunoUmi', cursive" }}>
              {g.permittedTitle}
            </h2>
            <ul className="space-y-4">
              {g.permitted.map((item, i) => (
                <li key={i} className="flex items-start gap-3">
                  <span className="text-luminous-blue-400 mt-1 flex-shrink-0">✦</span>
                  <p className="text-luminous-blue-100/90 leading-relaxed text-sm md:text-base">{item}</p>
                </li>
              ))}
            </ul>
          </section>

          {/* お断りしていること */}
          <section className="bg-deep-night-100/30 backdrop-blur-sm border border-luminous-blue-400/10 rounded-lg p-8 md:p-12 mb-8">
            <h2 className="text-xl font-semibold text-luminous-blue-200 mb-6 tracking-widest" style={{ fontFamily: "'Kaisei HarunoUmi', cursive" }}>
              {g.prohibitedTitle}
            </h2>
            <ul className="space-y-6">
              {g.prohibited.map((item, i) => (
                <li key={i} className="border-l-2 border-luminous-blue-500/30 pl-6">
                  <p className="text-luminous-blue-200 font-semibold mb-1 text-sm md:text-base">{item.title}</p>
                  <p className="text-luminous-blue-100/70 leading-relaxed text-sm">{item.body}</p>
                </li>
              ))}
            </ul>
          </section>

          {/* クレジット */}
          <section className="bg-deep-night-100/50 backdrop-blur-sm border border-luminous-blue-500/20 rounded-lg p-8 md:p-12 glow-soft mb-8 text-center">
            <h2 className="text-xl font-semibold text-luminous-blue-200 mb-4 tracking-widest" style={{ fontFamily: "'Kaisei HarunoUmi', cursive" }}>
              {g.creditTitle}
            </h2>
            <p className="text-luminous-blue-300 text-lg mb-4" style={{ fontFamily: "'Kaisei HarunoUmi', cursive" }}>
              {g.creditName}
            </p>
            <p className="text-luminous-blue-100/70 text-sm leading-relaxed whitespace-pre-line">
              {g.creditBody}
            </p>
          </section>

          {/* 更新・問い合わせ */}
          <section className="bg-deep-night-100/30 backdrop-blur-sm border border-luminous-blue-400/10 rounded-lg p-8 md:p-12 mb-12">
            <h2 className="text-xl font-semibold text-luminous-blue-200 mb-4 tracking-widest" style={{ fontFamily: "'Kaisei HarunoUmi', cursive" }}>
              {g.contactTitle}
            </h2>
            <p className="text-luminous-blue-100/80 leading-relaxed text-sm md:text-base mb-3">
              {g.contactBody}
            </p>
            <p className="text-luminous-blue-100/60 text-sm">
              {g.contactNote}
            </p>
          </section>

          <p className="text-center text-luminous-blue-100/40 text-xs mb-12">{g.lastUpdated}</p>

          <div className="text-center">
            <Link href="/" className="inline-flex items-center text-luminous-blue-300 hover:text-luminous-blue-200 transition-colors">
              <span className="mr-2">←</span>
              {t.backToTop}
            </Link>
          </div>
        </div>
      </div>
    </main>
  );
}
