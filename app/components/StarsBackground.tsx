'use client';

import { useState, useEffect } from 'react';

type Star = {
  left: string;
  top: string;
  width: string;
  height: string;
  delay: string;
  opacity: number;
};

export default function StarsBackground({ count = 50 }: { count?: number }) {
  const [stars, setStars] = useState<Star[]>([]);

  useEffect(() => {
    setStars(
      Array.from({ length: count }).map(() => ({
        left: `${Math.random() * 100}%`,
        top: `${Math.random() * 100}%`,
        width: `${Math.random() * 3 + 1}px`,
        height: `${Math.random() * 3 + 1}px`,
        delay: `${Math.random() * 2}s`,
        opacity: Math.random() * 0.5 + 0.3,
      }))
    );
  }, [count]);

  if (stars.length === 0) return null;

  return (
    <div className="fixed inset-0 overflow-hidden pointer-events-none">
      {stars.map((s, i) => (
        <div
          key={i}
          className="absolute rounded-full bg-luminous-blue-300 animate-sparkle"
          style={{
            left: s.left,
            top: s.top,
            width: s.width,
            height: s.height,
            animationDelay: s.delay,
            opacity: s.opacity,
          }}
        />
      ))}
    </div>
  );
}
