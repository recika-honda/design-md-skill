#!/usr/bin/env bash
# check-design-md.test.sh: regression tests for skills/design-md/scripts/check-design-md.sh
#
# Run:  bash tests/check-design-md.test.sh
#
# Works in both trees that ship this file (private project and exported repo), like
# fetch-site.test.sh. Offline: every case runs against tests/fixtures/check-design-md/
# or a copy of it mutated with one targeted change, so each failing case isolates one rule.
#
# Output: one "ok - <name>" / "not ok - <name>" line per case, the validator's output under
# each failure, then a summary line. Exit 0 only when every case passed.
#
# Portability: bash 3.2+ with BSD or GNU tools (stock macOS works).

set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd -P)
script=""
for candidate in \
  "$root/.claude/skills/design-md/scripts/check-design-md.sh" \
  "$root/skills/design-md/scripts/check-design-md.sh"; do
  if [ -f "$candidate" ]; then
    script=$candidate
    break
  fi
done
if [ -z "$script" ]; then
  printf 'check-design-md.test.sh: check-design-md.sh not found under %s\n' "$root" >&2
  exit 2
fi

fixtures="$root/tests/fixtures/check-design-md"
good="$fixtures/good.md"
picks="$fixtures/picks.txt"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

passed=0
failed=0

# expect <name> <expected exit> <pattern expected in output> -- <validator args...>
expect() {
  local name=$1 want_exit=$2 want_text=$3
  shift 4
  local out got_exit=0
  out=$(bash "$script" "$@" 2>&1) || got_exit=$?
  if [ "$got_exit" = "$want_exit" ] && printf '%s\n' "$out" | grep -qF -- "$want_text"; then
    printf 'ok - %s\n' "$name"
    passed=$((passed + 1))
  else
    printf 'not ok - %s\n  expected exit %s and output containing: %s\n  got exit %s, output:\n' \
      "$name" "$want_exit" "$want_text" "$got_exit"
    printf '%s\n' "$out" | sed 's/^/    /'
    failed=$((failed + 1))
  fi
}

# mutate <name> <sed expression>: copy good.md with one change, print the copy's path.
mutate() {
  local path="$work/$1.md"
  sed "$2" "$good" >"$path"
  printf '%s' "$path"
}

# picks_with <name> <extra line>...: copy picks.txt with the lines appended, print the path.
picks_with() {
  local path="$work/$1.txt"
  shift
  cp "$picks" "$path"
  printf '%s\n' "$@" >>"$path"
  printf '%s' "$path"
}

# picks_edit <name> <sed expression> [extra line...]: copy picks.txt with one change and the
# lines appended, print the path.
picks_edit() {
  local path="$work/$1.txt" expr=$2
  shift 2
  sed "$expr" "$picks" >"$path"
  if [ "$#" -gt 0 ]; then printf '%s\n' "$@" >>"$path"; fi
  printf '%s' "$path"
}

# ---- passing inputs ----
expect "good fixture passes with picks" 0 "check: PASS (0 failures); chosen 2, derived 9, defaulted 3, open 1" -- "$good" "$picks"
expect "good fixture passes without picks, with a warning" 0 "WARN: no picks.txt given" -- "$good"

# ---- tier comments ----
expect "token without a tier comment fails" 1 "spacing.container: no tier comment" -- \
  "$(mutate no-comment 's|^  container: 1120px .*|  container: 1120px|')" "$picks"
expect "nested token failure names the full path" 1 "typography.body-lg.fontSize: no tier comment" -- \
  "$(mutate nested 's|^    fontSize: 16px .*|    fontSize: 16px|')" "$picks"
expect "unknown tier word fails" 1 "comment does not start with chosen:, derived:, or defaulted:" -- \
  "$(mutate bad-tier 's|# defaulted: container and side margins, sec.8|# guessed: looks right|')" "$picks"
expect "skill default labeled chosen fails" 1 "a skill default labeled chosen" -- \
  "$(mutate forged 's|# defaulted: container and side margins, sec.8|# chosen: skill default, sec.8|')" "$picks"
expect "derived citing only sec.8 fails" 1 "derived cites no public rule" -- \
  "$(mutate derived-sec8 's|# defaulted: container and side margins, sec.8|# derived: container, sec.8|')" "$picks"
expect "derived citing a section that does not exist fails" 1 "derived cites no public rule" -- \
  "$(mutate derived-sec18 's|# derived: M3 short4, sec.5|# derived: my taste, sec.18|')" "$picks"
expect "a quoted phrase inside a tier comment is still read" 0 "check: PASS" -- \
  "$(mutate quoted-comment 's|# derived: M3 short4, sec.5|# derived: "M3 short4", sec.5|')" "$picks"
expect "flow-map token fails" 1 "typography.body-lg: flow map" -- \
  "$(mutate flow '/^  body-lg:$/,/^    lineHeight/d; s|^typography:$|typography:\
  body-lg: {fontSize: 16px, lineHeight: 1.75}   # derived: M3 body-large, sec.2|')" "$picks"
expect "flow-sequence token fails" 1 "rounded.none: flow map or list" -- \
  "$(mutate flow-seq 's|^  none: 0px .*|  none: [0, 1]                        # derived: M3 shape none, sec.4|')" "$picks"
expect "derived without a citation fails" 1 "derived without a rule citation" -- \
  "$(mutate derived-bare 's|# derived: M3 short4, sec.5|# derived: M3 short4|')" "$picks"
expect "defaulted without sec.8 fails" 1 "defaulted must cite sec.8" -- \
  "$(mutate defaulted-bare 's|# defaulted: container and side margins, sec.8|# defaulted: looks calm|')" "$picks"
expect "defaulted for a pick on a listed site passes without sec.8" 0 "check: PASS" -- \
  "$(mutate defaulted-pick 's|# defaulted: container and side margins, sec.8|# defaulted: 1120px; for pick "only four items in the top menu", site 1|')" "$picks"
expect "defaulted for a pick on a site picks.txt does not list fails" 1 "defaulted for a pick on site 2, which picks.txt does not list" -- \
  "$(mutate defaulted-pick-site2 's|# defaulted: container and side margins, sec.8|# defaulted: 1120px; for pick "only four items in the top menu", site 2|')" "$picks"
expect "defaulted for a pick without a site fails" 1 "write the pick as for pick" -- \
  "$(mutate defaulted-pick-nosite 's|# defaulted: container and side margins, sec.8|# defaulted: 1120px; for pick "only four items in the top menu"|')" "$picks"
expect "defaulted for a pick quoting no option on the site fails" 1 \
  "defaulted for pick \"anything at all\", site 1, but no picked option on site 1 has that text" -- \
  "$(mutate defaulted-pick-invented 's|# defaulted: container and side margins, sec.8|# defaulted: 1120px; for pick "anything at all", site 1|')" "$picks"
expect "defaulted for a pick quoting a declined option fails" 1 "but that option was offered there and not picked (a decline line)" -- \
  "$(mutate defaulted-pick-declined 's|# defaulted: container and side margins, sec.8|# defaulted: 1120px; for pick "one narrow centered column with wide side margins", site 1|')" "$picks"
expect "defaulted for a pick quote is compared after trimming" 0 "check: PASS" -- \
  "$(mutate defaulted-pick-trim 's|# defaulted: container and side margins, sec.8|# defaulted: 1120px; for pick "  only four items in the top menu ", site 1|')" "$picks"
expect "defaulted for a pick quoting a said answer passes" 0 "check: PASS" -- \
  "$(mutate defaulted-pick-said 's|# defaulted: container and side margins, sec.8|# defaulted: 1120px; for pick "ページ幅は広すぎないように", site 1|')" \
  "$(picks_with defaulted-pick-said 'said 1 structure - | ページ幅は広すぎないように')"
expect "without picks.txt a pick quote is checked for form only" 0 "check: PASS" -- \
  "$(mutate defaulted-pick-nopicks 's|# defaulted: container and side margins, sec.8|# defaulted: 1120px; for pick "anything at all", site 1|')"
expect "chosen naming neither site nor user fails" 1 "chosen must name" -- \
  "$(mutate chosen-vague 's|# chosen: site 1 (example.com)|# chosen: primary on accent|')" "$picks"

# ---- provenance against picks.txt ----
expect "chosen from a site picks.txt does not list fails" 1 "chosen from site 2, which picks.txt does not list" -- \
  "$(mutate site2 's|# chosen: site 1 (example.com)|# chosen: site 2 (other.com)|')" "$picks"
expect "chosen that no picked option covers fails" 1 "no picked option on site 1 covers it" -- \
  "$(mutate no-take 's|# derived: M3 short4, sec.5|# chosen: site 1 (example.com)|')" "$picks"
expect "the same token passes once a picked option covers it" 0 "check: PASS" -- \
  "$(mutate no-take-ok 's|# derived: M3 short4, sec.5|# chosen: site 1 (example.com)|')" \
  "$(picks_with mood 'pick 1 mood' 'take 1 mood motion.* | elements fade in on scroll')"
expect "chosen from an option offered and not picked fails" 1 \
  "the user was offered this there and did not pick it (declined: \"one narrow centered column with wide side margins\")" -- \
  "$(mutate declined 's|# defaulted: container and side margins, sec.8|# chosen: site 1 (example.com)|')" "$picks"
expect "a declined nested path matched by a wildcard fails as declined" 1 \
  "typography.body-lg.fontFamily: chosen from site 1, but the user was offered this there" -- \
  "$(mutate declined-nested 's|# chosen: user$|# chosen: site 1 (example.com)|')" "$picks"
expect "a path covered by a picked and a declined option fails" 1 \
  "it is covered by a picked option (\"the light sans body text (Noto Sans JP)\") and a declined option (\"the heavy serif headings (Playfair Display)\"); where the two overlap the truthful tier is derived or defaulted" -- \
  "$(mutate take-overlap 's|# chosen: user$|# chosen: site 1 (example.com)|')" \
  "$(picks_with take-overlap 'take 1 color-type typography.body-*.fontFamily | the light sans body text (Noto Sans JP)')"
expect "a wildcard take covers a nested typography path" 0 "check: PASS" -- \
  "$(mutate take-nested 's|# chosen: user$|# chosen: site 1 (example.com)|')" \
  "$(picks_edit take-nested '/typography[.][*][.]fontFamily/d' 'take 1 color-type typography.body-*.fontFamily | the light sans body text (Noto Sans JP)')"
expect "a wildcard take is anchored and does not cover a sibling role" 1 "but the user was offered this there" -- \
  "$(mutate take-sibling 's|# chosen: user$|# chosen: site 1 (example.com)|')" \
  "$(picks_with take-sibling 'take 1 color-type typography.display-*.fontFamily | the giant thin headline')"
expect "a take with - patterns covers no token" 1 "no picked option on site 1 covers it" -- \
  "$(mutate dash-take 's|# derived: Tailwind md, sec.3|# chosen: site 1 (example.com)|')" "$picks"
expect "a take on another site does not cover site 1" 1 "no picked option on site 1 covers it" -- \
  "$(mutate other-site 's|# derived: M3 short4, sec.5|# chosen: site 1 (example.com)|')" \
  "$(picks_with other-site 'site 2 https://example.org' 'pick 2 mood' 'take 2 mood motion.* | elements fade in on scroll')"
expect "a hex and a # after the bar stay option text" 1 \
  "(declined: \"the red accent #E24A33 (#c0392b) # Call B, colors\")" -- \
  "$(mutate declined-hex 's|# derived: M3 short4, sec.5|# chosen: site 1 (example.com)|')" \
  "$(picks_with declined-hex 'decline 1 color-type motion.* | the red accent #E24A33 (#c0392b) # Call B, colors')"
expect "option text that starts with # is kept" 0 "check: PASS" -- \
  "$good" "$(picks_with hash-text 'take 1 structure - | # just a heading')"
expect "a trailing comment on a take line is part of its option text" 1 \
  "defaulted for pick \"a short menu\", site 1, but no picked option on site 1 has that text" -- \
  "$(mutate pick-comment 's|# defaulted: container and side margins, sec.8|# defaulted: 1120px; for pick "a short menu", site 1|')" \
  "$(picks_with pick-comment 'take 1 structure - | a short menu   # Call B')"
expect "take without its pick bundle line fails" 1 "take 1 mood: no \"pick 1 mood\" line" -- \
  "$good" "$(picks_with take-no-pick 'take 1 mood motion.* | elements fade in on scroll')"
expect "said with a wildcard fails" 1 "said: pattern \"colors.*\" has a *" -- \
  "$good" "$(picks_with said-wild 'said 1 color-type colors.* | x')"
expect "said covers its tokens for chosen like take" 0 "check: PASS" -- \
  "$(mutate said-chosen 's|# derived: M3 short4, sec.5|# chosen: site 1 (example.com)|')" \
  "$(picks_with said-chosen 'pick 1 mood' 'said 1 mood motion.duration-short | 動きはこのサイトくらい短く')"
expect "said with - covers no token" 1 "no picked option on site 1 covers it" -- \
  "$(mutate said-dash 's|# derived: M3 short4, sec.5|# chosen: site 1 (example.com)|')" \
  "$(picks_with said-dash 'pick 1 mood' 'said 1 mood - | 動きはこのサイトくらい短く')"
expect "said without its pick bundle line fails" 1 "said 1 mood: no \"pick 1 mood\" line" -- \
  "$good" "$(picks_with said-no-pick 'said 1 mood motion.duration-short | 動きは短く')"
expect "said outranks a declined option on the same token" 0 "check: PASS" -- \
  "$(mutate said-overlap 's|# defaulted: container and side margins, sec.8|# chosen: site 1 (example.com)|')" \
  "$(picks_with said-overlap 'said 1 structure spacing.container | ページ幅もこのサイトに近づけたい')"
expect "said on a token no option declined passes" 0 "check: PASS" -- \
  "$(mutate said-container 's|# defaulted: container and side margins, sec.8|# chosen: site 1 (example.com)|')" \
  "$(picks_edit said-container '/^decline 1 structure spacing[.]container/d' 'said 1 structure spacing.container | ページ幅もこのサイトに近づけたい')"
expect "a trailing comma in patterns fails" 1 "bad token pattern \"\" (an empty element; remove the stray comma)" -- \
  "$good" "$(picks_with empty-tail 'take 1 color-type colors.primary, | the accent')"
expect "an empty element between commas fails" 1 "bad token pattern \"\" (an empty element; remove the stray comma)" -- \
  "$good" "$(picks_with empty-mid 'take 1 color-type colors.primary,,colors.on-primary | the accent')"
expect "a list of patterns covers each listed token" 0 "check: PASS" -- \
  "$(mutate two-patterns 's|# derived: M3 on-primary T100, sec.1|# chosen: site 1 (example.com)|')" \
  "$(picks_with two-patterns 'take 1 color-type colors.primary,colors.on-primary | white text on the accent')"
expect "a two-part typography pattern without * fails" 1 \
  "bad token pattern \"typography.body-lg\" (covers no property; write typography.body-lg.* or name the property" -- \
  "$good" "$(picks_with typo-two 'take 1 color-type typography.body-lg | the body text')"
expect "a typography role pattern ending in * covers its properties" 0 "check: PASS" -- \
  "$(mutate typo-star 's|# derived: M3 body-large, sec.2|# chosen: site 1 (example.com)|')" \
  "$(picks_with typo-star 'take 1 color-type typography.body-lg.* | the body text size')"
expect "records naming a site with no site line fail, one each" 1 "check: FAIL (5 failures)" -- \
  "$good" "$(picks_with no-site2 'pick 2 mood' 'take 2 mood - | a' 'decline 2 mood - | b' 'said 2 mood - | c' 'reject 2 the popup')"
expect "a reject naming a site with no site line says which line is missing" 1 "reject 2: no \"site 2 <url>\" line" -- \
  "$good" "$(picks_with no-site2-reject 'reject 2 the popup')"
expect "the same records pass once the site is listed" 0 "check: PASS" -- \
  "$good" "$(picks_with site2 'site 2 https://example.org' 'pick 2 mood' 'take 2 mood - | a' 'decline 2 mood - | b' 'said 2 mood - | c' 'reject 2 the popup')"
expect "take with an unknown bundle fails" 1 "unknown bundle \"layout\"" -- \
  "$good" "$(picks_with take-bad-bundle 'take 1 layout spacing.* | wide side margins')"
expect "take without option text fails" 1 "take needs <N> <bundle> <patterns> | <option text>" -- \
  "$good" "$(picks_with take-no-text 'take 1 color-type colors.primary')"
expect "take with a pattern that names no key fails" 1 "bad token pattern \"colors\"" -- \
  "$good" "$(picks_with take-bad-pattern 'take 1 color-type colors | the accent')"
expect "take with a wildcard group fails" 1 "bad token pattern \"*.primary\"" -- \
  "$good" "$(picks_with take-wild-group 'take 1 color-type *.primary | the accent')"
expect "note record fails with a hint to use take" 1 "\"note\" is no longer a record; write each picked option as \"take" -- \
  "$good" "$(picks_with note 'note 1 almost only white and black')"
expect "chosen: userland is not chosen: user" 1 "chosen must name" -- \
  "$(mutate userland 's|# chosen: user$|# chosen: userland guess|')" "$picks"
expect "chosen: user without a user line fails" 1 "picks.txt has no \"user colors\" line" -- \
  "$(mutate user-colors 's|# chosen: site 1 (example.com)|# chosen: user|')" "$picks"
expect "unknown bundle in picks.txt fails" 1 "unknown bundle \"layout\"" -- \
  "$good" "$(picks_with bad-bundle 'pick 1 layout')"
expect "unknown record in picks.txt fails" 1 "unknown record \"liked\"" -- \
  "$good" "$(picks_with bad-record 'liked 1 the hero')"

# ---- components and headings ----
expect "hex inside components fails" 1 "hex value inside components" -- \
  "$(mutate hex 's|    backgroundColor: "{colors.primary}"|    backgroundColor: "#24363f"|')" "$picks"
expect "single-quoted hex inside components fails" 1 "hex value inside components" -- \
  "$(mutate hex-single "s|    backgroundColor: \"{colors.primary}\"|    backgroundColor: '#24363f'|")" "$picks"
expect "missing required heading fails" 1 "missing required heading \"## Layout Heuristics\"" -- \
  "$(mutate no-heading 's|^## Layout Heuristics$|## Layout Notes|')" "$picks"
expect "duplicate heading fails" 1 "duplicate heading \"## Overview\"" -- \
  "$(mutate dup-heading 's|^## Shapes$|## Overview|')" "$picks"
expect "unclosed front matter fails" 1 "front matter is not closed" -- \
  "$(mutate unclosed '/^---$/{x;s/^/x/;/^xx$/{x;d;};x;}')" "$picks"

# ---- lengths carry a unit ----
expect "unitless rounded length fails" 1 "rounded.none: length without a unit (0); write it with a unit, e.g. 0px" -- \
  "$(mutate unitless 's|^  none: 0px |  none: 0   |')" "$picks"
expect "quoted unitless rounded length fails" 1 "rounded.none: length without a unit (\"0\")" -- \
  "$(mutate unitless-quoted 's|^  none: 0px |  none: "0" |')" "$picks"
expect "unitless spacing length fails" 1 "spacing.section: length without a unit (96)" -- \
  "$(mutate unitless-spacing 's|^  section: 96px |  section: 96   |')" "$picks"
expect "unitless typography values are not lengths and pass" 0 "check: PASS" -- \
  "$(mutate typo-unitless 's|^    lineHeight: 1.75 .*|&\
    letterSpacing: 0                  # derived: DADS display tracking 0, sec.9\
    fontWeight: "400"                 # derived: M3 regular 400, sec.2|')" "$picks"

# ---- achromatic neutrals ----
expect "achromatic comment on a tinted hex fails" 1 \
  "colors.surface-container: the tier comment says achromatic, but \"#f0ecf4\" is not a pure gray hex (R = G = B)" -- \
  "$(mutate achromatic-tinted 's|^  # warning: open.*|&\
  surface-container: "#f0ecf4"        # derived: neutral T94, sec.1; achromatic neutrals defaulted, sec.8|')" "$picks"
expect "achromatic comment on a tinted 3-digit hex fails" 1 "colors.surface-container: the tier comment says achromatic, but \"#efe\"" -- \
  "$(mutate achromatic-tinted3 's|^  # warning: open.*|&\
  surface-container: "#efe"           # derived: neutral T94, sec.1; achromatic neutrals defaulted, sec.8|')" "$picks"
expect "achromatic comment on a pure gray passes" 0 "check: PASS" -- \
  "$(mutate achromatic-gray 's|^  # warning: open.*|&\
  surface-container: "#f4f4f4"        # derived: neutral T94, sec.1; achromatic neutrals defaulted, sec.8|')" "$picks"
expect "achromatic comment on an uppercase 3-digit gray passes" 0 "check: PASS" -- \
  "$(mutate achromatic-gray3 's|^  # warning: open.*|&\
  surface-container: "#EEE"           # derived: neutral T94, sec.1; achromatic neutrals defaulted, sec.8|')" "$picks"
expect "a tinted hex without the word achromatic passes" 0 "check: PASS" -- \
  "$(mutate tinted-plain 's|^  # warning: open.*|&\
  surface-container: "#f0ecf4"        # derived: neutral T94, sec.1|')" "$picks"

# ---- page margin beside a chosen container ----
pm_picks=$(picks_edit pm-take '/^decline 1 structure spacing[.]container/d' 'take 1 structure spacing.container | the wide 1344px page')
expect "defaulted fluid margin beside a chosen container fails on the margin line" 1 \
  ":21: spacing.page-margin: a defaulted fluid margin (clamp(24px, 6vw, 96px)) beside a chosen spacing.container narrows the width the user picked" -- \
  "$(mutate pm-fluid 's|^  container: 1120px .*|  container: 1344px                  # chosen: site 1 (example.com)\
  page-margin: clamp(24px, 6vw, 96px) # defaulted: container and side margins, sec.8|')" "$pm_picks"
expect "a percent margin written before the chosen container fails too" 1 \
  ":20: spacing.page-margin: a defaulted fluid margin (5%)" -- \
  "$(mutate pm-percent-first 's|^  container: 1120px .*|  page-margin: 5%                     # defaulted: container and side margins, sec.8\
  container: 1344px                  # chosen: site 1 (example.com)|')" "$pm_picks"
expect "fixed 24px defaulted margin beside a chosen container passes" 0 "check: PASS" -- \
  "$(mutate pm-fixed 's|^  container: 1120px .*|  container: 1344px                  # chosen: site 1 (example.com)\
  page-margin: 24px                   # defaulted: page margin beside a chosen container, sec.8|')" "$pm_picks"
expect "the clamp beside the defaulted container passes" 0 "check: PASS" -- \
  "$(mutate pm-default 's|^  container: 1120px .*|&\
  page-margin: clamp(24px, 6vw, 96px) # defaulted: container and side margins, sec.8|')" "$picks"
expect "a chosen fluid margin beside a chosen container passes" 0 "check: PASS" -- \
  "$(mutate pm-chosen 's|^  container: 1120px .*|  container: 1344px                  # chosen: site 1 (example.com)\
  page-margin: clamp(24px, 5vw, 64px) # chosen: site 1 (example.com)|')" \
  "$(picks_edit pm-take-both '/^decline 1 structure spacing[.]container/d' 'take 1 structure spacing.container,spacing.page-margin | the wide 1344px page with its side padding')"

# ---- Sources record where values were measured ----
expect "a Sources item without measured: fails" 1 "Sources item 1: no \"measured:\"" -- \
  "$(mutate src-unmeasured 's| ; measured: static CSS (facts.txt)||')" "$picks"
expect "measured: on a continuation line passes" 0 "check: PASS" -- \
  "$(mutate src-continued 's| ; measured: static CSS (facts.txt)|\
   measured: static CSS (facts.txt)|')" "$picks"
expect "measured: after a blank line no longer belongs to the item" 1 "Sources item 1: no \"measured:\"" -- \
  "$(mutate src-blank 's| ; measured: static CSS (facts.txt)|\
\
   measured: static CSS (facts.txt)|')" "$picks"
expect "a second Sources item without measured: is named" 1 "Sources item 2: no \"measured:\"" -- \
  "$(mutate src-second 's|^1[.] example[.]com.*|&\
2. example.org : taken: nothing ; rejected: nothing|')" "$picks"
expect "Sources with no numbered item passes" 0 "check: PASS" -- \
  "$(mutate src-none 's|^1[.] example[.]com.*|No reference sites were given.|')" "$picks"

# ---- file handling ----
crlf="$work/crlf.md"
sed 's/$/\r/' "$good" >"$crlf"
expect "CRLF line endings pass" 0 "check: PASS" -- "$crlf" "$picks"
mkdir -p "$work/a=b"
cp "$good" "$work/a=b/good.md"
expect "a path containing = is read as a file" 0 "check: PASS" -- "$work/a=b/good.md" "$picks"
cp "$good" "$work/x=y.md"
rel_out=$(cd "$work" && bash "$script" "x=y.md" "$picks" 2>&1) && rel_exit=0 || rel_exit=$?
if [ "$rel_exit" = 0 ] && printf '%s\n' "$rel_out" | grep -qF "check: PASS"; then
  printf 'ok - a relative path containing = is read as a file\n'
  passed=$((passed + 1))
else
  printf 'not ok - a relative path containing = is read as a file\n  got exit %s, output:\n' "$rel_exit"
  printf '%s\n' "$rel_out" | sed 's/^/    /'
  failed=$((failed + 1))
fi

# ---- usage ----
expect "no arguments is a usage error" 2 "usage:" --
expect "unreadable DESIGN.md is an input error" 2 "cannot read" -- "$work/missing.md"

printf '%d passed, %d failed\n' "$passed" "$failed"
[ "$failed" -eq 0 ]
