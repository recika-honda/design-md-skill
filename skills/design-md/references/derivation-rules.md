# Derivation rules: how a full token set is computed from a few chosen values

Read by SKILL.md Step 5 when filling `# derived` tokens. Every derived value in a DESIGN.md
cites one row of this file by section number (e.g. `# derived: M3 tone T90, sec.1`). Values
with no row here are not derived; they become `TODO: decide`. Rows marked "unverified" may
be used only as a stated input choice, never as a rule citation.

Compiled 2026-10-05 (JST). Format: RULE -> VALUE(S) -> SOURCE. "unverified" = no primary source reached.
Abbrevs: MCU = https://github.com/material-foundation/material-color-utilities (typescript/dynamiccolor/color_spec_2021.ts, dart/lib/scheme/scheme_tonal_spot.dart, dart/lib/dynamiccolor/dynamic_scheme.dart; raw.githubusercontent.com/material-foundation/material-color-utilities/main/...)
MW = Material Web tokens v0.192: https://github.com/material-components/material-web/tree/main/tokens/versions/v0_192
Note: m3.material.io pages are JS-rendered and returned no body to WebFetch; M3 numbers below come from Google's generated token files (MW) and MCU source instead.

## 1. Color roles and derivation
Tonal palette: a palette = one hue + chroma sampled at tones 0-100 (HCT). Roles pick a palette and a tone.
| Rule | Value | Source |
| Tonal Spot palette chromas (source hue h) | primary h/36; secondary h/16; tertiary (h+60)/24; neutral h/6; neutral-variant h/8; error 25/84 | dart/lib/scheme/scheme_tonal_spot.dart L29-36; dart/lib/dynamiccolor/dynamic_scheme.dart L80 |
| primary | light T40 / dark T80 (primary palette) | MCU color_spec_2021.ts |
| on-primary | light T100 / dark T20 | MCU |
| primary-container | light T90 / dark T30 | MCU |
| on-primary-container | light T30 / dark T90 (non-fidelity) | MCU |
| secondary, tertiary | light T40 / dark T80 (own palettes) | MCU |
| on-secondary, on-tertiary | light T100 / dark T20 | MCU |
| secondary-container, tertiary-container | light T90 / dark T30 | MCU |
| on-secondary-container, on-tertiary-container | light T30 / dark T90 | MCU |
| error | light T40 / dark T80 | MCU |
| on-error | light T100 / dark T20 | MCU |
| error-container / on-error-container | light T90 / T30; dark T30 / T90 | MCU |
| background, surface | light T98 / dark T6 (neutral) | MCU |
| on-background, on-surface | light T10 / dark T90 | MCU |
| surface-container-lowest | light T100 / dark T4 | MCU L194-195 |
| surface-container-low | light T96 / dark T10 | MCU |
| surface-container | light T94 / dark T12 | MCU |
| surface-container-high | light T92 / dark T17 | MCU |
| surface-container-highest | light T90 / dark T22 | MCU |
| surface-dim | light T87 / dark T6 | MCU L173-174 |
| surface-bright | light T98 / dark T24 | MCU |
| surface-variant | light T90 / dark T30 (neutral-variant) | MCU |
| on-surface-variant | light T30 / dark T80 | MCU |
| outline | light T50 / dark T60 | MCU |
| outline-variant | light T80 / dark T30 | MCU |
| inverse-surface | light T20 / dark T90 | MCU |
| inverse-on-surface | light T95 / dark T20 | MCU |
| inverse-primary | light T80 / dark T40 | MCU |
| surface-tint | = primary tone (light T40 / dark T80) | MCU |
| shadow, scrim | neutral palette, black (tone 0) | MCU (palette neutral); tone value unverified |
| Full role-token list (CSS names) | primary, on-primary, primary-container, on-primary-container, secondary*, tertiary*, error*, background, surface, surface-bright/dim/container*, outline, outline-variant | https://raw.githubusercontent.com/material-components/material-web/main/docs/theming/color.md |
| Fixed roles (same in light/dark) | primary-fixed T90, primary-fixed-dim T80, on-primary-fixed T10, on-primary-fixed-variant T30 | MCU |
| Pairing rule | every container/fill role has an "on-" role; text on a role uses its on-role | MCU (on-X naming and tone gaps: T40/T100, T90/T30) |
| Contrast levels | schemes accept contrastLevel (standard/medium/high); containers move darker/lighter (e.g. surface-container light 94/92/90 across levels) | MCU ContrastCurve |
WCAG contrast minimums:
| 1.4.3 AA text | 4.5:1; large text 3:1; ratios must not be rounded (4.499 fails) | https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html |
| Large text definition | >= 18pt, or >= 14pt bold (CJK equivalent) | same |
| 1.4.11 AA non-text | UI components + graphical objects 3:1 against adjacent colors | https://www.w3.org/TR/WCAG22/ |
State colors:
| Material state-layer opacity | hover 0.08; focus 0.12; pressed 0.12; dragged 0.16 (overlay in on-color of the role, over the container) | MW _md-sys-state.scss |
| Disabled | content (label/icon) = on-surface at 0.38; container = on-surface at 0.12; outline disabled 0.12 | MW _md-comp-filled-button.scss, _md-comp-outlined-text-field.scss |
| Radix 12-step scale | 1 app bg; 2 subtle bg; 3 UI element bg; 4 hovered UI bg; 5 active/selected UI bg; 6 subtle border; 7 interactive border; 8 stronger border/focus ring; 9 solid; 10 hovered solid; 11 low-contrast text (Lc 60 APCA on step 2); 12 high-contrast text (Lc 90) | https://www.radix-ui.com/colors/docs/palette-composition/understanding-the-scale |
| Tailwind interaction | no formula in theme variables (single source Tailwind theme page: no state-color rule) | https://tailwindcss.com/docs/theme |

## 2. Type scale
Material 3 type scale (Roboto defaults; size/line-height in rem at 16px root; tracking in rem) - MW _md-sys-typescale.scss, _md-ref-typeface.scss
| Role | size px | line-height px | weight | tracking rem |
| display-large | 57 | 64 | 400 | -0.015625 |
| display-medium | 45 | 52 | 400 | 0 |
| display-small | 36 | 44 | 400 | 0 |
| headline-large | 32 | 40 | 400 | 0 |
| headline-medium | 28 | 36 | 400 | 0 |
| headline-small | 24 | 32 | 400 | 0 |
| title-large | 22 | 28 | 400 | 0 |
| title-medium | 16 | 24 | 500 | 0.009375 |
| title-small | 14 | 20 | 500 | 0.00625 |
| body-large | 16 | 24 | 400 | 0.03125 |
| body-medium | 14 | 20 | 400 | 0.015625 |
| body-small | 12 | 16 | 400 | 0.025 |
| label-large | 14 | 20 | 500 | 0.00625 |
| label-medium | 12 | 16 | 500 | 0.03125 |
| label-small | 11 | 16 | 500 | 0.03125 |
Weights: regular 400, medium 500, bold 700 (MW _md-ref-typeface.scss). Display/headline use "brand" face, body/label "plain" face (two-face slot model).
| Named modular ratios | 1.067 minor second; 1.125 major second; 1.200 minor third; 1.250 major third; 1.333 perfect fourth; 1.414 augmented fourth; 1.500 perfect fifth; 1.618 golden | https://typescale.com/ |
| Ratio-to-mood mapping | unverified (no primary source assigns moods to ratios) |
| Base size | 16px = 1rem; body-large 16/24 (M3) and Tailwind text-base 1rem/1.5 | MW; https://tailwindcss.com/docs/theme |
| Tailwind text steps (rem / line-height) | xs .75/1.333; sm .875/1.429; base 1/1.5; lg 1.125/1.556; xl 1.25/1.4; 2xl 1.5/1.333; 3xl 1.875/1.2; 4xl 2.25/1.111; 5xl 3/1; 6xl 3.75/1; 7xl 4.5/1; 8xl 6/1; 9xl 8/1 | tailwind theme page |
| Line-height body | M3 body-large 1.5; M3 body-medium 1.43; Tailwind base 1.5. Headings: M3 display-large 1.12, headline-large 1.25, headline-medium 1.29; Tailwind 3xl 1.2, 4xl 1.11, 5xl+ 1.0 | MW; tailwind |
| WCAG 1.4.12 (text must survive) | line-height 1.5x font; paragraph spacing 2x; letter-spacing 0.12em; word-spacing 0.16em | https://www.w3.org/TR/WCAG22/ |
| WCAG 1.4.4 / 1.4.10 | resize to 200% without loss; reflow at 320 CSS px width | https://www.w3.org/TR/WCAG22/ |
| Line length | under 80 characters (serif may be slightly longer, give serif slightly more line-height than sans) | https://raw.githubusercontent.com/anthropics/skills/main/skills/frontend-design/SKILL.md |
| One or two families; if two, clearly distinct | same SKILL.md |

## 3. Spacing, containers, breakpoints
| Tailwind spacing base | --spacing: 0.25rem (4px); utilities are multiples (n x 4px): 4,8,12,16,24,32,48,64,96 = steps 1,2,3,4,6,8,12,16,24 | https://tailwindcss.com/docs/theme (base); step-to-px by multiplication |
| 8px / 4px grid rationale text | unverified (no primary rationale page retrieved; M2 touch spacing 8dp only) | https://m2.material.io/design/usability/accessibility.html |
| Tailwind breakpoints | sm 40rem=640; md 48rem=768; lg 64rem=1024; xl 80rem=1280; 2xl 96rem=1536 | tailwind theme page |
| Tailwind container sizes | 3xs 256 ... xl 576, 2xl 672, 3xl 768, 4xl 896, 5xl 1024, 6xl 1152, 7xl 1280 | tailwind theme page |
| Bootstrap 5.3 container max-width | sm 540; md 720; lg 960; xl 1140; xxl 1320 (breakpoints 576/768/992/1200/1400) | https://getbootstrap.com/docs/5.3/layout/containers/ |
| Android/Material window size classes (width dp) | compact <600; medium 600-839; expanded 840-1199; large 1200-1599; extra-large >=1600 | https://developer.android.com/develop/ui/views/layout/window-size-classes |
| 1200 / 1440 container widths | unverified as standards (1200 appears only as a window-class boundary; 1440 unsourced) |

## 4. Radii and elevation
| M3 shape corners | none 0; extra-small 4; small 8; medium 12; large 16; extra-large 28; full 9999px | MW _md-sys-shape.scss |
| Tailwind radius | xs 2; sm 4; md 6; lg 8; xl 12; 2xl 16; 3xl 24; 4xl 32 | tailwind theme page |
| M3 elevation levels (dp) | level0 0; level1 1; level2 3; level3 6; level4 8; level5 12 | MW _md-sys-elevation.scss |
| M3 key-shadow CSS (offset-y blur) | L0 0 0; L1 1px 2px; L2 1px 2px; L3 1px 3px; L4 2px 3px; L5 4px 4px (key shadow only; an ambient shadow layer also exists) | material-web elevation/internal/_elevation.scss comments |
| Tailwind shadows | 2xs 0 1px rgb(0 0 0/.05); xs 0 1px 2px 0 /.05; sm 0 1px 3px 0 /.1, 0 1px 2px -1px /.1; md 0 4px 6px -1px /.1, 0 2px 4px -2px /.1; lg 0 10px 15px -3px /.1, 0 4px 6px -4px /.1; xl 0 20px 25px -5px /.1, 0 8px 10px -6px /.1; 2xl 0 25px 50px -12px /.25 | tailwind theme page |
| Dark surfaces express elevation via surface-container tones (see sec. 1) rather than shadow | MCU container tones |

## 5. Motion
| M3 durations | short1 50; short2 100; short3 150; short4 200; medium1 250; medium2 300; medium3 350; medium4 400; long1 450; long2 500; long3 550; long4 600; extra-long1 700; 2 800; 3 900; 4 1000 ms | MW _md-sys-motion.scss |
| M3 easing | standard cubic-bezier(0.2,0,0,1); standard-accelerate (0.3,0,1,1); standard-decelerate (0,0,0,1); emphasized (0.2,0,0,1); emphasized-accelerate (0.3,0,0.8,0.15); emphasized-decelerate (0.05,0.7,0.1,1); legacy (0.4,0,0.2,1); linear (0,0,1,1) | MW motion file |
| Tailwind easing | in (0.4,0,1,1); out (0,0,0.2,1); in-out (0.4,0,0.2,1); no default duration in theme vars | tailwind theme page |
| prefers-reduced-motion | values no-preference | reduce; under reduce replace motion (scale/pan/transitions) with static or gentle opacity change | https://developer.mozilla.org/en-US/docs/Web/CSS/@media/prefers-reduced-motion |
| Which motion to keep under reduce | skill choice (unverified against a primary source): keep short state feedback (color, shadow), remove parallax, scroll reveals, and autoplay | MDN above says replace motion with static or gentle opacity; the keep/remove split is the skill's reading, not a cited rule |
| WCAG 2.3.3 (AAA) | interaction-triggered motion can be disabled unless essential | https://www.w3.org/TR/WCAG22/ |
| Which duration for which element size | unverified (no primary mapping retrieved) |

## 6. Accessibility minimums
| Target size, WCAG 2.5.8 (AA) | >= 24x24 CSS px; exceptions: spacing (24px circle rule), equivalent, inline, user-agent, essential | https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html |
| Target size, WCAG 2.5.5 (AAA) | >= 44x44 CSS px | https://www.w3.org/WAI/WCAG22/Understanding/target-size-enhanced.html |
| Material touch target | 48dp, 8dp between targets | https://m2.material.io/design/usability/accessibility.html (page summarized by WebFetch; single source) |
| Apple HIG hit target | 44x44 pt | https://developer.apple.com/design/human-interface-guidelines/accessibility (summarized by WebFetch; single source) |
| M3 container heights seen | filled button 40px | MW _md-comp-filled-button.scss |
| Focus visible 2.4.7 (AA) | keyboard focus indicator must be visible | WCAG 2.2 |
| Focus not obscured 2.4.11 (AA) | focused component not entirely hidden by author content | WCAG 2.2 |
| Focus appearance 2.4.13 (AAA) | indicator area >= 2 CSS px perimeter of the component; contrast >= 3:1 | WCAG 2.2 |
| M3 focus outline width | text field focus outline 2px (vs 1px default) | MW _md-comp-outlined-text-field.scss |
| Web interface rules | never outline-none without replacement; use :focus-visible; hover states increase contrast; honor reduced-motion; animate transform/opacity only; never transition: all; icon buttons need aria-label; labels on controls | https://raw.githubusercontent.com/vercel-labs/web-interface-guidelines/main/command.md (fetched via summarizer) |

## 7. AI-consumption rules (Anthropic frontend-design SKILL.md, main branch)
Source for all rows: https://raw.githubusercontent.com/anthropics/skills/main/skills/frontend-design/SKILL.md
Do:
- Identify the product/subject first; ground design in it; open with the most characteristic thing in the subject's world.
- Typography carries personality; pick faces specific to the brief; one family or two (clearly distinct); intentional weights/widths/spacing.
- Line length < 80 characters; serif body gets slightly more line-height.
- Palette plan of 4-6 named hex values; type roles; one-sentence layout descriptions (ASCII wireframes); then review the plan for generic defaults before coding.
- Structural devices (borders, numbering, dividers, labels) must encode information; numbering only for truly sequential content.
- Motion: non-user-triggered motion sparingly; one orchestrated moment (page load or one reveal).
- Copy: plain user words, active voice, specific CTA ("Save changes" not "Submit"), same action name across flow, sentence case, errors explain cause and fix.
- Spend boldness in one place; cut decoration that does not serve the brief.
- Quality floor: responsive, visible keyboard focus, reduced-motion respected, accessible contrast, harmonious palette.
Don't:
- Accent single words in headlines with italic, bold, or color.
- ALL CAPS labels; unnecessary labels/eyebrows above content.
- Fade-and-slide-up on every section; hover transitions on every card.
- Listed AI defaults: cream #F4F1EA + serif display + terracotta #D97757; near-black + acid green/vermilion; broadsheet hairline-rule dense columns; SaaS card kits with identical rounded corners + soft grey shadows; template chrome (tracked caps eyebrows, middle-dot meta strings, spaced em dashes, monospace labels, arrow-appended links).
Other published agent guideline docs found: Vercel Web Interface Guidelines (URL in sec. 6). Any others: not searched beyond that [unverified existence].

## 8. Skill defaults (choices this skill makes where no public rule exists)
These are NOT rules; they are the skill's own fixed choices, so a DESIGN.md can cite them as
`# chosen: skill default, sec.8` instead of inventing a value silently. Change them here,
not per file.
| Default | Value | Why this value |
| Japanese body line-height | body-lg 1.75; body-md 1.7 | CJK glyphs are square and dense; 1.5 (M3 Latin, sec.2) reads cramped. 1.75 already exceeds the 1.4.12 test value of 1.5, and the layout must still survive a user override down to 1.5. Source: skill choice, unverified against a CJK typography standard |
| Oversized wordmark (display-lg) | 96px base, weight 300, tracking -0.02em, line-height 1.0 | A name-as-hero needs tighter tracking than M3's -0.25px absolute (sec.2) gives at that size; -0.02em is the skill's choice |
| Section padding by spacing feel | tight 48px, normal 64px, airy 96px | Tailwind steps 12 / 16 / 24 (sec.3); the feel-to-step mapping is the skill's choice (sec.3 marks it unverified) |
| Radius scale by shape feel | sharp: 0 / 4 / 8 / 12; soft: 8 / 12 / 16 / 28; round: 16 / 28 / 28 / 9999 for sm / md / lg / xl | rows of the M3 shape scale (sec.4); the feel-to-row mapping is the skill's choice |
| Scroll reveal | translate 16px, 300ms, M3 standard-decelerate, stagger 60ms, max 5 children, once | 300ms = M3 medium2 (sec.5); offset and stagger are the skill's choice |
| Modal scrim opacity | 50% of `scrim` (black) | M3 gives scrim tone 0 (sec.1) and no opacity; 50% is the skill's choice |
| Nav height | 72px | between Material's 64 and a 80px marketing bar; the skill's choice |
| Case card width | 360px desktop, 320px tablet, 280px mobile | three cards plus 24px gaps take 1128px of a 1280 container, leaving a 150px slice of the fourth card visible so the rail reads as scrollable; the skill's choice |
| Container and side margins | container 1120px; page margin clamp(24px, 6vw, 96px) on each side; at 1440 the centered container leaves 160px a side, at 1280 80px | a 1280 container leaves only 80px a side at 1440, which reads as cramped; the skill's choice. Override only with a creative intent recorded in Intent |
| Section rhythm | desktop: every band below the hero shares one height = the tallest band's natural height rounded up to 8px (default 960px, a standard inquiry form), equal `section` padding, heading + content grouped in the vertical middle; phones: natural height. Adjacent bands alternate background; one alignment axis per section; a lone sentence joins a neighboring section; content under half the band height is enlarged, not the band shrunk | equal section heights give the page a steady visual rhythm; a 560px min-height with tiny centered content looked like it was floating, so the floor, axis, and content-size rules come with it; the skill's choice |
| Display lines and heading wrap | display-size lines use the full container; headings use `word-break: auto-phrase` + `text-wrap: balance`; a heading that still orphans in a narrow card steps down one type role on phones | without these rules a 57px statement in the 740px column and a card title at 390px each ended in a lone final kana and period; the skill's choice |
| Grid gutter | 24px | DADS asks 2 x body size (32px at 16px, sec.9); 24px is Tailwind step 6 (sec.3) and the gutter the sec.9 offset-column widths are computed with; the skill's choice |
| Line length cap for CJK | 40em | sec.2 gives "under 80 characters" for Latin (Anthropic); a full-width character is roughly two Latin characters wide; the skill's choice |

## 9. Baseline rules from the Digital Agency Design System (DADS)
Source: https://design.digital.go.jp/dads/ (beta v2.18.0, read 2026-10-06). These feed the
`## Baseline` section every DESIGN.md carries regardless of style. Cite as `DADS <page>`.
Where DADS gives no number (container px, page margin px, reading line length, section
padding, motion), the baseline falls back to sec.3 / sec.8 and says so.
| Rule | Value | DADS page |
| Fluid layout; never hide a needed horizontal scrollbar | `リキッドレイアウト`; `横スクロールバーを隠さない` | foundations/layout/accessibility/ |
| 12-column grid; content sits in column spans | 12 columns | foundations/layout/ |
| Reading / article / FAQ / form blocks use a centered offset column | 8 cols with 2-col offset, or 6 cols with 3-col offset (`記事や読み物など ... カラムオフセット`) | foundations/layout/ |
| Gutter | 2 x body text size (`本文の文字サイズの2倍`) | foundations/layout/ |
| Keep the page margin at narrow widths | `ページ幅が狭くなった場合も ... マージンの余白を確保` | foundations/layout/ |
| Breakpoint | 768px: below = mobile/tablet, at or above = desktop | foundations/layout/ |
| Spacing scale | 3 to 5 steps on a modular scale; same value for the same kind of element; larger for more important | foundations/spacing/ |
| Body and UI text size | 16 CSS px minimum; 14px only for footer and constrained UI (`基本的には使用しません`) | foundations/typography/ |
| Body line-height | at least 1.5 x; Std-16 170-175%, Std-17 170%, Std-18 160%, Std-20 to 32 150%, Dsp 140% | foundations/typography/ |
| Letter-spacing | 0 / 0.01em / 0.02em only | foundations/typography/ |
| Italic for Japanese | avoid | foundations/typography/ |
| Heading level vs size | defined separately; one h1 per page | components/heading/ |
| Contrast | text 4.5:1 always; non-text UI and borders 3:1; a drop shadow never counts as contrast | foundations/color/, foundations/elevation/ |
| Meaning never by color alone | links underlined; button importance by shape | foundations/link-text/, components/button/accessibility/ |
| Focus indicator | visible on every interactive element; DADS default is a yellow + black double ring (`いかなる場合も変更してはいけません` for government sites) | foundations/color/ |
| Touch target | 44 x 44 CSS px minimum, no overlap with neighbors | components/button/accessibility/ |
| Button heights | 56 / 48 / 36 / 28; one primary per screen; confirm right, cancel left (desktop); avoid disabled buttons | components/button/ |
| Form labels | visible label above the field; support text gives format or example; `※必須` / `※任意` marker; placeholder never used as the label (`プレースホルダーテキストを使用してはなりません`) | components/input-text/usage/ |
| Field width | matches the expected input length (`入力内容に相応しい長さ`); input height 48 Medium (56 / 36) | components/input-text/usage/ |
| Error text | static, begins with `＊`, states the cause and the fix; not announced via aria-live | components/input-text/usage/, /accessibility/ |
| Form bans | no maxlength, no copy or paste ban, no split email field, no disabled or readonly fields | components/input-text/accessibility/ |
| Choice controls | radio for single choice (5 or fewer options), checkbox left of its label, optional radio groups need a "none" option | components/radio/, /checkbox/, /select/ |
| FAQ accordion | 2 or more items, header = question, important information never hidden, no nesting, built on `<details>` + `<summary>` | components/accordion/, /disclosure/ |
| Elevation | default level 0; hover at least one level up; dialogs at least two | foundations/elevation/ |
| Radius steps | none 0 / small 8 / medium 12-16 / large 16-32 / full | foundations/corner-shapes/ |
| Accessibility target | JIS X 8341-3:2016 level AA (`適合レベルAAに準拠`) | webaccessibility/ |
Derived px for the offset columns in the default 1120 container with 24px gutters (sec.8):
column = (1120 - 11 x 24) / 12 = 71.33px; 8 columns + 7 gutters = 738.7px; 6 columns + 5
gutters = 548px. Rounded to the 4px grid: `content-wide` 740px, `content-narrow` 548px, both
centered. Recompute these two if the container changes.

## Derivation recipe
Input: {primary hex, secondary hex|none, heading font, body font, spacing feel tight|normal|airy, radius feel sharp|soft|round, mood words}
1. Palettes: convert primary hex to HCT (hue h). Primary palette = (h, chroma of source or 36), secondary = (h,16) or from secondary hex, tertiary = (h+60,24), neutral (h,6), neutral-variant (h,8), error (25,84). [sec.1 Tonal Spot rows]
2. Light-scheme roles by tone table in sec.1 (primary T40, on-primary T100, primary-container T90, on-primary-container T30, same for secondary/tertiary/error; surface T98; on-surface T10; surface-containers T100/96/94/92/90; outline T50; outline-variant T80; surface-variant T90; on-surface-variant T30; inverse rows).
3. Dark-scheme roles by the dark column (primary T80, on-primary T20, containers T30, on-containers T90, surface T6, on-surface T90, containers T4/10/12/17/22, outline T60).
4. Contrast verification: compute ratio for every on-X/X pair; require >= 4.5:1 text, >= 3:1 large text and UI boundaries (outline, focus ring). Do not round. [WCAG 1.4.3, 1.4.11]. If the user's exact brand hex fails, record it as a brand swatch and use the tone-derived role for text.
5. States: hover = overlay of the role's on-color at 8%; focus 12%; pressed 12%; dragged 16%; disabled content on-surface 38%, disabled container on-surface 12%. [MW state tokens]. Alternative step-based mapping: Radix steps 3/4/5, 9/10. [sec.1]
6. Focus ring: 2px, >= 3:1 against adjacent colors, never outline:none without replacement; use :focus-visible. [2.4.13, 2.4.7, MW 2px, Vercel]
7. Typography: set base 16px. Use the M3 role table (sec.2) as default sizes/line-heights; optional alternative = modular scale from typescale.com ratio on 16px base (ratio selection by mood is unverified; state it as a chosen input, not a rule). Heading face -> display/headline/title slots; body face -> body/label slots. Body line-height 1.5 for Latin; Japanese body uses the sec.8 default (1.75 / 1.7). Headings 1.0-1.25 ranges observed in M3/Tailwind. Max line length < 80 chars. Ensure layout survives 1.4.12 spacing overrides.
8. Spacing: base unit 4px (Tailwind --spacing). Scale steps 4,8,12,16,24,32,48,64,96. Feel mapping: the sec.8 skill default (tight 48 / normal 64 / airy 96), cited as `chosen: skill default, sec.8`.
9. Radii: sharp = M3 none/extra-small (0/4); soft = small/medium/large (8/12/16); round = large/extra-large/full (16/28/9999). Mapping of feel to scale rows is a choice over sourced scales [M3 shape, Tailwind radius].
10. Elevation: levels 0-5 = 0,1,3,6,8,12 dp; CSS via the Tailwind shadow-xs..xl rows or M3 key-shadow (sec.4). In dark mode raise surface-container tone with level in addition to shadow.
11. Breakpoints: Tailwind 640/768/1024/1280/1536, or window classes 600/840/1200/1600. Container max-width: 1120px skill default (sec.8); Tailwind 1280 (7xl) or Bootstrap 1320 only when Intent records a reason.
12. Motion: durations from M3 tokens (feedback 50-200ms short; transitions 250-400ms medium; larger/page 450-600ms long); easing standard (0.2,0,0,1), decelerate for enter (0,0,0,1), accelerate for exit (0.3,0,1,1); emphasized for hero moments. Duration-to-element mapping is unverified. Add @media (prefers-reduced-motion: reduce) removing decorative motion, keeping feedback. Animate only transform/opacity; no transition: all.
13. Accessibility block: contrast 4.5/3/3; min target 24x24 (AA) with 44 (WCAG AAA / Apple) and 48 (Material) as comfortable defaults; focus rules; reflow 320px; resize 200%; text-spacing survival; reduced motion.
14. Do/Don't block: copy sec.7 rows verbatim; add the mood words as the "memorable thing" (spend boldness once).
