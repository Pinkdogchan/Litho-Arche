'use client';

import Image from 'next/image';
import Link from 'next/link';
import CoverLink from './components/CoverLink';
import StarsBackground from './components/StarsBackground';
import { useLanguage } from './context/LanguageContext';
import { useTranslations, useAreaTranslations } from './i18n';

export default function Home() {
  const { lang } = useLanguage();
  const t = useTranslations(lang);
  const areaT = useAreaTranslations(lang);

  return (
    <main className="min-h-screen bg-gradient-to-b from-deep-night-200 via-deep-night-100 to-deep-night-200 relative overflow-hidden">
      {/* 星空の背景エフェクト */}
      <StarsBackground count={50} />

      {/* 大きな天体 */}
      <div className="fixed inset-0 overflow-hidden pointer-events-none z-0">
        <div className="absolute" style={{ left: '-10%', top: '10%', width: '400px', height: '400px', background: 'radial-gradient(circle, rgba(0, 121, 230, 0.15) 0%, rgba(0, 121, 230, 0.05) 50%, transparent 100%)', borderRadius: '50%', filter: 'blur(40px)', animation: 'glow-pulse 8s ease-in-out infinite' }} />
        <div className="absolute" style={{ left: '-5%', top: '15%', width: '300px', height: '300px', background: 'radial-gradient(circle, rgba(100, 150, 255, 0.2) 0%, rgba(100, 150, 255, 0.1) 40%, transparent 70%)', borderRadius: '50%', filter: 'blur(30px)', animation: 'glow-pulse 10s ease-in-out infinite', animationDelay: '2s' }} />
        <div className="absolute" style={{ right: '-8%', top: '20%', width: '500px', height: '500px', background: 'radial-gradient(ellipse, rgba(80, 120, 200, 0.12) 0%, rgba(60, 100, 180, 0.08) 40%, transparent 70%)', borderRadius: '50%', filter: 'blur(50px)', transform: 'rotate(45deg)', animation: 'glow-pulse 12s ease-in-out infinite', animationDelay: '4s' }} />
        <div className="absolute" style={{ left: '50%', top: '-15%', transform: 'translateX(-50%)', width: '600px', height: '600px', background: 'radial-gradient(circle, rgba(0, 121, 230, 0.1) 0%, rgba(0, 121, 230, 0.05) 30%, transparent 60%)', borderRadius: '50%', filter: 'blur(60px)', animation: 'glow-pulse 15s ease-in-out infinite', animationDelay: '1s' }} />
        <div className="absolute" style={{ left: '50%', top: '-10%', transform: 'translateX(-50%)', width: '400px', height: '400px', background: 'radial-gradient(circle, rgba(150, 200, 255, 0.15) 0%, rgba(150, 200, 255, 0.08) 50%, transparent 80%)', borderRadius: '50%', filter: 'blur(40px)', animation: 'glow-pulse 18s ease-in-out infinite', animationDelay: '3s' }} />
        <div className="absolute" style={{ right: '-12%', bottom: '15%', width: '450px', height: '450px', background: 'radial-gradient(circle, rgba(120, 160, 220, 0.12) 0%, rgba(100, 140, 200, 0.06) 50%, transparent 80%)', borderRadius: '50%', filter: 'blur(45px)', animation: 'glow-pulse 14s ease-in-out infinite', animationDelay: '5s' }} />
        <div className="absolute" style={{ left: '-5%', bottom: '10%', width: '350px', height: '350px', background: 'radial-gradient(ellipse, rgba(90, 130, 190, 0.1) 0%, rgba(70, 110, 170, 0.05) 50%, transparent 75%)', borderRadius: '50%', filter: 'blur(35px)', transform: 'rotate(-30deg)', animation: 'glow-pulse 16s ease-in-out infinite', animationDelay: '6s' }} />
        <div className="absolute" style={{ left: '50%', bottom: '-10%', transform: 'translateX(-50%)', width: '550px', height: '550px', background: 'radial-gradient(circle, rgba(0, 121, 230, 0.08) 0%, rgba(0, 121, 230, 0.04) 40%, transparent 70%)', borderRadius: '50%', filter: 'blur(55px)', animation: 'glow-pulse 20s ease-in-out infinite', animationDelay: '7s' }} />
      </div>

      {/* 浮遊する本と紙 */}
      <div className="fixed inset-0 overflow-hidden pointer-events-none z-0">
        <div className="absolute" style={{ left: '50%', top: '50%', width: '1px', height: '1px', transform: 'translate(-50%, -50%)' }}>
          <div className="absolute" style={{ width: '140px', height: '185px', animation: 'spiral-orbit-book1 25s linear infinite', animationDelay: '-5s' }}>
            <div style={{ width: '100%', height: '100%', perspective: '400px', transform: 'rotateZ(12deg) rotateX(18deg) rotateY(-15deg)' }}>
              <Image src="/float-book.jpg" alt="" width={280} height={370} className="w-full h-full object-contain" style={{ opacity: 0.6, mixBlendMode: 'screen', maskImage: 'radial-gradient(ellipse 78% 78% at 50% 50%, black 40%, transparent 100%)', WebkitMaskImage: 'radial-gradient(ellipse 78% 78% at 50% 50%, black 40%, transparent 100%)' }} />
            </div>
          </div>
          <div className="absolute" style={{ width: '120px', height: '160px', animation: 'spiral-orbit-book2 28s linear infinite', animationDelay: '-11s' }}>
            <div style={{ width: '100%', height: '100%', perspective: '400px', transform: 'rotateZ(-20deg) rotateX(-15deg) rotateY(22deg)' }}>
              <Image src="/float-book.jpg" alt="" width={240} height={320} className="w-full h-full object-contain" style={{ opacity: 0.55, mixBlendMode: 'screen', maskImage: 'radial-gradient(ellipse 78% 78% at 50% 50%, black 40%, transparent 100%)', WebkitMaskImage: 'radial-gradient(ellipse 78% 78% at 50% 50%, black 40%, transparent 100%)' }} />
            </div>
          </div>
          <div className="absolute" style={{ width: '130px', height: '172px', animation: 'spiral-orbit-book3 30s linear infinite', animationDelay: '-20s' }}>
            <div style={{ width: '100%', height: '100%', perspective: '400px', transform: 'rotateZ(5deg) rotateX(28deg) rotateY(10deg)' }}>
              <Image src="/float-book.jpg" alt="" width={260} height={345} className="w-full h-full object-contain" style={{ opacity: 0.55, mixBlendMode: 'screen', maskImage: 'radial-gradient(ellipse 78% 78% at 50% 50%, black 40%, transparent 100%)', WebkitMaskImage: 'radial-gradient(ellipse 78% 78% at 50% 50%, black 40%, transparent 100%)' }} />
            </div>
          </div>
          <div className="absolute" style={{ width: '115px', height: '152px', animation: 'spiral-orbit-book4 27s linear infinite', animationDelay: '-7s' }}>
            <div style={{ width: '100%', height: '100%', perspective: '400px', transform: 'rotateZ(-8deg) rotateX(-22deg) rotateY(-18deg)' }}>
              <Image src="/float-book.jpg" alt="" width={230} height={305} className="w-full h-full object-contain" style={{ opacity: 0.6, mixBlendMode: 'screen', maskImage: 'radial-gradient(ellipse 78% 78% at 50% 50%, black 40%, transparent 100%)', WebkitMaskImage: 'radial-gradient(ellipse 78% 78% at 50% 50%, black 40%, transparent 100%)' }} />
            </div>
          </div>
          <div className="absolute" style={{ width: '125px', height: '165px', animation: 'spiral-orbit-book5 26s linear infinite', animationDelay: '-16s' }}>
            <div style={{ width: '100%', height: '100%', perspective: '400px', transform: 'rotateZ(24deg) rotateX(12deg) rotateY(-25deg)' }}>
              <Image src="/float-book.jpg" alt="" width={250} height={330} className="w-full h-full object-contain" style={{ opacity: 0.55, mixBlendMode: 'screen', maskImage: 'radial-gradient(ellipse 78% 78% at 50% 50%, black 40%, transparent 100%)', WebkitMaskImage: 'radial-gradient(ellipse 78% 78% at 50% 50%, black 40%, transparent 100%)' }} />
            </div>
          </div>
          <div className="absolute" style={{ width: '180px', height: '240px', animation: 'spiral-orbit-paper1 22s linear infinite', animationDelay: '-4s' }}>
            <div style={{ width: '100%', height: '100%', perspective: '400px', transform: 'rotateZ(18deg) rotateX(22deg) rotateY(-14deg)' }}>
              <Image src="/float-page-1.png" alt="" width={360} height={480} className="w-full h-full object-contain" style={{ opacity: 0.7, mixBlendMode: 'screen', maskImage: 'radial-gradient(ellipse 78% 78% at 50% 50%, black 40%, transparent 100%)', WebkitMaskImage: 'radial-gradient(ellipse 78% 78% at 50% 50%, black 40%, transparent 100%)' }} />
            </div>
          </div>
          <div className="absolute" style={{ width: '150px', height: '200px', animation: 'spiral-orbit-paper3 20s linear infinite', animationDelay: '-14s' }}>
            <div style={{ width: '100%', height: '100%', perspective: '400px', transform: 'rotateZ(8deg) rotateX(30deg) rotateY(12deg)' }}>
              <Image src="/float-page-3.png" alt="" width={300} height={400} className="w-full h-full object-contain" style={{ opacity: 0.65, mixBlendMode: 'screen', maskImage: 'radial-gradient(ellipse 78% 78% at 50% 50%, black 40%, transparent 100%)', WebkitMaskImage: 'radial-gradient(ellipse 78% 78% at 50% 50%, black 40%, transparent 100%)' }} />
            </div>
          </div>
          <div className="absolute" style={{ width: '155px', height: '205px', animation: 'spiral-orbit-paper4 23s linear infinite', animationDelay: '-3s' }}>
            <div style={{ width: '100%', height: '100%', perspective: '400px', transform: 'rotateZ(-14deg) rotateX(-25deg) rotateY(-18deg)' }}>
              <Image src="/float-page-4.jpg" alt="" width={310} height={410} className="w-full h-full object-contain" style={{ opacity: 0.65, mixBlendMode: 'screen', maskImage: 'radial-gradient(ellipse 78% 78% at 50% 50%, black 40%, transparent 100%)', WebkitMaskImage: 'radial-gradient(ellipse 78% 78% at 50% 50%, black 40%, transparent 100%)' }} />
            </div>
          </div>
          <div className="absolute" style={{ width: '165px', height: '220px', animation: 'spiral-orbit-paper1 26s linear infinite', animationDelay: '-19s' }}>
            <div style={{ width: '100%', height: '100%', perspective: '400px', transform: 'rotateZ(28deg) rotateX(15deg) rotateY(-22deg)' }}>
              <Image src="/float-page-5.jpg" alt="" width={330} height={440} className="w-full h-full object-contain" style={{ opacity: 0.65, mixBlendMode: 'screen', maskImage: 'radial-gradient(ellipse 78% 78% at 50% 50%, black 40%, transparent 100%)', WebkitMaskImage: 'radial-gradient(ellipse 78% 78% at 50% 50%, black 40%, transparent 100%)' }} />
            </div>
          </div>
          <div className="absolute" style={{ width: '170px', height: '225px', animation: 'spiral-orbit-paper2 28s linear infinite', animationDelay: '-10s' }}>
            <div style={{ width: '100%', height: '100%', perspective: '400px', transform: 'rotateZ(-10deg) rotateX(20deg) rotateY(25deg)' }}>
              <Image src="/float-page-6.jpg" alt="" width={340} height={450} className="w-full h-full object-contain" style={{ opacity: 0.65, mixBlendMode: 'screen', maskImage: 'radial-gradient(ellipse 78% 78% at 50% 50%, black 40%, transparent 100%)', WebkitMaskImage: 'radial-gradient(ellipse 78% 78% at 50% 50%, black 40%, transparent 100%)' }} />
            </div>
          </div>
          <div className="absolute" style={{ width: '155px', height: '210px', animation: 'spiral-orbit-paper3 25s linear infinite', animationDelay: '-18s' }}>
            <div style={{ width: '100%', height: '100%', perspective: '400px', transform: 'rotateZ(16deg) rotateX(-20deg) rotateY(-8deg)' }}>
              <Image src="/float-page-7.jpg" alt="" width={310} height={420} className="w-full h-full object-contain" style={{ opacity: 0.65, mixBlendMode: 'screen', maskImage: 'radial-gradient(ellipse 78% 78% at 50% 50%, black 40%, transparent 100%)', WebkitMaskImage: 'radial-gradient(ellipse 78% 78% at 50% 50%, black 40%, transparent 100%)' }} />
            </div>
          </div>
          <div className="absolute" style={{ width: '160px', height: '215px', animation: 'spiral-orbit-paper4 27s linear infinite', animationDelay: '-6s' }}>
            <div style={{ width: '100%', height: '100%', perspective: '400px', transform: 'rotateZ(-26deg) rotateX(12deg) rotateY(18deg)' }}>
              <Image src="/float-page-8.jpg" alt="" width={320} height={430} className="w-full h-full object-contain" style={{ opacity: 0.65, mixBlendMode: 'screen', maskImage: 'radial-gradient(ellipse 78% 78% at 50% 50%, black 40%, transparent 100%)', WebkitMaskImage: 'radial-gradient(ellipse 78% 78% at 50% 50%, black 40%, transparent 100%)' }} />
            </div>
          </div>
        </div>
      </div>

      {/* メインコンテンツ */}
      <div className="relative z-10 flex flex-col items-center justify-center min-h-screen px-4 py-16">
        {/* タイトルセクション */}
        <div className="text-center mb-16 animate-float">
          <CoverLink />
        </div>

        <div className="max-w-4xl mx-auto space-y-12">
          {/* 博物誌の目的 */}
          <section className="rounded-lg p-8 md:p-12 relative overflow-hidden paper-fade-edges" style={{ backgroundImage: "url('/paper-horizontal.jpg')", backgroundSize: 'cover', backgroundPosition: 'center' }}>
            <h3 className="text-2xl md:text-3xl font-semibold mb-6" style={{ fontFamily: "'Kaisei HarunoUmi', cursive", color: '#1a1a2e' }}>
              {t.topPage.purposeTitle}
            </h3>
            <div className="space-y-4 leading-relaxed relative z-10" style={{ color: '#2d2d4e' }}>
              <p>{t.topPage.purposeBody1}</p>
              <p>{t.topPage.purposeBody2}</p>
            </div>
          </section>

          {/* エリアへの導線 */}
          <section className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-12">
            {(
              [
                'stella-library',
                'crystal-vein-echo',
                'lunar-moss-forest',
                'bios-nebula',
                'celestial-bright-shore',
              ] as const
            ).map((slug) => (
              <Link
                key={slug}
                href={`/areas/${slug}`}
                className="rounded-lg p-6 hover:opacity-80 transition-all cursor-pointer block overflow-hidden paper-fade-edges"
                style={{ backgroundImage: "url('/paper-horizontal.jpg')", backgroundSize: 'cover', backgroundPosition: 'center' }}
              >
                <h4 className="text-xl font-semibold mb-3" style={{ fontFamily: "'Kaisei HarunoUmi', cursive", color: '#1a1a2e' }}>
                  {areaT[slug]?.title ?? slug}
                </h4>
                <p className="text-sm" style={{ fontFamily: "'Caveat', cursive", color: '#3a3a5e' }}>
                  {slug === 'stella-library' && 'Stella-Library "Void"'}
                  {slug === 'crystal-vein-echo' && 'Crystal-Vein Echo'}
                  {slug === 'lunar-moss-forest' && 'Lunar-Moss Forest'}
                  {slug === 'bios-nebula' && 'Bios-Nebula'}
                  {slug === 'celestial-bright-shore' && 'Celestial Bright Shore'}
                </p>
              </Link>
            ))}
          </section>
        </div>

        {/* フッター */}
        <footer className="mt-24 text-center text-luminous-blue-100/60 text-sm" style={{ fontFamily: "'Zen Kurenaido', cursive" }}>
          <p>{t.footer.archiveName}</p>
          <p className="mt-2">{t.footer.copyright}</p>
          <p className="mt-3 space-x-6">
            <a href="https://litho-arche.booth.pm/" target="_blank" rel="noopener noreferrer" className="text-luminous-blue-300/60 hover:text-luminous-blue-300 transition-colors tracking-widest">
              {t.footer.boothShop}
            </a>
            <Link href="/guidelines" className="text-luminous-blue-300/60 hover:text-luminous-blue-300 transition-colors tracking-widest">
              {t.footer.fanGuidelines}
            </Link>
          </p>
        </footer>
      </div>
    </main>
  );
}
