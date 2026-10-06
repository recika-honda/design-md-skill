# DESIGN.md output template, token sourcing, and the richness bar

Read by SKILL.md Step 5. Format follows the Google design.md spec (alpha):
https://github.com/google-labs-code/design.md (docs/spec.md). Front matter holds tokens,
the body holds prose and rules, `{group.key}` references a token. The linter rejects
duplicate headings and preserves unknown sections and token groups, which is what lets
this skill add `elevation`, `motion`, `breakpoints` groups and its own body sections.

Language: English body. The `Brief (Japanese)` section is the signed-off brief, verbatim.

## The richness bar

A finished file is 350 to 700 lines (a fully filled file lands near the top of that range;
the ceiling exists to stop padding, not to cut substance). The reference points are the Airbnb (545 lines),
Stripe (487) and Linear (548) files in VoltAgent/awesome-design-md: 13-23 color roles,
13-19 type roles, 15-38 component entries with state siblings, a responsive table, and
either Do's and Don'ts plus an Iteration Guide (Stripe, Linear) or Known Gaps (Airbnb,
Linear). This template requires all three closing sections.
Thin output is a failure even when every line in it is correct. Concretely, the file must
have, at minimum:

- 24 color roles (brand, surfaces, text, borders, semantic, state variants, scrim).
- 9 typography roles across display / headline / title / body / label.
- Spacing scale of 8 steps plus `section`, `gutter`, `container`.
- Elevation levels 0 to 5 with CSS shadow values.
- Motion durations (short / medium / long) and 3 easings.
- Breakpoints (4) and a responsive table with one row per breakpoint.
- Every component the user picked, plus the 6 base components every site needs
  (button-primary, button-secondary, text-input, card, nav, footer), each with hover,
  focus, active, disabled where the element is interactive.
- Interaction state matrix, Motion, Imagery & Iconography, Voice & Content,
  Accessibility, Do's and Don'ts, Known Gaps: none may be skipped or one-lined.

## Token sourcing: three tiers, never a fourth

Every token value carries its tier in a trailing comment.

| Tier | When | Comment form |
|---|---|---|
| chosen | the user picked this attribute on a site, or typed a value or preference | `# chosen: site 2 (airbnb.com)` or `# chosen: user` |
| derived | computed from chosen values by a public rule in `references/derivation-rules.md` | `# derived: <rule>, sec.N` e.g. `# derived: M3 tone T90, sec.1` |
| open | no chosen input and no rule can bridge the gap | in `colors` / `typography` / `spacing` / `rounded`: OMIT the key and leave a comment line `# <key>: open (TODO: decide), see Known Gaps` (the linter rejects a placeholder value); in body prose: the literal `TODO: decide` |

Rules:
- Derivation is mandatory, not optional. If a chosen primary color exists, the full role set
  (containers, on-colors, surfaces, outlines, state overlays, dark scheme) is derived. A file
  that leaves derivable tokens as `TODO` fails the richness bar.
- Derivation never overrides a chosen value. A chosen hex stays as chosen even if the rule
  would compute a slightly different tone; the rule fills the roles around it. If the
  chosen hex fails WCAG contrast in a text role, keep it as a brand swatch and derive a
  passing tone for the text role, and say so in the Colors body.
- Rows marked "unverified" in derivation-rules.md are inputs the skill chooses and names as
  choices (`# chosen: skill default, ratio 1.25`), never cited as rules.
- Two sites chosen for the same attribute: the user's free text decides; absent that, ask one
  question before writing. Never average or blend.
- Component tokens reference other tokens with `{colors.x}` syntax; a raw hex inside
  `components` is an error. The spec's normative component properties are
  `backgroundColor`, `textColor`, `typography`, `rounded`, `padding`, `size`, `height`,
  `width`; others (`borderColor`, `borderWidth`, `shadow`) are preserved with a lint
  warning, which is acceptable. States are sibling entries (`button-primary-hover`,
  `-active`, `-disabled`, `text-input-focus`), the pattern the richest public files use.
- `{ref}` syntax resolves only into the spec's groups (`colors`, `typography`, `spacing`,
  `rounded`). A reference into `elevation`, `motion`, or `breakpoints` is a lint ERROR
  inside `components`: write the literal value there with a comment naming the level
  (`# = elevation.level2`). In body prose the `{elevation.level2}` form is fine.
- A visually transparent component gets `backgroundColor: "{colors.surface}"` (its usual
  host surface), not `transparent`, so the linter's contrast check has a real pair.
- Expected lint warnings, accepted and listed in Known Gaps: disabled-state contrast
  (Material 38% / 12% is low by design), a decorative hero wordmark, the non-normative
  component properties, and the extra token groups. Errors are never accepted.
- Colors are lowercase hex in quotes. Font families are plain names in YAML with the fallback
  stack in the body prose.
- The body never names a reference site in Overview through Accessibility. Attribution lives
  in `Sources` and `Intent`. The consuming AI should read the system as the user's own.

## Skeleton

Fill every `<...>`. Delete no section. Where a section has no chosen input, it is still
written from derived values and says in one sentence that it is derived, not chosen.

```md
---
version: alpha
name: <site name or working title from Step 0>
description: <one line: what the site is, for whom, primary goal>
colors:
  # brand
  primary: "<hex>"                    # chosen|derived|open
  on-primary: "<hex>"                 # derived: M3 tone T100, sec.1
  primary-container: "<hex>"          # derived: M3 tone T90, sec.1
  on-primary-container: "<hex>"       # derived: M3 tone T30, sec.1
  primary-hover: "<hex>"              # derived: state layer 8% on-color, sec.1
  primary-active: "<hex>"             # derived: state layer 12%, sec.1
  primary-disabled: "<hex>"           # derived: on-surface 12%, sec.1
  secondary: "<hex>"
  on-secondary: "<hex>"
  secondary-container: "<hex>"
  on-secondary-container: "<hex>"
  tertiary: "<hex>"
  on-tertiary: "<hex>"
  # surfaces
  surface: "<hex>"                    # derived: neutral T98, sec.1
  surface-dim: "<hex>"
  surface-bright: "<hex>"
  surface-container-low: "<hex>"
  surface-container: "<hex>"
  surface-container-high: "<hex>"
  on-surface: "<hex>"                 # derived: neutral T10, sec.1
  on-surface-variant: "<hex>"
  # borders
  outline: "<hex>"                    # derived: neutral-variant T50, sec.1
  outline-variant: "<hex>"
  # semantic
  error: "<hex>"
  on-error: "<hex>"
  error-container: "<hex>"
  success: "<hex>"                    # open or chosen; no M3 rule
  warning: "<hex>"
  # overlays
  scrim: "<hex>"                      # chosen: skill default, neutral T0 at 50%, sec.8
  focus-ring: "<hex>"                 # derived: >= 3:1 vs adjacent, sec.6
typography:
  display-lg:
    fontFamily: <heading family>       # chosen|open
    fontSize: <px>                     # derived: M3 display-medium 45px or scale ratio, sec.2
    fontWeight: "<100-900>"
    lineHeight: <unitless or px>
    letterSpacing: <em>
  display-md: {...}
  headline-lg: {...}
  headline-md: {...}
  title-lg: {...}
  title-md: {...}
  body-lg: {...}                       # 16px / 1.5 unless chosen otherwise, sec.2
  body-md: {...}
  label-lg: {...}
  label-md: {...}                      # 14px minimum (DADS: nothing readable below 14), sec.9
  caption: {...}                       # 14px, footer and constrained UI only, sec.9
rounded:
  none: 0
  sm: <px>                             # derived: M3 shape scale by feel, sec.4
  md: <px>
  lg: <px>
  xl: <px>
  full: 9999px
spacing:
  base: 4px                            # derived: Tailwind --spacing, sec.3
  xxs: 2px
  xs: 4px
  sm: 8px
  md: 12px
  lg: 16px
  xl: 24px
  xxl: 32px
  xxxl: 48px
  section: <px>                        # chosen feel -> 48|64|96, stated as skill default
  gutter: <px>
  container: 1120px                    # chosen: skill default, sec.8 (override only with a creative intent in Intent)
  page-margin: clamp(24px, 6vw, 96px)  # chosen: skill default, sec.8; side margin outside the container
  content-wide: 740px                  # derived: DADS 8-col offset column in the container, sec.9; reading, FAQ, forms
  content-narrow: 548px                # derived: DADS 6-col offset column, sec.9; single-column forms, short statements
  section-height: 960px                # chosen: skill default, sec.8; desktop band height = tallest band
elevation:
  level0: none
  level1: "<css shadow>"               # derived: Tailwind shadow-sm, sec.4
  level2: "<css shadow>"
  level3: "<css shadow>"
  level4: "<css shadow>"
  level5: "<css shadow>"
motion:
  duration-short: <ms>                 # derived: M3 short4 200ms, sec.5
  duration-medium: <ms>
  duration-long: <ms>
  easing-standard: cubic-bezier(0.2, 0, 0, 1)
  easing-enter: cubic-bezier(0, 0, 0, 1)
  easing-exit: cubic-bezier(0.3, 0, 1, 1)
breakpoints:
  sm: 640px                            # derived: Tailwind, sec.3 (or chosen from site)
  md: 768px
  lg: 1024px
  xl: 1280px
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.label-lg}"
    rounded: "{rounded.md}"
    padding: "{spacing.md} {spacing.xl}"
    height: <px>                       # >= 44px, sec.6
  button-primary-hover:
    backgroundColor: "{colors.primary-hover}"
  button-primary-active:
    backgroundColor: "{colors.primary-active}"
  button-primary-disabled:
    backgroundColor: "{colors.primary-disabled}"
    textColor: "{colors.on-surface-variant}"
  button-secondary: {...}
  button-secondary-hover: {...}
  text-input: {...}
  text-input-focus:
    borderColor: "{colors.focus-ring}"
    borderWidth: 2px
  text-input-error: {...}
  card: {...}
  card-hover: {...}
  nav: {...}
  footer: {...}
  <one entry per component the user picked, with its states>
---

## Agent Guide
<8-12 lines addressed to the AI that will build the site. Reading order: Baseline first,
then Intent, then tokens, then Components. Priority when rules conflict: Baseline > Do's
and Don'ts > Intent > tokens > body prose. How to treat `TODO: decide` (ask the owner, never guess). Which token groups are
chosen vs derived, so the AI knows what is sacred and what is adjustable. One line on the
one quality to protect above all others.>

## Baseline
Rules that hold for this site whatever the style says. They come from the Digital Agency
Design System (DADS, https://design.digital.go.jp/dads/) and WCAG 2.2; a style rule that
conflicts with a baseline rule loses. Priority: Baseline > Do's and Don'ts > Intent >
tokens > prose.
### Layout
- Fluid layout at every width; a needed horizontal scrollbar is never hidden. (DADS layout)
- Content lives on a 12-column grid inside `{spacing.container}`, centered, with
  `{spacing.gutter}` side margins kept at every width including the narrowest. (DADS layout)
- Reading blocks (statements, long copy, FAQ, forms, articles) never span the full
  container: they sit in a centered column of `{spacing.content-wide}` (DADS 8-col offset)
  or `{spacing.content-narrow}` (DADS 6-col offset). Their rules, dividers, and fields end
  at that column's edge, never at the page edge or at a left-aligned text measure.
- Grids reduce column counts at breakpoints; visual order equals reading order. (DADS)
- Generous side margins by default: the container is `{spacing.container}` with
  `{spacing.page-margin}` kept on each side, so cards and headings never sit near the
  screen edge. (skill default, sec.8)
- Uniform section height by default: on desktop (1024px and wider) every
  band below the hero shares one height, `{spacing.section-height}`, set to the tallest
  band's natural height rounded up to the 8px grid (skill default 960px, the height of a
  standard inquiry form). Each band keeps `{spacing.section}` padding and holds its heading
  and content together as one group in the vertical middle. Phones keep natural height.
  Because short content in a tall band can read as floating, the band must still have a
  visible floor (the alternating background below) and its heading and content must sit
  on one axis; if a band's content is under half the height, enlarge the content (bigger
  cards, an image, more items) rather than shrink the band. (skill default, sec.8)
- Every band has a visible floor: adjacent bands alternate background (`surface` /
  `surface-container-low`), and two bands of the same color never touch. If the page order
  makes that impossible, merge the shorter band into its neighbor. (skill default, sec.8)
- Two alignment axes, one per section: grid sections (cards, rails, multi-column) align to
  the container's left edge; reading sections (statements, long copy, FAQ, forms) put their
  heading AND their content in the centered `{spacing.content-wide}` column. A section never
  mixes the two, and every section uses one of them. (skill default, sec.8)
- A lone sentence (a statement, a call to action line) is not a section of its own: it opens
  or closes a neighboring section. (skill default, sec.8)
- These defaults change only when Intent records a deliberate creative reason (for
  example a full-bleed editorial layout); the reason is written there, not implied.
- Display-size lines (display-md and up, short statements) are not reading blocks: they
  use the full container, never the content column, so a one-line statement stays on one
  line. (skill default, sec.8)
- Japanese headings wrap at phrase boundaries with balanced lines (`word-break:
  auto-phrase; text-wrap: balance`); no heading may end with a one- or two-character
  orphan such as a lone final kana and period at any width. Where a narrow card cannot
  avoid it, the heading steps down one type role on phones. (skill default, sec.8)
### Spacing
- One modular scale of 3 to 5 working steps; the same kind of element always gets the same
  gap; the more important the element, the larger its surrounding gap. (DADS spacing)
### Typography
- Body and UI text 16px or larger; 14px only in the footer or constrained UI; nothing
  readable below 14px. Line-height at least 1.5 for body (this file: `{typography.body-lg}`).
  Letter-spacing only 0, 0.01em, or 0.02em. No italic for Japanese. One h1 per page;
  heading level and size are independent. (DADS typography, heading)
### Color and contrast
- Text 4.5:1 against its background, always; non-text UI and borders 3:1; a drop shadow
  never counts as contrast. Meaning is never carried by color alone: links are underlined
  or otherwise marked, button importance is shown by shape, states by text or icon. (DADS
  color, link-text, elevation)
### Interaction
- Every interactive element shows a visible focus indicator at 3:1 or better; targets are
  44 x 44 CSS px minimum with no overlap. Hover raises elevation at least one level;
  dialogs sit at least two levels up. Decorative motion stops under
  `prefers-reduced-motion`. (DADS button accessibility, elevation; WCAG 2.4.7, 2.5.8)
### Buttons
- Heights from 56 / 48 / 36 / 28. One primary per screen; secondary at most three per
  context; confirm on the right, cancel on the left on desktop. Disabled buttons are
  avoided; show what is needed instead. (DADS button)
### Forms
- Visible label above every field; support text gives the format or an example; required
  and optional are marked with words (`※必須` / `※任意`); a placeholder is never the label.
  Field width matches the expected input (an email field is not a page-wide bar); the
  whole form sits in the reading column. Errors are static text that begins with `＊`
  and states the cause and the fix, tied with `aria-describedby`, never via `aria-live`.
  No `maxlength`, no copy or paste bans, no split email fields, no disabled or readonly
  fields. Radio for single choice up to five options; checkbox left of its label. (DADS
  input-text, radio, checkbox, select)
### Disclosure
- FAQ and similar use an accordion of two or more items built on `<details>` and
  `<summary>`, header = the question, nothing important hidden inside, no nesting. (DADS
  accordion, disclosure)
### Target
- JIS X 8341-3:2016 / WCAG 2.2 level AA. (DADS webaccessibility)

## Overview
<5-8 sentences. What the site is for, who visits, the mood in everyday words, how the page
should feel at first glance and after a minute, the one thing a visitor should remember.
No site names.>
**Key Characteristics:**
- <5-7 bullets, one trait each: e.g. one accent color per screen; flat surfaces, one shadow
  tier; airy section bands over dense card grids; sentence-case copy; no decorative motion>

## Colors
### Brand & Accent
<role of primary / secondary / tertiary; where each appears; how much of the page is
accent (a percentage or "one element per screen")>
### Surfaces
<background strategy: flat white, layered greys, dark bands; which surface-container role
goes where (page, card, sheet, modal)>
### Text
<on-surface for body, on-surface-variant for secondary, when inverse text appears>
### Borders & Dividers
<outline vs outline-variant usage; hairline weight; when borders are replaced by spacing>
### Semantic
<error / success / warning usage; never color alone (pair with icon or text)>
### States
<hover 8%, focus 12%, pressed 12%, disabled 38%/12% as applied; cite sec.1>
### Dark Scheme
<either the derived dark roles (M3 dark column) in a short table, or "Light only by
decision; dark scheme derivable on request" if the user chose light only>
### Contrast Verification
<a table: pair, ratio, pass/fail for every on-X/X pair and for focus-ring vs surface>

## Typography
### Families
<heading family, body family, why they fit the mood; fallback stacks; loading source if
Google Fonts; one or two families only>
### Hierarchy
<table: role, size, line-height, weight, tracking, where used>
### Principles
<line length under 80 chars; sentence case; no accented single words in headlines; serif
body gets more line-height; what gets bold and what never does>
### Substitutes
<if the chosen family is proprietary (SF Pro, Airbnb Cereal), the closest open family and
the metric differences to expect>

## Layout
### Spacing System
<base unit; the scale; what each step is for (card padding, gutters, section bands); the
section rhythm (alternating backgrounds, dividers, or whitespace only)>
### Grid & Container
<container width; column counts per breakpoint; gutter; any asymmetric layout (sidebar,
sticky rail)>
### Page Structure
<numbered list, top to bottom, one line per section: name, layout (columns, alignment),
background surface, the component it uses, the chosen source if any>
### Whitespace Philosophy
<2-4 sentences: where the page breathes and where it is dense, and why that contrast
serves the goal from Step 0>

## Elevation & Depth
<how many shadow tiers exist and which elements use each; borders vs shadows; dark scheme
uses surface tone instead of shadow; modal scrim value>

## Shapes
<radius per element class: buttons, inputs, cards, images, chips, modals; whether radii are
uniform or deliberately mixed; `{rounded.*}` references>

## Components
### Buttons
<primary / secondary / tertiary: size, padding, radius, label style, every state in one
line each, where each variant is used>
### Inputs & Forms
<text input at rest / focus / error / disabled; label placement; helper text; validation
tone>
### Cards
<padding, radius, border or shadow, image ratio, hover behavior, text hierarchy inside>
### Navigation
<height, sticky or not, logo placement, link style, active state, mobile collapse pattern>
### Footer
<columns, background, link style, legal band>
### <Picked component 1, e.g. Hero>
<what it is, layout, tokens by reference, behavior; which site inspired it (number only)>
### <Picked component 2...>

## Interaction States
<a matrix table: component x state (rest, hover, focus-visible, active, disabled, loading,
error) with the token or rule in each cell; one line on cursor and transition for each>

## Motion
<what animates (transform and opacity only); durations per class (feedback short,
transitions medium, page or hero long); easings; the one orchestrated moment, if any;
`prefers-reduced-motion` behavior: remove decorative motion, keep feedback; never
`transition: all`>

## Responsive Behavior
| Name | Width | Key Changes |
|---|---|---|
| Mobile | < {breakpoints.sm} | <nav collapse, column counts, hero crop, CTA placement> |
| Tablet | ... | ... |
| Desktop | ... | ... |
| Wide | > {breakpoints.xl} | <content cap, gutters absorb> |
### Collapsing Strategy
<grids reduce columns never reflow rows; what becomes a sheet or bottom bar; sticky rail
behavior; the narrow-width nav rule (what leaves the bar below N px); mobile sizes for
display-lg and display-md (clamp() ranges) and mobile padding for bands and cards>
### Touch Targets
<minimum 44px for primary actions (sec.6), 24px absolute floor, spacing between targets>

## Imagery & Iconography
<photo style (people vs product, color treatment, crop ratios), illustration policy, icon
set (one set only, stroke weight, size steps), logo clear space; what is forbidden (stock
cliches, mixed icon sets)>

## Voice & Content
<tone in three adjectives; sentence case; active voice; CTA wording rule (specific verbs);
error message shape (cause + fix); microcopy length limits; language and formality level
for the audience from Step 0>

## Accessibility
<contrast minimums applied (4.5 / 3 / 3); focus ring spec; target sizes; reflow at 320px;
200% zoom; text-spacing survival; reduced motion; color never the sole signal; alt text
policy; heading order>

## Do's and Don'ts
### Do:
- **Do** <rule derived from a chosen attribute>
- **Do** <...> (4-8 lines)
### Don't:
- **Don't** <rule from the user's "would not imitate" answers>
- **Don't** <generic-AI-look bans from derivation-rules sec.7 that apply to this mood>
- **Don't** <...> (4-8 lines)

## Intent
<English, 8-15 lines. Industry, goal, audience from Step 0. For each bundle: what the user
chose to take and from which source number, what they explicitly rejected, what stays
open. Which token groups are chosen vs derived. This section is why the file exists; write
it so an AI with no other context could rebuild the choices.>

## Sources
1. <domain of site 1> : taken: <one line> ; rejected: <one line or "nothing">
2. <domain of site 2> : ...
3. <domain of site 3> : ...
Rules cited for derived values: `references/derivation-rules.md` of the design-md skill
(Material 3 color and type roles, WCAG 2.2, Tailwind scales, Anthropic frontend-design).

## Iteration Guide
<6-10 lines for the owner and the AI: which token to change for which effect (warmer: shift
`primary` hue and re-derive; calmer: raise `spacing.section` one step and drop one accent
use; denser: step spacing down, keep `rounded`); what must be re-derived after a change
(on-colors and the contrast table after any color change; line-heights after any size
change); what never changes without a new interview (the Intent section)>

## Known Gaps
<bullet list of what this file does not cover and why: states not observable, dark scheme
not chosen, components the site will need that no reference showed, every `TODO: decide`
with the question the owner must answer>

## Brief (Japanese)
<the signed-off brief, verbatim, including its title line>
```

## Filling order

0. The Baseline section is copied from the skeleton verbatim (it is not style-dependent);
   only the token references inside it are resolved. Then check every later section
   against it: a style choice that breaks a baseline rule is rewritten, not kept.
   Derived values are snapped to the Baseline, not left at their source rule's value:
   letter-spacing to 0 / 0.01em / 0.02em (M3 tracking values are snapped, display roles
   get 0; only an `aria-hidden` wordmark may go negative); readable sizes to 14px or
   more; FAQ written as `<details>` / `<summary>`; required marks written `※必須` /
   `※任意`; error text starting with `＊`. Builders follow a style section over the
   Baseline when the two disagree, so the snapping happens here.
1. Chosen tokens first, from the interview picks and `facts.txt`.
2. Derived tokens, group by group, following the recipe at the end of
   `references/derivation-rules.md` (palettes, roles, contrast check, states, type scale,
   spacing, radii, elevation, breakpoints, motion).
3. Layout and Page Structure from the WebFetch section list plus picks.
4. Components: the 6 base ones, then every picked one, each with states.
5. Interaction States matrix, Motion, Responsive, Imagery, Voice, Accessibility.
6. Do's and Don'ts from picks, rejections, and sec.7 bans that fit the mood.
7. Agent Guide and Overview last, so they summarize rather than promise.
8. Intent, Sources, Iteration Guide, Known Gaps, Brief.

## Consistency self-check (cross-section invariants)

Each pair below is a contradiction that can live between two sections that are
individually fine. Check every pair below before writing; a builder follows the
priority order (Baseline > Do's and Don'ts > Intent > tokens > prose) and will silently pick one side.

- Nav width budget: at 320px, logo + primary CTA (label at label-lg plus 2 x 24px padding)
  + menu button + gaps must fit inside 320 - 2 x gutter. If not, write the narrow-width rule
  yourself (CTA moves into the sheet below N px, or a shorter mobile label).
- "Once per page" rules vs semantic and state uses: if the accent may appear once, say
  where success, selected, and highlighted states go instead, or exempt them explicitly.
- Elevation prose vs Interaction States matrix: every level named in the matrix is a level
  the Elevation section says is in use, and vice versa.
- Page Structure heading sizes vs Hierarchy table: a section title size named in Page
  Structure matches the Hierarchy row for section titles, or the exception is stated.
- Band rhythm vs band assignments: if bands "alternate", the Page Structure list actually
  alternates; otherwise describe the real rhythm (two low bands in a row is allowed, say so).
- Box arithmetic: for every component with a fixed height, height >= 2 x vertical padding
  + line-height x font-size. Inputs with body-lg at 1.75 need 52px or 8px padding.
- Focus treatment per class: buttons and links get the ring + offset; inputs get the
  border change; say which, so the Accessibility sentence and the component rules agree.
  Also state what happens when a field is both invalid and focused.
- Hover motion wording: "no hover animation" bans transform; say whether a shadow or
  color change on hover is allowed (it usually is) so card-hover and the Don't agree.
- One trigger per behavior: the nav hairline, the sheet breakpoint, and the collapse rule
  each appear once, or every mention uses the same value.
- Mobile rules for every display size and every padded band: display-md and display-lg
  get a clamp() or a mobile size; accent bands and cards get a mobile padding; section
  padding has a mobile value.
- Whole-card links: a card that "is the link" contains no second interactive element, or
  the inner button is the only link and the card is its hit area.
- Rails: enough items that the last one is cut at the widest breakpoint (four or more
  for a 1280 container with 360px cards), and a stated destination for each item or an
  explicit "cards are not links".
- Single-page sites: say how the active nav state is driven (scroll position) or drop it.

## Self-check before writing the file

- Line count between 350 and 700. Under 350: a section was one-lined; fix it.
- Baseline present verbatim and no later section contradicts it (reading blocks centered in
  content-wide or content-narrow; no text under 14px; placeholders never labels).
- Every token has a tier comment (chosen / derived). Open tokens are absent from the
  token map, named in a comment line, and each one appears in Known Gaps with its
  question.
- No hex value inside `components`; references only.
- Contrast table present, every text pair >= 4.5:1 or explicitly noted as large text 3:1.
- No reference site named outside `Sources` and `Intent`.
- No copied sentence, image URL, or logo from any site.
- Heading set matches the skeleton exactly once each.
- The Brief section is byte-identical to the text the user said OK to.
