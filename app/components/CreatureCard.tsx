'use client';

import { useRef, useState } from 'react';
import Image from 'next/image';

type Creature = {
  name: string;
  nameEn: string;
  description: string;
  image?: string;
};

type Props = {
  group: {
    image?: string;
    items: Creature[];
  };
};

export default function CreatureCard({ group }: Props) {
  const [revealed, setRevealed] = useState(false);
  const isMouse = useRef(false);

  const handlePointerEnter = (e: React.PointerEvent) => {
    if (e.pointerType === 'mouse') {
      isMouse.current = true;
      setRevealed(true);
    }
  };

  const handlePointerLeave = (e: React.PointerEvent) => {
    if (e.pointerType === 'mouse') {
      isMouse.current = false;
      setRevealed(false);
    }
  };

  const handleClick = () => {
    if (!isMouse.current) {
      setRevealed(r => !r);
    }
  };

  // 画像なし生物は常時表示
  if (!group.image) {
    return (
      <div className="bg-deep-night-100/40 backdrop-blur-sm border border-luminous-blue-500/20 rounded-lg overflow-hidden p-6 space-y-5">
        {group.items.map((creature, ci) => (
          <div key={ci} className={ci > 0 ? 'pt-5 border-t border-luminous-blue-500/20' : ''}>
            <h3 className="text-xl font-semibold text-luminous-blue-200 mb-2" style={{ fontFamily: "'Kaisei HarunoUmi', cursive" }}>
              {creature.name}
            </h3>
            <p className="text-sm text-luminous-blue-100/70 mb-3" style={{ fontFamily: "'Caveat', cursive" }}>
              {creature.nameEn}
            </p>
            <p className="text-luminous-blue-100/90 text-sm leading-relaxed">
              {creature.description}
            </p>
          </div>
        ))}
      </div>
    );
  }

  return (
    <div
      className="relative bg-deep-night-100/40 backdrop-blur-sm border border-luminous-blue-500/20 rounded-lg overflow-hidden cursor-pointer select-none"
      onPointerEnter={handlePointerEnter}
      onPointerLeave={handlePointerLeave}
      onClick={handleClick}
    >
      {/* イラスト */}
      <Image
        src={group.image}
        alt={group.items[0].name}
        width={900}
        height={1200}
        className={`w-full transition-transform duration-700 ease-out ${revealed ? 'scale-105' : 'scale-100'}`}
      />

      {/* タッチ用ヒント（マウス非対応デバイスのみ表示） */}
      <div
        className={`touch-hint absolute bottom-0 left-0 right-0 flex justify-center pb-4 pointer-events-none transition-opacity duration-300 ${revealed ? 'opacity-0' : 'opacity-100'}`}
      >
        <span className="text-luminous-blue-200/60 text-xs tracking-widest">タップして記録を見る</span>
      </div>

      {/* オーバーレイ：ホバー or タップで浮かび上がる */}
      <div
        className={`absolute inset-0 flex flex-col justify-end transition-opacity duration-500 ${revealed ? 'opacity-100' : 'opacity-0'}`}
        style={{ background: 'linear-gradient(to top, rgba(10,14,25,0.97) 0%, rgba(15,20,30,0.85) 50%, transparent 100%)' }}
      >
        <div className={`p-6 space-y-5 transition-transform duration-500 ease-out ${revealed ? 'translate-y-0' : 'translate-y-6'}`}>
          {group.items.map((creature, ci) => (
            <div key={ci} className={ci > 0 ? 'pt-5 border-t border-luminous-blue-500/20' : ''}>
              <h3 className="text-xl font-semibold text-luminous-blue-200 mb-1" style={{ fontFamily: "'Kaisei HarunoUmi', cursive" }}>
                {creature.name}
              </h3>
              <p className="text-sm text-luminous-blue-300/70 mb-3" style={{ fontFamily: "'Caveat', cursive" }}>
                {creature.nameEn}
              </p>
              <p className="text-luminous-blue-100/90 text-sm leading-relaxed">
                {creature.description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
