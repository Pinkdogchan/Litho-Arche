'use client';

import Image from 'next/image';
import type { Character } from '../lib/characters';
import CreatureCard from './CreatureCard';
import { useLanguage } from '../context/LanguageContext';
import { useTranslations } from '../i18n';

function SectionTitle({ children }: { children: React.ReactNode }) {
  return (
    <div className="relative flex items-center justify-center mb-8">
      <Image
        src="/title-frame.png"
        alt=""
        width={600}
        height={120}
        className="w-full max-w-lg"
        style={{ filter: 'invert(1) sepia(1) saturate(2) hue-rotate(190deg) brightness(1.2)', opacity: 0.85 }}
      />
      <h2 className="absolute text-xl font-semibold text-luminous-blue-100 tracking-widest" style={{ fontFamily: "'Kaisei HarunoUmi', cursive" }}>
        {children}
      </h2>
    </div>
  );
}

export default function CharacterProfile({ character, featuredVideo }: { character: Character; featuredVideo?: string }) {
  const { lang } = useLanguage();
  const cp = useTranslations(lang).characterProfile;

  return (
    <div className="space-y-8">

      {/* メインイラスト */}
      <div className="relative flex justify-center">
        <div className="relative w-full max-w-xl">
          <Image src="/paper.png" alt="" width={900} height={1200} className="w-full drop-shadow-2xl" />
          <div className="absolute inset-0 flex items-center justify-center p-10 pt-14 pb-20">
            {featuredVideo ? (
              <video
                src={featuredVideo}
                autoPlay
                muted
                playsInline
                loop
                className="w-full h-full object-contain"
                style={{
                  mixBlendMode: 'multiply',
                  WebkitMaskImage: 'radial-gradient(ellipse 72% 72% at 50% 50%, black 30%, transparent 100%)',
                  maskImage: 'radial-gradient(ellipse 72% 72% at 50% 50%, black 30%, transparent 100%)',
                }}
              />
            ) : (
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
            )}
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

      {/* ステートメント */}
      {character.statement && (
        <section className="bg-deep-night-100/50 backdrop-blur-sm border border-luminous-blue-500/20 rounded-lg p-8 md:p-12 glow-soft">
          <p className="text-lg md:text-xl text-luminous-blue-100/90 leading-relaxed italic text-center" style={{ fontFamily: "'Caveat', cursive" }}>
            {character.statement}
          </p>
        </section>
      )}

      {/* 観測記録 */}
      <section className="bg-deep-night-100/30 backdrop-blur-sm border border-luminous-blue-400/10 rounded-lg p-8 md:p-12">
        <SectionTitle>{cp.observationTitle}</SectionTitle>
        <div className="space-y-6">
          {character.profile.map((item, i) => (
            <div key={i} className="border-l-2 border-luminous-blue-500/30 pl-6">
              <p className="text-sm text-luminous-blue-300/80 mb-1 tracking-widest">{item.label}</p>
              <p className="text-luminous-blue-100/90 leading-relaxed">{item.text}</p>
            </div>
          ))}
          {character.personality.map((text, i) => (
            <div key={`p-${i}`} className="border-l-2 border-luminous-blue-500/30 pl-6">
              <p className="text-luminous-blue-100/90 leading-relaxed">{text}</p>
            </div>
          ))}
          {character.weakness && (
            <div className="border-l-2 border-luminous-blue-500/30 pl-6">
              <p className="text-sm text-luminous-blue-300/80 mb-1 tracking-widest">{cp.offLogLabel}</p>
              <p className="text-luminous-blue-100/90 leading-relaxed">{character.weakness}</p>
            </div>
          )}
        </div>
      </section>

      {/* 所持品・道具 */}
      {character.equipment && (
        <section className="bg-deep-night-100/30 backdrop-blur-sm border border-luminous-blue-400/10 rounded-lg p-8 md:p-12">
          <SectionTitle>{cp.equipmentTitle}</SectionTitle>
          {character.equipmentImage && (
            <div className="flex justify-center mb-8">
              <Image
                src={character.equipmentImage}
                alt=""
                width={420}
                height={467}
                className="w-48 md:w-64 drop-shadow-2xl animate-float"
                style={{ animationDuration: '7s' }}
              />
            </div>
          )}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {character.equipment.map((item, i) => (
              <div key={i} className="bg-deep-night-100/40 border border-luminous-blue-500/20 rounded-lg p-6">
                <h3 className="text-lg font-semibold text-luminous-blue-200 mb-2" style={{ fontFamily: "'Kaisei HarunoUmi', cursive" }}>{item.name}</h3>
                <p className="text-luminous-blue-100/80 text-sm leading-relaxed">{item.description}</p>
              </div>
            ))}
          </div>
        </section>
      )}

      {/* 観測者の解剖図 */}
      {character.anatomyImages && character.anatomyImages.length > 0 && (
        <section className="bg-deep-night-100/30 backdrop-blur-sm border border-luminous-blue-400/10 rounded-lg p-8 md:p-12">
          <SectionTitle>{cp.anatomyTitle}</SectionTitle>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {character.anatomyImages.map((item, i) => (
              <CreatureCard
                key={i}
                group={{ image: item.image, items: [{ name: item.name, nameEn: item.nameEn, description: item.description }] }}
              />
            ))}
          </div>
        </section>
      )}

      {/* 言葉 */}
      {character.quote && (
        <section className="bg-deep-night-100/50 backdrop-blur-sm border border-luminous-blue-500/20 rounded-lg p-8 md:p-12 glow-soft text-center">
          <p className="text-xl md:text-2xl text-luminous-blue-100/90 italic" style={{ fontFamily: "'Caveat', cursive" }}>
            {character.quote}
          </p>
          <p className="text-luminous-blue-300 mt-4">— {character.name}</p>
        </section>
      )}

    </div>
  );
}
