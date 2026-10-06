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

# picks_with <name> <extra line>: copy picks.txt with one line appended, print the path.
picks_with() {
  local path="$work/$1.txt"
  cp "$picks" "$path"
  printf '%s\n' "$2" >>"$path"
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
  "$(mutate flow-seq 's|^  none: 0 .*|  none: [0, 1]                        # derived: M3 shape none, sec.4|')" "$picks"
expect "derived without a citation fails" 1 "derived without a rule citation" -- \
  "$(mutate derived-bare 's|# derived: M3 short4, sec.5|# derived: M3 short4|')" "$picks"
expect "defaulted without sec.8 fails" 1 "defaulted must cite sec.8" -- \
  "$(mutate defaulted-bare 's|# defaulted: container and side margins, sec.8|# defaulted: looks calm|')" "$picks"
expect "chosen naming neither site nor user fails" 1 "chosen must name" -- \
  "$(mutate chosen-vague 's|# chosen: site 1 (example.com)|# chosen: primary on accent|')" "$picks"

# ---- provenance against picks.txt ----
expect "chosen from a site picks.txt does not list fails" 1 "chosen from site 2, which picks.txt does not list" -- \
  "$(mutate site2 's|# chosen: site 1 (example.com)|# chosen: site 2 (other.com)|')" "$picks"
expect "chosen from a site whose picked bundles do not cover the group fails" 1 "the user picked no bundle there that covers motion" -- \
  "$(mutate wrong-bundle 's|# derived: M3 short4, sec.5|# chosen: site 1 (example.com)|')" "$picks"
expect "the same token passes once the covering bundle is picked" 0 "check: PASS" -- \
  "$(mutate wrong-bundle-ok 's|# derived: M3 short4, sec.5|# chosen: site 1 (example.com)|')" \
  "$(picks_with mood 'pick 1 mood')"
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
