export type Character = {
  name: string;
  nameEn: string;
  title: string;
  images: { src: string; alt: string }[];
  statement?: string;
  profile: { label: string; text: string }[];
  personality: string[];
  weakness?: string;
  equipment?: { name: string; description: string }[];
  equipmentImage?: string;
  anatomyImages?: Array<{
    image: string;
    name: string;
    nameEn: string;
    description: string;
  }>;
  quote?: string;
};

export const characters: Record<string, Character> = {
  rufen: {
    name: 'ルーフェン',
    nameEn: 'Rufen',
    title: 'ステラ・アーカイブ 主席記録官',
    images: [
      { src: '/rufen-main.png', alt: 'ルーフェン' },
      { src: '/rufen-stars.png', alt: '星空のルーフェン' },
      { src: '/rufen-dream.png', alt: '妄想するルーフェン' },
    ],
    statement: '「僕の姿が一つではないのは、魂が昨日までの僕ではない証。言葉で語り尽くせない想いは、この心が形にした『器』に込める。それは誰かに決められた色ではなく、心の奥底にいる小さな自分がその時に望む姿で、僕はこの世界の美しさを、最後の一滴まで記録し続ける。」',
    profile: [
      {
        label: '役割',
        text: '世界中の「まだ言葉にならない想い」や「忘れかけられた夢」を収集し、美しく分類・記録する主席記録官。',
      },
      {
        label: '本質',
        text: '固定された実体を持たない「流動する自我」の体現者。蛇が脱皮するように古い自分を脱ぎ捨て、新たな姿へと再生を繰り返す。',
      },
      {
        label: 'マント',
        text: '内側が銀河のように広がる宇宙空間のマント。脱ぎ捨てた過去の自分（皮）を編み込んで作られており、ここから「仲間たち」が飛び出して記録作業を支える。',
      },
    ],
    personality: [
      '本来は冷静な記録官であるべき存在だが、「温度のあるデータ」——泣いている夢、消えかけの願い、誰にも届かなかった優しさ——に触れると、胸の奥がきゅっとして規定外の保管をしてしまう。',
      'ステラ・アーカイブ的には軽い規則違反の常習犯。本人は悪気ゼロ。',
      '自分を責めている人の夢、まだ言葉にならない孤独、「大丈夫」と言いながら壊れかけている想い——そういうものに、特に弱い。',
    ],
    weakness: '記録は完璧なのに、自分の感情ログは未整理。他人の夢は分類できるのに、自分の「なりたい未来」は曖昧。時空観測のプロなのに、地図を間違えて読んでしまう。',
    equipment: [
      {
        name: 'ドロップランプ',
        description: 'ルナ・モス・フォレストで固まった樹液のランプ。星書庫でのインク代わりや、記録を封印する「蝋」として使う。',
      },
      {
        name: '記録官の皮（マント）',
        description: '脱ぎ捨てた過去の自分が編み込まれた宇宙空間のマント。その内側には無限の空想が広がっている。',
      },
    ],
    equipmentImage: '/stella-items.png',
    anatomyImages: [
      {
        image: '/rufen-anatomy-concept.jpg',
        name: '核心概念：変容する観測者',
        nameEn: 'The Transforming Observer',
        description: 'ルーフェンは、固定された実体を持たない「流動する自我」の体現者。Litho-Archeに散らばる名前のない感情や古い夢をアーカイブするためには、記録官自身が常に純粋な器であり続けなければならない。彼は成長や心境の変化に伴い、蛇が脱皮するように古い自分（皮）を脱ぎ捨て、新たな姿へと再生を繰り返す。',
      },
      {
        image: '/rufen-anatomy-refsheet.jpg',
        name: '外見の哲学',
        nameEn: 'Character Reference',
        description: '実在の動物の生々しさと幻想的な美しさを併せ持つ姿。それは「なりたい自分」を現実と幻想の壁を超えて体現したもの。前後の姿と、幼体・成体の両形態を記録した図譜。自らの魂がアップデートされた瞬間、必然的に表面化する新たな形を「肉体」として再構築する。',
      },
      {
        image: '/rufen-anatomy-skull.jpg',
        name: '頭蓋構造と角の解剖',
        nameEn: 'Cranial Anatomy',
        description: '角は柔らかいベルベット状の毛皮で覆われており、成長と共に内部のクリスタル状の角が露出する。黒い大きな耳は、感情の波紋と「まだ言葉にならない想い」を受信するアンテナとして機能している。幼体では耳と角の境界が曖昧で、成熟するにつれて輪郭が鮮明になる。',
      },
      {
        image: '/rufen-anatomy-form.jpg',
        name: '変容形態：深淵の観測',
        nameEn: 'Aquatic Form',
        description: '深淵の水域で観測を行う際に顕現する形態。魚のような尾と鰭を持ち、深海の「言葉にならない静寂」を直接皮膚で感知することができる。この姿はルーフェンの脱皮の一段階であり、水に溶けた誰かの記憶を体全体で受け取るための器として機能する。',
      },
    ],
    quote: '「この星屑が誰にも見られないまま消えるの、いやだ」',
  },
  volt: {
    name: 'ヴォルト',
    nameEn: 'Antwort / Volt',
    title: '応える者 ── 種族：Varglith（ヴァルグリト）',
    images: [
      { src: '/volt.png', alt: 'ヴォルト' },
    ],
    profile: [
      {
        label: '名の意味',
        text: '「Antwort（アントヴォルト）」── ドイツ語で「答え」。ルーフェン（Rufen＝呼ぶ者）の叫びにのみ即座に反応し、その小さな身体をあらゆる災厄から遮断する「答え」そのもの。',
      },
      {
        label: '種族・外見',
        text: '古の騎士の魂が宿るVarglith（ヴァルグリト）の巨人狼。岩石のような筋肉と、深い森の夜を溶かし込んだような毛並みを持つ。',
      },
      {
        label: '星雲の眼（Cosmic Eyes）',
        text: '青く発光する瞳の奥には、単なる光彩ではなく、渦巻く銀河や星々が内包されている。ヴォルトは、この小宇宙を通してルーフェンの魂を「見通す」。かつて誰にも気づかれなかったルーフェンの輝きを、ヴォルトだけは最初からこの瞳に映していた。彼が見つめる時、そこには宇宙規模の「全肯定」が宿っている。',
      },
      {
        label: '蒼晶の爪（Gemstone Claws）',
        text: '四肢の先に備わる爪は、研磨されたサファイアやラピスラズリのように透き通った蒼い輝きを放つ。「Litho（石）」の究極の形態であり、獲物を引き裂く武器であると同時に、世界を傷つけることなく「真実の美」を切り出すための聖なる道具である。',
      },
    ],
    personality: [],
  },
};
