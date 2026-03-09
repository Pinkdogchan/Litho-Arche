'use client';

import { useEffect } from 'react';
import { useLanguage } from '../context/LanguageContext';

export default function LangAttributeSync() {
  const { lang } = useLanguage();

  useEffect(() => {
    document.documentElement.lang = lang;
  }, [lang]);

  return null;
}
