'use client';

import Link from 'next/link';
import Image from 'next/image';
import { useLanguage } from '../../context/LanguageContext';
import { useTranslations, useAreaTranslations } from '../../i18n';
import { characters } from '../../lib/characters';
import CreatureCard from '../../components/CreatureCard';
import CharacterProfile from '../../components/CharacterProfile';
import StarsBackground from '../../components/StarsBackground';
import type { AreaStructure } from '../../i18n/types';

export default function AreaContent({
  slug,
  structure,
}: {
  slug: string;
  structure: AreaStructure;
}) {
  const { lang } = useLanguage();
  const t = useTranslations(lang);
  const areaT = useAreaTranslations(lang)[slug];

  if (!areaT) return null;

  const mergedCreatures = structure.creatures?.map((c, i) => ({
    nameEn: c.nameEn,
    image: c.image,
    name: areaT.creatures?.[i]?.name ?? c.nameEn,
    description: areaT.creatures?.[i]?.description ?? '',
  }));

  const mergedIllustrations = structure.illustrations?.map((ill, i) => ({
    image: ill.image,
    nameEn: ill.nameEn,
    name: areaT.illustrations?.[i]?.name ?? ill.nameEn,
    description: areaT.illustrations?.[i]?.description ?? '',
  }));

  const character = structure.characterSlug ? characters[structure.characterSlug] : undefined;

  return (
    <main className="min-h-screen bg-gradient-to-b from-deep-night-200 via-deep-night-100 to-deep-night-200 relative overflow-hidden">
      {/* 星空の背景エフェクト */}
      <StarsBackground count={50} />

      <div className="relative z-10 min-h-screen px-4 py-16">
        <div className="max-w-5xl mx-auto">
          {/* 戻るリンク */}
          <Link
            href="/"
            className="inline-flex items-center text-luminous-blue-300 hover:text-luminous-blue-200 mb-8 transition-colors"
          >
            <span className="mr-2">←</span>
            {t.backToTop}
          </Link>

          {/* タイトルセクション */}
          <div className="text-center mb-12 space-y-4">
            <h1 className="text-5xl md:text-7xl font-bold glow-luminous text-luminous-blue-200">
              {areaT.title}
            </h1>
            <div className="w-32 h-1 bg-gradient-to-r from-transparent via-luminous-blue-400 to-transparent mx-auto"></div>
            <p className="text-xl md:text-2xl text-luminous-blue-100/80 font-light tracking-wider">
              {structure.titleEn}
            </p>
          </div>

          {/* エリアイラスト */}
          {structure.showImage && (
            <div className="relative w-full mb-12 flex flex-col items-center gap-8">
              <div className="relative w-full max-w-2xl">
                <Image
                  src={structure.image}
                  alt={areaT.title}
                  width={900}
                  height={1200}
                  className="w-full rounded-sm drop-shadow-2xl"
                  priority
                />
              </div>
              {structure.extraImages?.map((src, i) => (
                <div key={i} className="relative w-full max-w-2xl">
                  <Image
                    src={src}
                    alt={`${areaT.title} ${i + 2}`}
                    width={900}
                    height={1200}
                    className="w-full rounded-sm drop-shadow-2xl"
                  />
                </div>
              ))}
            </div>
          )}

          {/* エリアの説明 */}
          <section className="bg-deep-night-100/50 backdrop-blur-sm border border-luminous-blue-500/20 rounded-lg p-8 md:p-12 glow-soft mb-8">
            <p className="text-lg md:text-xl text-luminous-blue-100/90 leading-relaxed">
              {areaT.description}
            </p>
          </section>

          {/* 景観のポイント */}
          <section className="bg-deep-night-100/30 backdrop-blur-sm border border-luminous-blue-400/10 rounded-lg p-8 md:p-12 mb-8">
            <div className="relative flex items-center justify-center mb-8">
              <Image
                src="/title-frame.png"
                alt=""
                width={600}
                height={120}
                className="w-full max-w-lg"
                style={{ filter: 'invert(1) sepia(1) saturate(2) hue-rotate(190deg) brightness(1.2)', opacity: 0.85 }}
              />
              <h2 className="absolute text-xl md:text-2xl font-semibold text-luminous-blue-100 tracking-widest" style={{ fontFamily: "'Kaisei HarunoUmi', cursive" }}>
                {t.areaPage.landscapeTitle}
              </h2>
            </div>
            <div className="space-y-4">
              {areaT.landscape.map((point, index) => (
                <p key={index} className="text-luminous-blue-100/90 leading-relaxed">
                  {point}
                </p>
              ))}
            </div>
          </section>

          {/* 星書庫の記録 */}
          <section className="bg-deep-night-100/30 backdrop-blur-sm border border-luminous-blue-400/10 rounded-lg p-8 md:p-12 mb-8">
            <div className="relative flex items-center justify-center mb-8">
              <Image
                src="/title-frame.png"
                alt=""
                width={600}
                height={120}
                className="w-full max-w-lg"
                style={{ filter: 'invert(1) sepia(1) saturate(2) hue-rotate(190deg) brightness(1.2)', opacity: 0.85 }}
              />
              <h2 className="absolute text-xl md:text-2xl font-semibold text-luminous-blue-100 tracking-widest" style={{ fontFamily: "'Kaisei HarunoUmi', cursive" }}>
                {t.areaPage.archiveTitle}
              </h2>
            </div>
            <p className="text-luminous-blue-100/90 leading-relaxed">
              {areaT.worldView}
            </p>
          </section>

          {/* キャラクタープロフィール */}
          {structure.characterSlug && character && (
            <section className="mb-8">
              <div className="relative flex items-center justify-center mb-4">
                <Image
                  src="/title-frame.png"
                  alt=""
                  width={600}
                  height={120}
                  className="w-full max-w-lg"
                  style={{ filter: 'invert(1) sepia(1) saturate(2) hue-rotate(190deg) brightness(1.2)', opacity: 0.85 }}
                />
                <h2 className="absolute text-xl md:text-2xl font-semibold text-luminous-blue-100 tracking-widest" style={{ fontFamily: "'Kaisei HarunoUmi', cursive" }}>
                  {character.nameEn}
                </h2>
              </div>
              <CharacterProfile character={character} featuredVideo={structure.featuredVideo} />
            </section>
          )}

          {/* 生物の紹介 */}
          {mergedCreatures && mergedCreatures.length > 0 && (
            <section className="bg-deep-night-100/30 backdrop-blur-sm border border-luminous-blue-400/10 rounded-lg p-8 md:p-12 mb-8">
              <div className="relative flex items-center justify-center mb-8">
                <Image
                  src="/title-frame.png"
                  alt=""
                  width={600}
                  height={120}
                  className="w-full max-w-lg"
                  style={{ filter: 'invert(1) sepia(1) saturate(2) hue-rotate(190deg) brightness(1.2)', opacity: 0.85 }}
                />
                <h2 className="absolute text-xl md:text-2xl font-semibold text-luminous-blue-100 tracking-widest" style={{ fontFamily: "'Kaisei HarunoUmi', cursive" }}>
                  {t.areaPage.creaturesTitle}
                </h2>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {(() => {
                  const groups: Array<{ image?: string; items: { name: string; nameEn: string; description: string; image?: string }[] }> = [];
                  const imageIndex = new Map<string, number>();
                  for (const creature of mergedCreatures) {
                    if (creature.image && imageIndex.has(creature.image)) {
                      groups[imageIndex.get(creature.image)!].items.push(creature);
                    } else {
                      if (creature.image) imageIndex.set(creature.image, groups.length);
                      groups.push({ image: creature.image, items: [creature] });
                    }
                  }
                  return groups.map((group, gi) => (
                    <CreatureCard key={gi} group={group} />
                  ));
                })()}
              </div>
            </section>
          )}

          {/* イラストギャラリー */}
          {mergedIllustrations && mergedIllustrations.length > 0 && (
            <section className="bg-deep-night-100/30 backdrop-blur-sm border border-luminous-blue-400/10 rounded-lg p-8 md:p-12 mb-8">
              <div className="relative flex items-center justify-center mb-8">
                <Image
                  src="/title-frame.png"
                  alt=""
                  width={600}
                  height={120}
                  className="w-full max-w-lg"
                  style={{ filter: 'invert(1) sepia(1) saturate(2) hue-rotate(190deg) brightness(1.2)', opacity: 0.85 }}
                />
                <h2 className="absolute text-xl md:text-2xl font-semibold text-luminous-blue-100 tracking-widest" style={{ fontFamily: "'Kaisei HarunoUmi', cursive" }}>
                  {areaT.illustrationsTitle ?? t.areaPage.defaultIllustrationsTitle}
                </h2>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {mergedIllustrations.map((item, i) => (
                  <CreatureCard
                    key={i}
                    group={{ image: item.image, items: [{ name: item.name, nameEn: item.nameEn, description: item.description }] }}
                  />
                ))}
              </div>
            </section>
          )}

          {/* 記録官の観察日誌 */}
          {structure.lifeImages && structure.lifeImages.length > 0 && (
            <section className="bg-deep-night-100/30 backdrop-blur-sm border border-luminous-blue-400/10 rounded-lg p-8 md:p-12 mb-8">
              <div className="relative flex items-center justify-center mb-8">
                <Image
                  src="/title-frame.png"
                  alt=""
                  width={600}
                  height={120}
                  className="w-full max-w-lg"
                  style={{ filter: 'invert(1) sepia(1) saturate(2) hue-rotate(190deg) brightness(1.2)', opacity: 0.85 }}
                />
                <h2 className="absolute text-xl md:text-2xl font-semibold text-luminous-blue-100 tracking-widest" style={{ fontFamily: "'Kaisei HarunoUmi', cursive" }}>
                  {t.areaPage.observerJournalTitle}
                </h2>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {structure.lifeImages.slice(0, 2).map((src, i) => (
                  <div key={i} className="flex items-center justify-center">
                    <Image src={src} alt="" width={600} height={600} className="w-full max-w-sm drop-shadow-2xl" />
                  </div>
                ))}
                {structure.lifeImages[2] && (
                  <div className="flex items-center justify-center">
                    <Image src={structure.lifeImages[2]} alt="" width={1200} height={912} className="w-full max-w-sm drop-shadow-2xl" />
                  </div>
                )}
                {structure.lifeImages[3] && (
                  <div className="flex items-center justify-center">
                    <Image src={structure.lifeImages[3]} alt="" width={600} height={600} className="w-full max-w-xs drop-shadow-2xl" />
                  </div>
                )}
              </div>
            </section>
          )}

          {/* キャラクターイラスト（動画がある場合） */}
          {structure.characterSlug && character && structure.featuredVideo && (
            <div className="mb-8 flex justify-center">
              <div className="relative w-full max-w-xl">
                <Image src="/paper.png" alt="" width={900} height={1200} className="w-full drop-shadow-2xl" />
                <div className="absolute inset-0 flex items-center justify-center p-10 pt-14 pb-20">
                  <Image
                    src={character.images[0].src}
                    alt={character.images[0].alt}
                    width={700}
                    height={700}
                    className="w-full h-full object-contain"
                    style={{
                      mixBlendMode: 'multiply',
                      WebkitMaskImage: 'radial-gradient(ellipse 72% 72% at 50% 50%, black 30%, transparent 100%)',
                      maskImage: 'radial-gradient(ellipse 72% 72% at 50% 50%, black 30%, transparent 100%)',
                    }}
                  />
                </div>
                <div className="absolute" style={{ bottom: '14%', right: '14%', width: '100px' }}>
                  <Image
                    src="/stamp.png"
                    alt=""
                    width={200}
                    height={200}
                    className="w-full"
                    style={{ mixBlendMode: 'multiply', opacity: 0.8, transform: 'rotate(-8deg)' }}
                  />
                </div>
              </div>
            </div>
          )}

          {/* 装飾イラスト */}
          {structure.decorativeImage && (
            <div className="flex justify-center my-4">
              <Image
                src={structure.decorativeImage}
                alt=""
                width={420}
                height={467}
                className="w-48 md:w-64 animate-float drop-shadow-2xl"
                style={{ animationDuration: '7s' }}
              />
            </div>
          )}

          {/* メッセージ */}
          {areaT.message && (
            <section className="bg-deep-night-100/50 backdrop-blur-sm border border-luminous-blue-500/20 rounded-lg p-8 md:p-12 mb-8">
              <p className="text-lg md:text-xl text-luminous-blue-100/90 leading-relaxed italic">
                {areaT.message}
              </p>
              <p className="text-right text-luminous-blue-300 mt-4">
                {t.areaPage.messageAuthor}
              </p>
            </section>
          )}

          {/* 戻るリンク */}
          <div className="text-center mt-12">
            <Link
              href="/"
              className="inline-flex items-center text-luminous-blue-300 hover:text-luminous-blue-200 transition-colors"
            >
              <span className="mr-2">←</span>
              {t.backToTop}
            </Link>
          </div>
        </div>
      </div>
    </main>
  );
}
