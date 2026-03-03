'use client';

import { useRef } from 'react';

type Props = {
  src?: string;
  fadeEdges?: boolean;
  cropMargin?: string;
};

export default function RufenVideo({ src = '/rufen-appear.mp4', fadeEdges = false, cropMargin = '-12%' }: Props) {
  const videoRef = useRef<HTMLVideoElement>(null);

  const handleEnded = () => {
    const video = videoRef.current;
    if (!video) return;
    video.pause();
  };

  return (
    <div
      className={`w-full mx-auto overflow-hidden ${fadeEdges ? 'video-fade-edges' : 'rounded-lg'}`}
      style={!fadeEdges ? { boxShadow: '0 0 20px rgba(0, 121, 230, 0.3), 0 0 40px rgba(0, 121, 230, 0.2)' } : undefined}
    >
      <video
        ref={videoRef}
        src={src}
        autoPlay
        muted
        playsInline
        onEnded={handleEnded}
        className="w-full block"
        style={{ marginTop: cropMargin, marginBottom: cropMargin }}
      />
    </div>
  );
}
