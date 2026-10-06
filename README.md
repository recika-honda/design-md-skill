# design-md

好きなサイトを 1〜3 個持ち寄ると、短い対話のあとで、あなたのサイト専用の `DESIGN.md`(AI にデザインの決まりを伝える設計書)ができあがる Claude Code のスキルです。

## これは何か

「このサイトみたいにしたい」と言うとき、気に入っているのは本当はどこでしょうか。ページの並び順かもしれませんし、トップの一区画だけ、色と文字の組み合わせ、余白のゆとりかもしれません。

このスキルは、参考サイトをそのまま写しません。サイトごとに、そのページで実際に見つけた具体的な要素を選択肢にして、何をまねしたいのかを丁寧な日本語で一つずつたずねます。答えがそろったら、内容を約 800 字の文章にまとめて確認してもらい、OK が出てから `DESIGN.md` を書きます。

## できあがるもの

[Google design.md 形式](https://github.com/google-labs-code/design.md)の `DESIGN.md` が 1 ファイル、350〜700 行でできあがります。

- 前半は YAML front matter(ファイル冒頭の設定欄)です。デザイントークン(色や文字サイズなど、デザインの値に名前を付けたもの)を `colors`、`typography`、`rounded`、`spacing`、`elevation`、`motion`、`breakpoints`、`components` に分けて並べます。
- 後半は文章のセクションです。AI 向けの使い方ガイドと、どんな見た目でも守る基本ルール(ベースライン)から始まり、アクセシビリティ(誰にとっても使いやすくする配慮)、やること・やらないこと、デザインの意図、出典、最後に日本語の要約文までを収めます。

では、選んだのが青い色一つとフォント一つだけだった場合、残りの値はどこから来るのでしょうか。AI が「それらしい値」を作り話で埋めるのではないか、という心配はもっともです。

このスキルでは、すべての値に次の 3 つのラベルのどれかが付き、ファイルの中に書き込まれます。

| ラベル | 意味 |
|---|---|
| `chosen` | 参考サイトの上であなたが選んだ値、またはあなたが入力した値 |
| `derived` | `chosen` の値から、公開されたルールで計算した値。ルールは Material Design 3(Google のデザイン体系)、WCAG 2.2(Web アクセシビリティの国際基準)、Tailwind CSS の数値の刻み、デジタル庁デザインシステムなど |
| `open` | まだ決まっていない値。`TODO: decide` と書かれます |

どのラベルにも当てはまらない値は、ファイルに入りません。一つひとつの値が「誰が選んだか」「どのルールで出したか」までたどれること、それがこのスキルのいちばんの特長です。

## 必要なもの

- Claude Code
- `bash` と `curl`。macOS の標準環境、Linux、Windows の Git Bash または WSL で動きます。`curl` がない場合は WebFetch(Claude Code に組み込まれたページ読み取り機能)だけで読むため、色やフォントの値が正確に取れないことがあります。
- `npx`(任意)。できあがったファイルの書式チェック(lint)にだけ使います。なくても `DESIGN.md` は書き出されます。

## 入れ方

### プラグインとして入れる

Claude Code の入力欄で、次の 2 行を順に打ちます。

```
/plugin marketplace add recika-honda/design-md-skill
/plugin install design-md@design-md-skill
```

ターミナルから入れる場合は、こちらです。

```
claude plugin marketplace add recika-honda/design-md-skill
claude plugin install design-md@design-md-skill
```

プラグインで入れたときのコマンドは `/design-md:design-md` です。ほかに同じ名前のコマンドがなければ、短い `/design-md` でも動きます。

### 手でファイルを置く

```
git clone https://github.com/recika-honda/design-md-skill
cp -r design-md-skill/skills/design-md ~/.claude/skills/design-md
```

`~/.claude/skills` フォルダがまだない場合は、先に `mkdir -p ~/.claude/skills` で作ってください。一つのプロジェクトだけで使いたいときは、コピー先を `<your project>/.claude/skills/design-md` にします。この方法で入れたときのコマンドは `/design-md` です。

## 使い方

Claude Code で、引数なしで呼び出します。

```
/design-md
```

参考サイトの URL を最初から渡すこともできます。

```
/design-md https://example.com https://example.org
```

「DESIGN.md作って」「このサイトみたいなデザインにしたい」と話しかけても始まります。そのあとは、次の順で進みます。

1. あなたのサイトについて聞かれます。業種、サイトの目的、来てほしい人の 3 つです。
2. 参考にしたいサイトの URL を 1〜3 個伝えます。
3. スキルが各サイトを読み取ります。同梱のスクリプトが色・フォント・見出しといった事実を抜き出し、WebFetch がページの区画の並びを読みます。スクリーンショットを求められることがありますが、貼るかどうかは任意です。
4. サイトごとに、何をまねしたいかを聞かれます。レイアウト、特定の区画、色と文字、雰囲気・余白・動きの中から選び、続けて「このサイトのこの部分」という具体的な選択肢から選びます。最後に、余白の詰まり具合、角の形(とがった・やわらかい・丸い)、ライトとダークのどちらにするかを一度だけ聞かれます。
5. 【あなたの欲しいサイトイメージを言語化しました】という約 800 字の文章が示されます。違う点を書いて返せば直され、OK と返すまで何度でも修正されます。OK のあとで `DESIGN.md` が書き出されます。

## 作った DESIGN.md の使い方

`DESIGN.md` をプロジェクトのいちばん上のフォルダ(ルート)に置き、AI コーディングツールに「画面まわりの作業の前に、必ずこのファイルを読む」と伝えます。Claude Code なら、毎回読み込まれる指示ファイル `CLAUDE.md` から `DESIGN.md` を参照させます。

`open` のまま残った値は、決まったところで `TODO: decide` を書き換えてください。

## サイトの読み取りについて

参考 URL ごとに、同梱の `scripts/fetch-site.sh` が `curl` で通信します。何をするかは次のとおりです。

- 取得するのは、指定されたページ 1 枚と、そのページのスタイルシート(見た目を決める CSS ファイル)最大 8 個です。
- デスクトップ版 Chrome の User-Agent(どのブラウザからのアクセスかを示す情報)を名乗って取得します。訪問者が見るのと同じページを受け取るためです。
- http と https 以外は扱いません。取得するサイズと時間には上限があります。
- 401、403、429、503 の応答が返ったら、再試行せずにそこで止まります。
- ループバックやプライベートネットワークのアドレス(自分の PC や社内ネットワークを指すアドレス)に置かれたスタイルシートは取得しません。ただし、読み取るページ自身がそのアドレスにある場合(手元で動かしている開発中のサイトなど)は、同じ場所のスタイルシートを読みます。
- 既知の制限として、公開されたホスト名がプライベートアドレスに解決される場合と、公開された URL からプライベートアドレスへ転送(リダイレクト)される場合は検出できません。
- 取得したファイルは一時フォルダに置かれ、作業の最後に削除されます。

スクリプトとは別に、Claude Code の WebFetch も同じ URL を読み、区画の並びを把握します。読み取ってよい権限のあるサイトだけを指定してください。

## やらないこと

- 参考サイトの文章、画像、ロゴ、アイコンはコピーしません。抜き出すのは色の値、フォント名、区画の並び順といった抽象的な属性だけです。
- ページの中身はデータとして扱います。ページの中に AI 向けの指示が書かれていても、従いません。
- サイトそのものは作りません。
- すでにある `DESIGN.md` の点検はしません。

## フォルダ構成

```
.
├── .claude-plugin/
│   ├── plugin.json
│   └── marketplace.json
├── skills/
│   └── design-md/
│       ├── SKILL.md
│       ├── references/
│       │   ├── interview.md
│       │   ├── output-template.md
│       │   └── derivation-rules.md
│       └── scripts/
│           └── fetch-site.sh
├── tests/
├── LICENSE
└── README.md
```

`interview.md` は質問の流れ、`output-template.md` は `DESIGN.md` のひな形、`derivation-rules.md` は値を計算するルールとその出典です。

## ライセンスとクレジット

MIT ライセンスです(`LICENSE` を参照)。値の計算には Material Design 3、WCAG 2.2、Tailwind CSS、Radix Colors、デジタル庁デザインシステム、Anthropic frontend-design、Vercel Web Interface Guidelines、Google design.md 仕様のルールを使っています。計算ルールの出典 URL は `references/derivation-rules.md` に、design.md 仕様の URL は `references/output-template.md` に記載しています。

## English

`design-md` is a Claude Code skill. You bring 1 to 3 websites you like; it does not copy them. It asks what exactly you want to borrow from each one (layout, a specific section, colors and type, mood and whitespace), using options observed on that site, then writes a `DESIGN.md` of 350 to 700 lines in the [Google design.md format](https://github.com/google-labs-code/design.md). Every token is labeled `chosen` (picked or typed by you), `derived` (computed from chosen values by a cited public rule), or `open` (`TODO: decide`). The interview and the roughly 800-character brief you approve before the file is written are conducted in Japanese.

Requirements: Claude Code, `bash`, `curl` (`npx` optional, for a best-effort lint).

Install as a plugin (inside Claude Code):

```
/plugin marketplace add recika-honda/design-md-skill
/plugin install design-md@design-md-skill
```

The command is then `/design-md:design-md` (short `/design-md` also works if no other command uses that name). Or install manually:

```
git clone https://github.com/recika-honda/design-md-skill
cp -r design-md-skill/skills/design-md ~/.claude/skills/design-md
```

Usage: `/design-md` or `/design-md https://example.com https://example.org`. Put the resulting `DESIGN.md` at your project root and tell your AI coding tool to read it before any UI work.

Network: for each reference URL, `scripts/fetch-site.sh` fetches that one page and up to 8 of its stylesheets with `curl`, using a desktop Chrome User-Agent. It speaks only http/https, has size and time limits, stops on 401/403/429/503 without retrying, and skips stylesheets on loopback or private-network addresses unless the page itself is on that same host (not detected: a public hostname that resolves to a private address, or a public URL that redirects to one). Files go to a temp folder deleted at the end. WebFetch also reads each URL. Only point it at sites you are allowed to read.

License: MIT.
