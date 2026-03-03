'use client';

import Image from 'next/image';
import { useState } from 'react';

export default function CoverLink() {
  const [opened, setOpened] = useState(false);

  const coverTransform = opened ? 'rotateY(-160deg)' : 'rotateY(-10deg)';

  return (
    <div className="block text-center select-none">
      {/* 本体 — クリック不要、視覚のみ */}
      <div
        className="inline-block relative mx-auto"
        style={{ perspective: '1400px', perspectiveOrigin: '40% 50%' }}
      >
        {/* 右ページ — openedのときだけDOMに存在させる */}
        {opened && (
          <div
            className="absolute top-0 rounded-r-lg overflow-hidden"
            style={{
              left: 0,
              width: '100%',
              height: '100%',
              zIndex: 0,
              animation: 'bookPageReveal 0.4s ease 0.5s both',
            }}
          >
            <Image
              src="/float-book.jpg"
              alt=""
              width={900}
              height={1200}
              className="w-full h-full object-cover"
            />
            <div
              style={{
                position: 'absolute',
                inset: 0,
                background: 'linear-gradient(160deg, rgba(10, 15, 35, 0.82) 0%, rgba(8, 12, 28, 0.88) 100%)',
                display: 'flex',
                flexDirection: 'column',
                padding: '8% 8%',
                boxSizing: 'border-box',
              }}
            >
              <div style={{ position: 'absolute', inset: '4%', border: '1px solid rgba(0, 121, 230, 0.25)', borderRadius: '2px', pointerEvents: 'none' }} />
              <div style={{ position: 'relative', zIndex: 1, display: 'flex', flexDirection: 'column', height: '100%', gap: '4%' }}>
                <div style={{ flexShrink: 0, width: '80%', margin: '0 auto', overflow: 'hidden', borderRadius: '4px' }}>
                  <video
                    src="/rufen-appear.mp4"
                    autoPlay
                    muted
                    playsInline
                    onEnded={(e) => (e.currentTarget as HTMLVideoElement).pause()}
                    className="w-full block"
                    style={{ marginTop: '-18%', marginBottom: '-18%' }}
                  />
                </div>
                <h2 style={{ fontFamily: "'Kaisei HarunoUmi', cursive", fontSize: '1rem', color: '#80c1ff', textAlign: 'center', margin: 0, marginTop: 'auto', flexShrink: 0, letterSpacing: '0.05em' }}>
                  記録官ルーフェンからの伝言
                </h2>
                <div style={{ fontSize: '0.75rem', color: 'rgba(179, 217, 255, 0.9)', lineHeight: 1.75, fontFamily: "'Kalam', cursive", overflow: 'hidden' }}>
                  <p style={{ margin: '0 0 4%' }}>深い霧の底、地殻の裂け目に沿って広がる世界へようこそ。</p>
                  <p style={{ margin: '0 0 4%' }}>ここは、世界中の「まだ言葉にならない想い」や「忘れかけられた夢」を収集し、美しく分類・記録する図譜「Litho-Arche 博物誌」の観測所です。</p>
                  <p style={{ margin: '0 0 4%', fontStyle: 'italic', fontFamily: "'Caveat', cursive", fontSize: '1.05em', color: 'rgba(179, 217, 255, 0.85)' }}>
                    「記録されなければ、それは最初から無かったことになる。
                    <br />
                    だから僕は、消えゆく記憶を最後の一滴まで記録し続ける。」
                  </p>
                  <p style={{ margin: 0, textAlign: 'right', color: '#4da9ff' }}>— 主席記録官 ルーフェン</p>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* ページの束（右側の厚み） */}
        <div
          className="absolute rounded-r-sm"
          style={{
            top: '6px',
            bottom: '6px',
            right: '-14px',
            width: '14px',
            background: `repeating-linear-gradient(
              to bottom,
              #f0ece4,
              #f0ece4 2px,
              #ddd8cc 2px,
              #ddd8cc 3px
            )`,
            boxShadow: '4px 2px 10px rgba(0,0,0,0.35)',
            opacity: opened ? 0 : 1,
            transition: 'opacity 0.3s ease',
          }}
        />

        {/* 表紙（3D回転） */}
        <div
          onClick={() => setOpened(prev => !prev)}
          style={{
            transformOrigin: 'left center',
            transform: coverTransform,
            transition: 'transform 1.0s cubic-bezier(0.4, 0, 0.2, 1)',
            transformStyle: 'preserve-3d',
            position: 'relative',
            zIndex: 1,
            cursor: 'pointer',
          }}
        >
          <div style={{ backfaceVisibility: 'hidden', WebkitBackfaceVisibility: 'hidden' }}>
            <div
              className="absolute left-0 top-0 bottom-0 z-10 rounded-l-lg pointer-events-none"
              style={{ width: '22px', background: 'linear-gradient(to right, rgba(0,10,40,0.55), transparent)' }}
            />
            <Image
              src="/cover.jpg"
              alt="Litho-Arche - A Chronicle of Vanishing Echoes"
              width={900}
              height={1200}
              className="w-full max-w-lg rounded-lg block"
              priority
              style={{ filter: 'drop-shadow(-8px 12px 30px rgba(0,0,0,0.6))' }}
            />
          </div>
          <div
            style={{
              position: 'absolute',
              inset: 0,
              backfaceVisibility: 'hidden',
              WebkitBackfaceVisibility: 'hidden',
              transform: 'rotateY(180deg)',
              borderRadius: '8px',
              overflow: 'hidden',
            }}
          >
            <Image
              src="/float-book.jpg"
              alt=""
              width={900}
              height={1200}
              className="w-full h-full object-cover"
            />
          </div>
        </div>
      </div>

      {/* 開く／閉じるボタン — 3Dツリー完全外側の <button> */}
      <button
        type="button"
        onClick={() => setOpened(prev => !prev)}
        className="group text-luminous-blue-300/50 text-sm mt-5 tracking-[0.3em] hover:text-luminous-blue-300/90 transition-colors duration-300 bg-transparent border-0 cursor-pointer"
        style={{ fontFamily: "'Caveat', cursive", display: 'block', width: '100%' }}
      >
        {opened ? '── 閉じる ──' : '── 開く ──'}
      </button>
    </div>
  );
}
