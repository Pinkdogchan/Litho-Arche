import Link from 'next/link';
import Image from 'next/image';
import { notFound } from 'next/navigation';
import CreatureCard from '../../components/CreatureCard';
import CharacterProfile from '../../components/CharacterProfile';
import { characters } from '../../lib/characters';

// エリアデータの定義
const areas: Record<string, {
  title: string;
  titleEn: string;
  image: string;
  showImage?: boolean;
  extraImages?: string[];
  description: string;
  landscape: string[];
  worldView: string;
  features?: string[];
  creatures?: Array<{
    name: string;
    nameEn: string;
    description: string;
    image?: string;
  }>;
  message?: string;
  decorativeImage?: string;
  lifeImages?: string[];
  featuredVideo?: string;
  characterSlug?: string;
  illustrations?: Array<{ image: string; name: string; nameEn: string; description: string }>;
  illustrationsTitle?: string;
}> = {
  'stella-library': {
    title: '虚無の星書庫',
    titleEn: 'Stella-Library "Void"',
    image: '/area-stella-library.jpg',
    showImage: true,
    description: '崖の縁に佇む、「空想の観測所」。ここは主席記録官が実際に執筆を行う場所であり、物理的な境界が存在しない特異点です。',
    landscape: [
      '空中に光る本や紙だけが浮かんでいます。',
      '手を伸ばせば、記録官ルーフェンがこれまで収集した「誰かの未完成な夢」を読み取ることができます。',
      '背後には、地平線から宇宙が始まっているような、境界線のない星空が広がっています。',
    ],
    worldView: '物理的な境界を取り払うことで、リト・アルケーの住人は宇宙の知性と直接繋がることができます。ここに集まる「未完成の夢」たちは、記録されることで初めてその輝きを取り戻します。',
    message: '「ここは主席記録官が実際に執筆を行う場所だよ。物理的な境界を取り払うことで、リト・アルケーの住人は宇宙の知性と直接繋がることができるんだ。君も1冊読んでみる？」',
    lifeImages: ['/rufen-stroll.png', '/rufen-daydream.png', '/stella-caravan.png', '/rufen-wolf-play.png'],
    featuredVideo: '/dream-4.mp4',
    characterSlug: 'rufen',
  },
  'crystal-vein-echo': {
    title: '追憶の水晶脈',
    titleEn: 'Crystal-Vein Echo',
    image: '/area-crystal-vein-echo.jpg',
    showImage: true,
    description: '深い霧の底、地殻の裂け目に沿って広がる「音を視覚化する」回廊です。',
    landscape: [
      '地面から巨大な水晶の柱が不規則に突き出しており、その内部には過去に誰かが呟いた「独り言」や「願い」が光の波紋として閉じ込められています。',
      '霧が水晶に触れるたび、淡いプリズム光が周囲を照らします。',
      '巨大な透明水晶に、頭上の銀河が反射して映り込む「鏡合わせの宇宙」。',
    ],
    worldView: '「言葉にならない不安」「怒り」「憎しみ」「強欲」などのネガティブな感情を吸い込み、浄化して光に変えるリト・アルケーの天然フィルターの役割を果たしています。',
    message: '「この水晶の内側に閉じ込められた光は、かつて誰かが声にできなかった言葉たちです。怒りも、ねたみも、呑み込んだ『助けて』も——ここでは等しく、浄化されて光になることを許されます。壁にそっと手を当ててみてください。凝り固まっていたものが、少し溶け出すはずですから。」',
    illustrationsTitle: '水晶脈に刻まれた記憶',
    illustrations: [
      {
        image: '/crystal-art-fox-jacket.jpg',
        name: '水晶の旅人',
        nameEn: 'Crystal Wanderer',
        description: '追憶の水晶脈をひとり通り過ぎていった、名もなき旅人の記録。開いたジッパーの奥、毛皮の内側には青い空間が広がっている。外側は獣の姿をしていながら、その中に宇宙を抱えているような存在。振り返ることなく歩き続けるその横顔は、やがて水晶の内壁に光として永遠に刻まれた。',
      },
      {
        image: '/crystal-art-howling.jpg',
        name: '解放の咆哮',
        nameEn: 'The Great Release',
        description: '水晶脈の最深部で観測された咆哮。長い年月、胸の奥底に押し込め続けた「言葉にできなかった絶叫」が、ついに光として解き放たれた瞬間。その叫びはそのまま水晶に吸い込まれ、浄化され、やがてここを訪れる誰かを照らす星の歌へと昇華された。',
      },
      {
        image: '/crystal-art-rufen.jpg',
        name: '水晶との対話',
        nameEn: 'Crystal Dialogue',
        description: '主席記録官が水晶の回廊で「閉じ込められた想い」を直接受信している瞬間。水晶から伸びる光の筋が、その髪に静かに絡みついている。誰かの「誰にも届かなかった優しさ」に触れた瞬間、記録官の瞳に規定外の感情がひとつ宿った。',
      },
      {
        image: '/crystal-art-wolf-light-1.jpg',
        name: '光への憧れ・静',
        nameEn: 'Longing for Light I',
        description: '同じ狼を描いた2枚のうちの1枚。オパール色の虹彩が毛並みの奥から滲み出すように宿り、獣でありながらすでに光の側にいるような佇まいをしている。光そのものになりたいという純粋な憧れが、この一対の絵を生んだ。',
      },
      {
        image: '/crystal-art-wolf-light-2.jpg',
        name: '光への憧れ・動',
        nameEn: 'Longing for Light II',
        description: '同じ狼を描いた2枚のうちの1枚。毛並みはすでに風に溶け、プリズムの色が後方へ流れ散っている。前を向いたままその輪郭は霞んでいく。光になることを恐れず、ただそこへ向かっていく。',
      },
      {
        image: '/crystal-art-sprint.jpg',
        name: '蒼晶の疾走',
        nameEn: 'Sapphire Sprint',
        description: '水晶脈の光の中に溶け出すルーフェンの記録。オパールの内側で白い光が砕けて無数の色になる瞬間に魅了された彼が、そのプリズムの輝きを毛並みに宿した形態。輪郭は少しずつほどけ、やがて光そのものへと静かに消えていく。',
      },
    ],
  },
  'lunar-moss-forest': {
    title: '月苔の深き眠り',
    titleEn: 'Lunar-Moss Forest',
    image: '/area-lunar-moss-forest.jpg',
    showImage: true,
    description: '発光植物が最も密集している、柔らかい静寂に包まれた森です。',
    landscape: [
      '足元には、人の体温に反応して白く光る「銀河苔」がふかふかの絨毯のように広がっています。',
      '樹木は透明な樹液を滴らせ、それが空中で固まって「宙に浮く雫のランプ」となり、外の光を地上へ繋ぐ導線となっています。',
      'だから森の奥がふんわりと明るい。',
    ],
    worldView: 'この森の苔は、地上の喧騒で傷ついた者の歩幅を緩める性質があります。ここでは誰も急ぐ必要がなく、ただ「存在していること」だけが肯定される聖域です。',
    message: '「この森では、どんな急ぎ足も自然と遅くなります。銀河苔が体温に反応して光るから——急いで通り過ぎるには、あまりにも美しすぎるのです。何かを成し遂げなくていい。ここにいる、ただそれだけで、僕はこの頁に記録します。」',
    creatures: [
      {
        name: '深淵の観測眼',
        nameEn: 'Stellar Ocellus',
        description: 'イボタガを彷彿とさせる、灰褐色と漆黒の波状紋の中に、吸い込まれるような「同心円状の巨大な目玉模様」を左右の翅に宿した大型の蛾。ルーフェンはこの蛾を「沈黙の記録官」と呼びます。',
        image: '/creature-stellar-cobalt.jpg',
      },
      {
        name: '藍蜜の追跡者',
        nameEn: 'Cobalt Humming',
        description: 'ホウジャク（蜂雀）に似た、高速で羽ばたく小型の昆虫。月苔の隙間にひっそりと咲く青い花の蜜を主食としています。',
        image: '/creature-stellar-cobalt.jpg',
      },
      {
        name: '琥珀の鱗粉舞う者',
        nameEn: 'Amber Fairy',
        description: '人に近いシルエットを持つ、オレンジと焦茶色の翅を広げた蛾の生き物。飛翔するたびに、温かな光を放つ琥珀色の鱗粉を振りまきます。',
        image: '/creature-amber-bunny.jpg',
      },
      {
        name: '月光の跳躍者',
        nameEn: 'Bunny Moth',
        description: '全身が青くふさふさとした長い体毛に覆われ、うさぎのような長い「触角（耳）」を持つ愛らしい蛾。ルーフェンの良き友人です。',
        image: '/creature-amber-bunny.jpg',
      },
      {
        name: '月夜のもち肌',
        nameEn: 'Bomi-Sphinx',
        description: '赤ちゃんの肌のように「もちもち・すべすべ」とした弾力のある白い体を持つ、スズメガの幼虫。ルーフェンのペットとしても愛されています。',
        image: '/creature-bomi-sphinx.jpg',
      },
      {
        name: '白銀の旋風',
        nameEn: 'Lunar Fluffy-Moth',
        description: 'ボミスズメが青い月光を浴びて羽化した姿で、全身がシルクのように細く「ふさふさ」した白い毛に包まれた美しく愛らしい小型の蛾。',
      },
    ],
  },
  'bios-nebula': {
    title: '生命の星雲',
    titleEn: 'Bios-Nebula',
    image: '/area-bios-nebula.jpg',
    showImage: true,
    description: 'Litho-Archeの最下層に位置する、巨大な空洞。ここでは「霧」が最も濃く、頭上の星空と足元の発光植物の境界が消滅し、まるで宇宙の深淵を歩いているような感覚に陥るエリアです。',
    landscape: [
      '足元には、深いインディゴブルーの霧が重く沈殿しています。',
      'その霧の中には微細な発光粒子が渦巻いており、歩くたびに銀河が波打つような軌跡を残します。',
      '天井からは、半透明の鉱石で作られた「繭」のような結晶がいくつも垂れ下がっています。',
      'この繭は、地上で誰かが捨ててしまった「純粋な好奇心」や「幼い日の空想」を養分にして、ゆっくりと明滅しています。',
    ],
    worldView: 'このエリアは、Litho-Archeにおける「魂のリサイクルセンター」です。地上の効率主義や「正解」を求める社会で窒息し、死んでしまったアイデアや感性は、一度このBios-Nebulaに流れ着きます。',
    message: '「Bios-Nebulaで迷子になるのは、悪いことではありません。ここにある光の一つ一つは、かつてあなたが『無駄だ』と切り捨てた大切な一部なのですから。私はそれらを拾い集め、決して消えないように、このアーカイブに綴り続けます。」',
    illustrationsTitle: '創造の断片',
    illustrations: [
      {
        image: '/nebula-sketch-fursuit.jpg',
        name: '器の習作',
        nameEn: 'Studies of the Vessel',
        description: '着ぐるみの構造を探るための習作。内側にいる自分を、外側の「形」としてどう作るか。様々な角度から検討された体のシルエットと、仮面のような顔。自分をまとう「器」を真剣に考えた記録は、ルーフェンが言う「脱皮」の概念と、どこかで繋がっている。',
      },
      {
        image: '/nebula-sketch-rabbit.jpg',
        name: '名前を待つ顔たち',
        nameEn: 'Faces Without Names',
        description: 'キャラクターが生まれる最初の瞬間の記録。まだ名前も輪郭も定まらない、問いかけのような顔たち。走り書きの一言すら、繭の養分になっている。ここに流れ着いた空想は、いつかまた誰かの手で形になるのを、静かに待っている。',
      },
      {
        image: '/nebula-sketch-sprout.jpg',
        name: '生まれかけの生き物たち',
        nameEn: 'Creatures Almost Born',
        description: '手の形を探す習作と、まだ名前のない生き物たちの記録。頭に芽が生えた白い子、青い輪の精霊、小さな幽霊。完成することなく宙に浮いたままのアイデアが、Bios-Nebulaの霧の中でかすかに息をしている。',
      },
      {
        image: '/nebula-sketch-coffee.jpg',
        name: '骨格と動きの探求',
        nameEn: 'Studies of Form and Motion',
        description: '骨格と動きの探求、そして青い毛並みを持つ者の最初期の姿。骨だけのスケルトンたちが踊り、大きな爪を持つ者が空を見上げる。まだ物語を持たないキャラクターたちが、繭の中で名前を待っている。',
      },
      {
        image: '/nebula-sketch-dark.jpg',
        name: '暗闇の中の青',
        nameEn: 'Blue in the Dark',
        description: '深い暗闇の中、青い光の線だけが輪郭を描く。口を開き、何かを叫ぼうとしているのか、あるいは飲み込もうとしているのか。Bios-Nebulaの最も深い場所で観測される者の顔は、こういう表情をしている。光を知っているから、こんなに青い。',
      },
      {
        image: '/nebula-sketch-orca.jpg',
        name: '深淵の泳ぐ者',
        nameEn: 'Dwellers of the Deep',
        description: '水中で光を纏うシャチと、深淵に潜む黒い獣たちの記録。Bios-Nebulaの最下層では生と死の境が溶け合い、海の覇者も暗い霧の中の怪物も、等しく繭に収められる。光を知っているから、闇も描けた。',
      },
    ],
  },
  'ember-core-hearth': {
    title: '残り火の深淵',
    titleEn: 'Ember-Core Hearth',
    image: '/area-ember-core-hearth.png',
    description: '白い霧がここでは「温かい蒸気」へと変化し、地底の奥深くから昇る琥珀色の光がエリア全体を照らしています。',
    landscape: [
      '足元を流れるのは熱いマグマではなく、液体状になった「古い情熱」の結晶です。',
      '触れると熱を帯びていますが、火傷をすることはなく、冷え切った心を芯から温める効果があります。',
      '木々の枝には、提灯のように赤く発光する果実が実っています。',
      'これは、かつて誰かが抱いた「忘れられない憧れ」が具現化したもので、風が吹くと火の粉のような胞子を散らします。',
    ],
    worldView: '「Bios-Nebula」が魂をリサイクルする場所なら、ここは「魂に再び火を灯す鍛冶場」です。一度は「無駄だ」と捨てられたアイデアや感情も、このエリアの熱（肯定的な情熱）に触れることで、再び動き出すための活力を得ます。',
    message: '「ここの熱は、傷つけるためにあるのではありません。あの頃、誰かに笑われて手放してしまった情熱は——捨てたのではなく、ここに預けてあっただけです。足元を流れる琥珀色の光に触れてみてください。それは君の、まだ燃え続けている部分ですから。」',
  },
  'solar-resonance-crater': {
    title: '日輪の共鳴孔',
    titleEn: 'Solar-Resonance Crater',
    image: '/area-solar-resonance-crater.png',
    description: 'Litho-Archeの中で唯一、頭上の星空が見えないほどに「黄金の光」が充満している垂直の空洞エリアです。',
    landscape: [
      'エリアの中央には、巨大な浮遊鉱石が太陽のように居座り、そこから真下に向かって強烈なオレンジ色の光線（共鳴波）を放っています。',
      '壁面からは砂時計の砂のように細かい黄金の砂が流れ落ちており、それが光を反射してエリア全体をまばゆい黄金色に染め上げています。',
      'ここを訪れる者は、自分の鼓動が周囲の光の明滅と同期していく不思議な感覚を覚えます。',
    ],
    worldView: 'ここは「怒り」や「憎しみ」といった激しい感情のエネルギーを、「正義感」や「自己防衛の意志」という純粋な黄金の力へと転換する変換装置の役割を担っています。',
    message: '「この場所では、君の鼓動が周囲の明滅と同期し始めます。それは錯覚ではありません——君の中にある激しさが、星の鼓動と共鳴しているのです。怒りとは、まだ磨かれていない正義感のことです。ここに来た君の感情は、すでに金へと変わりつつあります。」',
  },
  'celestial-bright-shore': {
    title: '天光の輝浜',
    titleEn: 'Celestial Bright Shore',
    image: '/area-celestial-bright-shore.jpg',
    showImage: true,
    extraImages: ['/area-celestial-bright-shore-2.jpg'],
    description: 'クレーターから放出される莫大な熱量とエネルギーによって、周囲を包む「白い霧」が完全に蒸発し、「晴天の窓」のようになっている特異点です。',
    landscape: [
      '水晶を含んだ砂浜が海に溶け出し、海水は沖縄の比ではないほど透明度が高く、青く澄んで太陽光を反射してプリズムのような虹色の光を放ちます。',
      '陸上には、海から進化した色彩豊かな「陸生珊瑚」が樹木のようにそびえ立ち、その間を南国のシダ植物に似た発光植物が埋め尽くしています。',
      'このエリアの境界線では、行き場を失った白い霧が巨大な壁のようにそびえ立っています。',
    ],
    worldView: '常に冷涼で湿度の高いLitho-Archeにおいて、ここでの海水浴は単なる遊びではなく、身体に溜まった霧の湿気を追い出すための儀式のようなもの。',
    message: '「リト・アルケーで、ここだけ霧が晴れています。それは偶然ではありません——ここまで辿り着いたこと自体が、君がまだ前を向いている証拠です。思い切り光を浴びてください。プリズムの波が君の輪郭をなぞるとき、それはこの世界が『ここにいるよ』と、静かに応えている声です。」',
  },
  'twilight-glow-reef': {
    title: '黄昏の抱擁',
    titleEn: 'Twilight-Glow Reef',
    image: '/area-twilight-glow-reef.png',
    description: '「Bios-Nebula（生命の星雲）」の深いインディゴブルーと、「Ember-Core Hearth（残り火の深淵）」の琥珀色が溶け合う、広大な湿地帯のようなエリアです。',
    landscape: [
      '足元を漂う霧は、場所によって薄紫色から茜色へと刻々と変化します。',
      '透明な水晶の枝を持ちながら、その芯にはオレンジ色の光を宿した樹木が群生しています。',
      '枝からは「宙に浮く雫のランプ」が滴り落ちますが、ここではその雫が夕日のように輝き、ゆっくりと霧の中へ沈んでいきます。',
      '数時間に一度、頭上の星空がひときわ強く瞬き、エリア全体が目が眩むようなマゼンタ色に染まる「エコー・サンセット」が発生します。',
    ],
    worldView: 'ここは、Litho-Archeにおける「決意の待合室」です。「Bios-Nebula」で過去を浄化し、自分の一部を肯定された者が、再び地上の熱い情熱（赤色のエリア）へ飛び込む前に、心を整える場所です。',
    message: '「ここは、さよならと初めましてが手をつなぐ場所。青い夜の優しさに別れを告げ、赤い朝の熱量を受け入れる。その色の混じり合いこそが、あなたが再び『生きていく』ための新しい筆跡（ログ）になるのです。」',
  },
};

export async function generateStaticParams() {
  return Object.keys(areas).map((slug) => ({
    slug,
  }));
}

export default function AreaPage({ params }: { params: { slug: string } }) {
  const area = areas[params.slug];

  if (!area) {
    notFound();
  }

  return (
    <main className="min-h-screen bg-gradient-to-b from-deep-night-200 via-deep-night-100 to-deep-night-200 relative overflow-hidden">
      {/* 星空の背景エフェクト */}
      <div className="fixed inset-0 overflow-hidden pointer-events-none">
        {Array.from({ length: 50 }).map((_, i) => (
          <div
            key={i}
            className="absolute rounded-full bg-luminous-blue-300 animate-sparkle"
            style={{
              left: `${Math.random() * 100}%`,
              top: `${Math.random() * 100}%`,
              width: `${Math.random() * 3 + 1}px`,
              height: `${Math.random() * 3 + 1}px`,
              animationDelay: `${Math.random() * 2}s`,
              opacity: Math.random() * 0.5 + 0.3,
            }}
          />
        ))}
      </div>

      {/* メインコンテンツ */}
      <div className="relative z-10 min-h-screen px-4 py-16">
        <div className="max-w-5xl mx-auto">
          {/* 戻るリンク */}
          <Link
            href="/"
            className="inline-flex items-center text-luminous-blue-300 hover:text-luminous-blue-200 mb-8 transition-colors"
          >
            <span className="mr-2">←</span>
            博物誌のトップへ戻る
          </Link>

          {/* タイトルセクション */}
          <div className="text-center mb-12 space-y-4">
            <h1 className="text-5xl md:text-7xl font-bold glow-luminous text-luminous-blue-200">
              {area.title}
            </h1>
            <div className="w-32 h-1 bg-gradient-to-r from-transparent via-luminous-blue-400 to-transparent mx-auto"></div>
            <p className="text-xl md:text-2xl text-luminous-blue-100/80 font-light tracking-wider">
              {area.titleEn}
            </p>
          </div>

          {/* エリアイラスト */}
          {area.showImage && (
            <div className="relative w-full mb-12 flex flex-col items-center gap-8">
              <div className="relative w-full max-w-2xl">
                <Image
                  src={area.image}
                  alt={area.title}
                  width={900}
                  height={1200}
                  className="w-full rounded-sm drop-shadow-2xl"
                  priority
                />
              </div>
              {area.extraImages?.map((src, i) => (
                <div key={i} className="relative w-full max-w-2xl">
                  <Image
                    src={src}
                    alt={`${area.title} ${i + 2}`}
                    width={900}
                    height={1200}
                    className="w-full rounded-sm drop-shadow-2xl"
                  />
                </div>
              ))}
            </div>
          )}

          {/* エリアの説明 */}
          <section className="bg-deep-night-100/50 backdrop-blur-sm border border-luminous-blue-500/20 rounded-lg p-8 md:p-12 glow-soft mb-8">
            <p className="text-lg md:text-xl text-luminous-blue-100/90 leading-relaxed">
              {area.description}
            </p>
          </section>

          {/* 景観のポイント */}
          <section className="bg-deep-night-100/30 backdrop-blur-sm border border-luminous-blue-400/10 rounded-lg p-8 md:p-12 mb-8">
            <div className="relative flex items-center justify-center mb-8">
              <Image
                src="/title-frame.png"
                alt=""
                width={600}
                height={120}
                className="w-full max-w-lg"
                style={{ filter: 'invert(1) sepia(1) saturate(2) hue-rotate(190deg) brightness(1.2)', opacity: 0.85 }}
              />
              <h2 className="absolute text-xl md:text-2xl font-semibold text-luminous-blue-100 tracking-widest" style={{ fontFamily: "'Kaisei HarunoUmi', cursive" }}>
                景観のポイント
              </h2>
            </div>
            <div className="space-y-4">
              {area.landscape.map((point, index) => (
                <p
                  key={index}
                  className="text-luminous-blue-100/90 leading-relaxed"
                >
                  {point}
                </p>
              ))}
            </div>
          </section>

          {/* 星書庫の記録 */}
          <section className="bg-deep-night-100/30 backdrop-blur-sm border border-luminous-blue-400/10 rounded-lg p-8 md:p-12 mb-8">
            <div className="relative flex items-center justify-center mb-8">
              <Image
                src="/title-frame.png"
                alt=""
                width={600}
                height={120}
                className="w-full max-w-lg"
                style={{ filter: 'invert(1) sepia(1) saturate(2) hue-rotate(190deg) brightness(1.2)', opacity: 0.85 }}
              />
              <h2 className="absolute text-xl md:text-2xl font-semibold text-luminous-blue-100 tracking-widest" style={{ fontFamily: "'Kaisei HarunoUmi', cursive" }}>
                星書庫の記録
              </h2>
            </div>
            <p className="text-luminous-blue-100/90 leading-relaxed">
              {area.worldView}
            </p>
          </section>

          {/* キャラクタープロフィール（ある場合） */}
          {area.characterSlug && characters[area.characterSlug] && (
            <section className="mb-8">
              <div className="relative flex items-center justify-center mb-4">
                <Image
                  src="/title-frame.png"
                  alt=""
                  width={600}
                  height={120}
                  className="w-full max-w-lg"
                  style={{ filter: 'invert(1) sepia(1) saturate(2) hue-rotate(190deg) brightness(1.2)', opacity: 0.85 }}
                />
                <h2 className="absolute text-xl md:text-2xl font-semibold text-luminous-blue-100 tracking-widest" style={{ fontFamily: "'Kaisei HarunoUmi', cursive" }}>
                  ルーフェン
                </h2>
              </div>
              <CharacterProfile character={characters[area.characterSlug]} featuredVideo={area.featuredVideo} />
            </section>
          )}

          {/* 生物の紹介（ルナ・モス・フォレストの場合） */}
          {area.creatures && area.creatures.length > 0 && (
            <section className="bg-deep-night-100/30 backdrop-blur-sm border border-luminous-blue-400/10 rounded-lg p-8 md:p-12 mb-8">
              <div className="relative flex items-center justify-center mb-8">
                <Image
                  src="/title-frame.png"
                  alt=""
                  width={600}
                  height={120}
                  className="w-full max-w-lg"
                  style={{ filter: 'invert(1) sepia(1) saturate(2) hue-rotate(190deg) brightness(1.2)', opacity: 0.85 }}
                />
                <h2 className="absolute text-xl md:text-2xl font-semibold text-luminous-blue-100 tracking-widest" style={{ fontFamily: "'Kaisei HarunoUmi', cursive" }}>
                  このエリアの生物
                </h2>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {(() => {
                  // 同じ画像を持つ生物をグループ化
                  const groups: Array<{ image?: string; items: typeof area.creatures }> = [];
                  const imageIndex = new Map<string, number>();
                  for (const creature of area.creatures!) {
                    if (creature.image && imageIndex.has(creature.image)) {
                      groups[imageIndex.get(creature.image)!].items.push(creature);
                    } else {
                      if (creature.image) imageIndex.set(creature.image, groups.length);
                      groups.push({ image: creature.image, items: [creature] });
                    }
                  }
                  return groups.map((group, gi) => (
                    <CreatureCard key={gi} group={group as { image?: string; items: { name: string; nameEn: string; description: string; image?: string }[] }} />
                  ));
                })()}
              </div>
            </section>
          )}

          {/* イラストギャラリー（ある場合） */}
          {area.illustrations && area.illustrations.length > 0 && (
            <section className="bg-deep-night-100/30 backdrop-blur-sm border border-luminous-blue-400/10 rounded-lg p-8 md:p-12 mb-8">
              <div className="relative flex items-center justify-center mb-8">
                <Image
                  src="/title-frame.png"
                  alt=""
                  width={600}
                  height={120}
                  className="w-full max-w-lg"
                  style={{ filter: 'invert(1) sepia(1) saturate(2) hue-rotate(190deg) brightness(1.2)', opacity: 0.85 }}
                />
                <h2 className="absolute text-xl md:text-2xl font-semibold text-luminous-blue-100 tracking-widest" style={{ fontFamily: "'Kaisei HarunoUmi', cursive" }}>
                  {area.illustrationsTitle ?? '記録された情景'}
                </h2>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {area.illustrations.map((item, i) => (
                  <CreatureCard
                    key={i}
                    group={{ image: item.image, items: [{ name: item.name, nameEn: item.nameEn, description: item.description }] }}
                  />
                ))}
              </div>
            </section>
          )}

          {/* 記録官の観察日誌（ある場合） */}
          {area.lifeImages && area.lifeImages.length > 0 && (
            <section className="bg-deep-night-100/30 backdrop-blur-sm border border-luminous-blue-400/10 rounded-lg p-8 md:p-12 mb-8">
              <div className="relative flex items-center justify-center mb-8">
                <Image
                  src="/title-frame.png"
                  alt=""
                  width={600}
                  height={120}
                  className="w-full max-w-lg"
                  style={{ filter: 'invert(1) sepia(1) saturate(2) hue-rotate(190deg) brightness(1.2)', opacity: 0.85 }}
                />
                <h2 className="absolute text-xl md:text-2xl font-semibold text-luminous-blue-100 tracking-widest" style={{ fontFamily: "'Kaisei HarunoUmi', cursive" }}>
                  主席記録官の観察日誌
                </h2>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {area.lifeImages.slice(0, 2).map((src, i) => (
                  <div key={i} className="flex items-center justify-center">
                    <Image
                      src={src}
                      alt=""
                      width={600}
                      height={600}
                      className="w-full max-w-sm drop-shadow-2xl"
                    />
                  </div>
                ))}
                {area.lifeImages[2] && (
                  <div className="flex items-center justify-center">
                    <Image
                      src={area.lifeImages[2]}
                      alt=""
                      width={1200}
                      height={912}
                      className="w-full max-w-sm drop-shadow-2xl"
                    />
                  </div>
                )}
                {area.lifeImages[3] && (
                  <div className="flex items-center justify-center">
                    <Image
                      src={area.lifeImages[3]}
                      alt=""
                      width={600}
                      height={600}
                      className="w-full max-w-xs drop-shadow-2xl"
                    />
                  </div>
                )}
              </div>
            </section>
          )}

          {/* キャラクターイラスト（動画がある場合は紙の上にイラストを表示） */}
          {area.characterSlug && characters[area.characterSlug] && area.featuredVideo && (
            <div className="mb-8 flex justify-center">
              <div className="relative w-full max-w-xl">
                <Image src="/paper.png" alt="" width={900} height={1200} className="w-full drop-shadow-2xl" />
                <div className="absolute inset-0 flex items-center justify-center p-10 pt-14 pb-20">
                  <Image
                    src={characters[area.characterSlug].images[0].src}
                    alt={characters[area.characterSlug].images[0].alt}
                    width={700}
                    height={700}
                    className="w-full h-full object-contain"
                    style={{
                      mixBlendMode: 'multiply',
                      WebkitMaskImage: 'radial-gradient(ellipse 72% 72% at 50% 50%, black 30%, transparent 100%)',
                      maskImage: 'radial-gradient(ellipse 72% 72% at 50% 50%, black 30%, transparent 100%)',
                    }}
                  />
                </div>
                <div className="absolute" style={{ bottom: '14%', right: '14%', width: '100px' }}>
                  <Image
                    src="/stamp.png"
                    alt=""
                    width={200}
                    height={200}
                    className="w-full"
                    style={{ mixBlendMode: 'multiply', opacity: 0.8, transform: 'rotate(-8deg)' }}
                  />
                </div>
              </div>
            </div>
          )}

          {/* 装飾イラスト（ある場合） */}
          {area.decorativeImage && (
            <div className="flex justify-center my-4">
              <Image
                src={area.decorativeImage}
                alt=""
                width={420}
                height={467}
                className="w-48 md:w-64 animate-float drop-shadow-2xl"
                style={{ animationDuration: '7s' }}
              />
            </div>
          )}

          {/* メッセージ（ある場合） */}
          {area.message && (
            <section className="bg-deep-night-100/50 backdrop-blur-sm border border-luminous-blue-500/20 rounded-lg p-8 md:p-12 mb-8">
              <p className="text-lg md:text-xl text-luminous-blue-100/90 leading-relaxed italic">
                {area.message}
              </p>
              <p className="text-right text-luminous-blue-300 mt-4">
                — 主席記録官 ルーフェン
              </p>
            </section>
          )}

          {/* 戻るリンク */}
          <div className="text-center mt-12">
            <Link
              href="/"
              className="inline-flex items-center text-luminous-blue-300 hover:text-luminous-blue-200 transition-colors"
            >
              <span className="mr-2">←</span>
              博物誌のトップへ戻る
            </Link>
          </div>
        </div>
      </div>
    </main>
  );
}
