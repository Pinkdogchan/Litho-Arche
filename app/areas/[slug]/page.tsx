import { notFound } from 'next/navigation';
import AreaContent from './AreaContent';
import type { AreaStructure } from '../../i18n/types';

// 画像・nameEn・characterSlug など翻訳不要の構造データのみ保持
const areaStructures: Record<string, AreaStructure> = {
  'stella-library': {
    titleEn: 'Stella-Library "Void"',
    image: '/area-stella-library.jpg',
    showImage: true,
    lifeImages: ['/rufen-stroll.png', '/rufen-daydream.png', '/stella-caravan.png', '/rufen-wolf-play.png'],
    featuredVideo: '/dream-4.mp4',
    characterSlug: 'rufen',
  },
  'crystal-vein-echo': {
    titleEn: 'Crystal-Vein Echo',
    image: '/area-crystal-vein-echo.jpg',
    showImage: true,
    illustrations: [
      { image: '/crystal-art-fox-jacket.jpg', nameEn: 'Crystal Wanderer' },
      { image: '/crystal-art-howling.jpg', nameEn: 'The Great Release' },
      { image: '/crystal-art-rufen.jpg', nameEn: 'Crystal Dialogue' },
      { image: '/crystal-art-wolf-light-1.jpg', nameEn: 'Longing for Light I' },
      { image: '/crystal-art-wolf-light-2.jpg', nameEn: 'Longing for Light II' },
      { image: '/crystal-art-sprint.jpg', nameEn: 'Sapphire Sprint' },
    ],
  },
  'lunar-moss-forest': {
    titleEn: 'Lunar-Moss Forest',
    image: '/area-lunar-moss-forest.jpg',
    showImage: true,
    creatures: [
      { nameEn: 'Stellar Ocellus', image: '/creature-stellar-cobalt.jpg' },
      { nameEn: 'Cobalt Humming', image: '/creature-stellar-cobalt.jpg' },
      { nameEn: 'Amber Fairy', image: '/creature-amber-bunny.jpg' },
      { nameEn: 'Bunny Moth', image: '/creature-amber-bunny.jpg' },
      { nameEn: 'Bomi-Sphinx', image: '/creature-bomi-sphinx.jpg' },
      { nameEn: 'Lunar Fluffy-Moth' },
    ],
  },
  'bios-nebula': {
    titleEn: 'Bios-Nebula',
    image: '/area-bios-nebula.jpg',
    showImage: true,
    illustrations: [
      { image: '/nebula-sketch-fursuit.jpg', nameEn: 'Studies of the Vessel' },
      { image: '/nebula-sketch-rabbit.jpg', nameEn: 'Faces Without Names' },
      { image: '/nebula-sketch-sprout.jpg', nameEn: 'Creatures Almost Born' },
      { image: '/nebula-sketch-coffee.jpg', nameEn: 'Studies of Form and Motion' },
      { image: '/nebula-sketch-dark.jpg', nameEn: 'Blue in the Dark' },
      { image: '/nebula-sketch-orca.jpg', nameEn: 'Dwellers of the Deep' },
    ],
  },
  'ember-core-hearth': {
    titleEn: 'Ember-Core Hearth',
    image: '/area-ember-core-hearth.png',
  },
  'solar-resonance-crater': {
    titleEn: 'Solar-Resonance Crater',
    image: '/area-solar-resonance-crater.png',
  },
  'celestial-bright-shore': {
    titleEn: 'Celestial Bright Shore',
    image: '/area-celestial-bright-shore.jpg',
    showImage: true,
    extraImages: ['/area-celestial-bright-shore-2.jpg'],
  },
  'twilight-glow-reef': {
    titleEn: 'Twilight-Glow Reef',
    image: '/area-twilight-glow-reef.png',
  },
};

export async function generateStaticParams() {
  return Object.keys(areaStructures).map((slug) => ({ slug }));
}

export default function AreaPage({ params }: { params: { slug: string } }) {
  const structure = areaStructures[params.slug];
  if (!structure) notFound();
  return <AreaContent slug={params.slug} structure={structure} />;
}
