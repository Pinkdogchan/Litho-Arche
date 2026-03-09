import type { Language, UITranslations, AreaTranslations } from './types';
import { ja } from './ja';
import { en } from './en';
import { zhTW } from './zh-TW';
import { zhCN } from './zh-CN';
import { jaAreas } from './areas/ja';
import { enAreas } from './areas/en';
import { zhTWAreas } from './areas/zh-TW';
import { zhCNAreas } from './areas/zh-CN';

const uiTranslations: Record<Language, UITranslations> = { ja, en, 'zh-TW': zhTW, 'zh-CN': zhCN };
const areaTranslations: Record<Language, AreaTranslations> = {
  ja: jaAreas,
  en: enAreas,
  'zh-TW': zhTWAreas,
  'zh-CN': zhCNAreas,
};

export function useTranslations(lang: Language): UITranslations {
  return uiTranslations[lang] ?? ja;
}

export function useAreaTranslations(lang: Language): AreaTranslations {
  return areaTranslations[lang] ?? jaAreas;
}
