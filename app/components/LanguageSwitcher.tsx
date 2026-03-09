'use client';

import { useLanguage } from '../context/LanguageContext';
import type { Language } from '../i18n/types';

const LANGS: { code: Language; label: string }[] = [
  { code: 'ja', label: '日本語' },
  { code: 'en', label: 'EN' },
  { code: 'zh-TW', label: '繁體' },
  { code: 'zh-CN', label: '简体' },
];

export default function LanguageSwitcher() {
  const { lang, setLang } = useLanguage();

  return (
    <div
      className="fixed top-4 right-4 z-50 flex items-center rounded-md border border-luminous-blue-500/20 bg-deep-night-100/50 backdrop-blur-sm overflow-hidden"
      style={{ fontFamily: "'Zen Kurenaido', cursive" }}
    >
      {LANGS.map(({ code, label }) => (
        <button
          key={code}
          type="button"
          onClick={() => setLang(code)}
          className={[
            'px-3 py-1.5 text-xs tracking-widest transition-colors duration-200',
            lang === code
              ? 'bg-luminous-blue-500/40 border border-luminous-blue-400/50 text-luminous-blue-100'
              : 'text-luminous-blue-300/60 hover:text-luminous-blue-300/90',
          ].join(' ')}
        >
          {label}
        </button>
      ))}
    </div>
  );
}
