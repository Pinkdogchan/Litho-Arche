export type Language = 'ja' | 'en' | 'zh-TW' | 'zh-CN';

export type UITranslations = {
  backToTop: string;

  topPage: {
    purposeTitle: string;
    purposeBody1: string;
    purposeBody2: string;
  };

  areaPage: {
    landscapeTitle: string;
    archiveTitle: string;
    creaturesTitle: string;
    observerJournalTitle: string;
    defaultIllustrationsTitle: string;
    messageAuthor: string;
  };

  characterProfile: {
    observationTitle: string;
    offLogLabel: string;
    equipmentTitle: string;
    anatomyTitle: string;
  };

  coverLink: {
    heading: string;
    message1: string;
    message2: string;
    quote: string;
    quoteAuthor: string;
    open: string;
    close: string;
  };

  creatureCard: {
    tapHint: string;
  };

  guidelines: {
    title: string;
    subtitle: string;
    intro1: string;
    intro2: string;
    permittedTitle: string;
    permitted: string[];
    prohibitedTitle: string;
    prohibited: Array<{ title: string; body: string }>;
    creditTitle: string;
    creditName: string;
    creditBody: string;
    contactTitle: string;
    contactBody: string;
    contactNote: string;
    lastUpdated: string;
  };

  footer: {
    archiveName: string;
    copyright: string;
    boothShop: string;
    fanGuidelines: string;
  };
};

export type AreaTranslation = {
  title: string;
  description: string;
  landscape: string[];
  worldView: string;
  message?: string;
  illustrationsTitle?: string;
  creatures?: Array<{
    name: string;
    description: string;
  }>;
  illustrations?: Array<{
    name: string;
    description: string;
  }>;
};

export type AreaTranslations = Record<string, AreaTranslation>;

/** Non-translatable structural data that stays in page.tsx */
export type AreaStructure = {
  titleEn: string;
  image: string;
  showImage?: boolean;
  extraImages?: string[];
  lifeImages?: string[];
  decorativeImage?: string;
  featuredVideo?: string;
  characterSlug?: string;
  creatures?: Array<{ nameEn: string; image?: string }>;
  illustrations?: Array<{ image: string; nameEn: string }>;
};
