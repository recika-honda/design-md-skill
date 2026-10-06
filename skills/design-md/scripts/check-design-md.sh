#!/usr/bin/env bash
# check-design-md.sh: mechanical checks on a DESIGN.md draft written by the design-md skill.
#
# Usage: check-design-md.sh <DESIGN.md> [picks.txt]
#
# What it proves (the judgment checks stay with the model, see output-template.md):
#   - every leaf token in colors / typography / rounded / spacing / elevation / motion /
#     breakpoints carries a tier comment: chosen, derived, or defaulted
#   - `derived` cites a public rule (sec.1-7 or sec.9), never only the skill defaults (sec.8)
#   - `defaulted` cites sec.8 or names an unverified row
#   - `chosen` names `site N` or `user`; with picks.txt, site N exists and the user ticked a
#     bundle that grants this token group for site N (or a `user <group>` line exists)
#   - no hex value inside `components`
#   - every required body heading appears exactly once, and no `##` heading is duplicated
#
# picks.txt (written during the interview, SKILL.md Step 3), one fact per line:
#   site <N> <url>     pick <N> <structure|component|color-type|mood>
#   user <group>       note <N> <text>     reject <N> <text>     (# starts a comment)
#
# Output: one "FAIL <file>:<line>: <reason>" line per problem, then one summary line:
#   "check: <PASS|FAIL> (<n> failures); chosen <c>, derived <d>, defaulted <f>, open <o>"
# Exit: 0 pass, 1 at least one FAIL, 2 usage or unreadable input.
#
# Portability: bash 3.2+ and POSIX awk (stock macOS awk works).

set -euo pipefail

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  printf 'usage: check-design-md.sh <DESIGN.md> [picks.txt]\n' >&2
  exit 2
fi

design=$1
picks=${2:-}

if [ ! -r "$design" ]; then
  printf 'check-design-md.sh: cannot read %s\n' "$design" >&2
  exit 2
fi
if [ -n "$picks" ] && [ ! -r "$picks" ]; then
  printf 'check-design-md.sh: cannot read %s\n' "$picks" >&2
  exit 2
fi

# Without picks.txt the provenance of `chosen` cannot be proven; say so loudly instead of
# passing silently. An empty file stands in so awk always gets two inputs.
picks_input=$picks
if [ -z "$picks" ]; then
  printf 'WARN: no picks.txt given; chosen tokens are checked for form only, not provenance\n'
  picks_input=/dev/null
fi

# awk reads an operand containing "=" as a variable assignment; a ./ prefix keeps it a file.
case $design in /*) design_arg=$design ;; *) design_arg=./$design ;; esac
case $picks_input in /*) picks_arg=$picks_input ;; *) picks_arg=./$picks_input ;; esac

awk -v design_name="$design" -v picks_name="${picks:-picks.txt}" -v have_picks="${picks:+1}" '
function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
function fail(file, line, msg) { printf "FAIL %s:%d: %s\n", file, line, msg; failures++ }

# Blank out quoted strings (same length) so a "#hex" value is not read as a comment start,
# while the comment itself can still be cut from the original line at the same position.
function mask_quotes(s,   out, i, c, q) {
  out = ""; q = ""
  for (i = 1; i <= length(s); i++) {
    c = substr(s, i, 1)
    if (q == "" && (c == "\"" || c == "\047")) { q = c; out = out c; continue }
    if (q != "" && c == q) { q = ""; out = out c; continue }
    out = out (q == "" ? c : "x")
  }
  return out
}

# Bundle -> token groups it grants to `chosen: site N` (mirrors SKILL.md Step 3).
function grants(bundle, group) {
  if (bundle == "structure")  return (group == "spacing" || group == "breakpoints")
  if (bundle == "component")  return (group == "rounded" || group == "elevation" || group == "spacing")
  if (bundle == "color-type") return (group == "colors" || group == "typography")
  if (bundle == "mood")       return (group == "spacing" || group == "rounded" || group == "elevation" || group == "motion")
  return 0
}

BEGIN {
  failures = 0; n_chosen = 0; n_derived = 0; n_defaulted = 0; n_open = 0
  split("colors typography rounded spacing elevation motion breakpoints", g, " ")
  for (i in g) token_group[g[i]] = 1
  required_list = "Agent Guide|Hard Baseline|Layout Heuristics|Overview|Colors|Typography|Layout|Elevation & Depth|Shapes|Components|Interaction States|Motion|Responsive Behavior|Imagery & Iconography|Voice & Content|Accessibility|Do'"'"'s and Don'"'"'ts|Intent|Sources|Iteration Guide|Known Gaps|Brief (Japanese)"
  n_required = split(required_list, required, "|")
}

{ sub(/\r$/, "") }   # tolerate CRLF files

# ---- pass 1: picks.txt (phase is set to 2 on the command line before DESIGN.md) ----
phase != 2 {
  line = $0; sub(/#.*/, "", line); line = trim(line)
  if (line == "") next
  n = split(line, f, /[ \t]+/)
  if (f[1] == "site") {
    if (f[2] !~ /^[1-9][0-9]*$/) { fail(picks_name, FNR, "site needs a number: " line); next }
    site[f[2]] = 1
  } else if (f[1] == "pick") {
    if (f[2] !~ /^[1-9][0-9]*$/ || n < 3) { fail(picks_name, FNR, "pick needs <N> <bundle>: " line); next }
    if (!grants(f[3], "colors") && !grants(f[3], "spacing")) { fail(picks_name, FNR, "unknown bundle \"" f[3] "\" (structure|component|color-type|mood)"); next }
    picked[f[2], f[3]] = 1
  } else if (f[1] == "user") {
    if (!(f[2] in token_group)) { fail(picks_name, FNR, "user needs a token group: " line); next }
    user_group[f[2]] = 1
  } else if (f[1] != "note" && f[1] != "reject") {
    fail(picks_name, FNR, "unknown record \"" f[1] "\" (site|pick|user|note|reject)")
  }
  next
}

# ---- pass 2: DESIGN.md ----
FNR == 1 {
  if ($0 != "---") { fail(design_name, 1, "front matter must start with --- on line 1"); in_fm = 0; fm_done = 1 }
  else { in_fm = 1 }
  next
}

in_fm && $0 == "---" { in_fm = 0; fm_done = 1; next }

in_fm {
  raw = $0
  # Comment-only lines: count open tokens, nothing else to check.
  if (raw ~ /^[ \t]*#/) {
    if (raw ~ /^[ \t]*#[ \t]*[A-Za-z0-9_.-]+:[ \t]*open/) n_open++
    next
  }
  if (raw ~ /^[A-Za-z]/) {           # top-level key starts a group
    top = raw; sub(/:.*/, "", top); parent = ""; next
  }
  bare = mask_quotes(raw)
  comment = ""
  if (match(bare, /[ \t]#/)) { comment = trim(substr(raw, RSTART + 2)); bare = substr(bare, 1, RSTART - 1) }

  if (top == "components") {
    if (raw ~ /["\047]#[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]/) fail(design_name, FNR, "hex value inside components; reference a token instead")
    next
  }
  if (!(top in token_group)) next

  # A leaf has a value after the colon; a key with nothing after it opens a nested map
  # (a typography role), remembered so failures name the full path.
  key = trim(bare); sub(/:.*/, "", key)
  if (bare !~ /:[ \t]*[^ \t]/) { parent = key; next }
  if (bare ~ /^  [^ ]/) parent = ""
  if (parent != "") key = parent "." key

  if (bare ~ /:[ \t]*[{[]/) { fail(design_name, FNR, top "." key ": flow map or list; write it in block form, one property per line, each with its own tier"); next }
  if (comment == "") { fail(design_name, FNR, top "." key ": no tier comment (chosen | derived | defaulted)"); next }

  if (comment ~ /^chosen:/) {
    n_chosen++
    if (comment ~ /^chosen:[ \t]*skill default/) { fail(design_name, FNR, top "." key ": a skill default labeled chosen; use defaulted: <row>, sec.8"); next }
    if (comment ~ /^chosen:[ \t]*site[ \t]+[0-9]/) {
      s = comment; sub(/^chosen:[ \t]*site[ \t]+/, "", s); sub(/[^0-9].*/, "", s)
      if (have_picks) {
        if (!(s in site)) { fail(design_name, FNR, top "." key ": chosen from site " s ", which picks.txt does not list"); next }
        ok = 0
        split("structure component color-type mood", b, " ")
        for (i in b) if (((s, b[i]) in picked) && grants(b[i], top)) ok = 1
        if (!ok) fail(design_name, FNR, top "." key ": chosen from site " s ", but the user picked no bundle there that covers " top)
      }
    } else if (comment ~ /^chosen:[ \t]*user([ \t(;,]|$)/) {
      if (have_picks && !(top in user_group)) fail(design_name, FNR, top "." key ": chosen: user, but picks.txt has no \"user " top "\" line")
    } else {
      fail(design_name, FNR, top "." key ": chosen must name \"site N\" or \"user\"")
    }
  } else if (comment ~ /^derived:/) {
    n_derived++
    # Public-rule sections are 1-7 and 9; sec.8 holds the skill defaults.
    cited = comment " "
    if (cited !~ /sec\.[0-9]/) { fail(design_name, FNR, top "." key ": derived without a rule citation (sec.N)"); next }
    if (cited !~ /sec\.[1-79][^0-9]/) fail(design_name, FNR, top "." key ": derived cites no public rule (sec.1-7 or sec.9); sec.8 values are defaulted")
  } else if (comment ~ /^defaulted:/) {
    n_defaulted++
    if ((comment " ") !~ /sec\.8[^0-9]/ && comment !~ /unverified/) fail(design_name, FNR, top "." key ": defaulted must cite sec.8 or an unverified row")
  } else {
    fail(design_name, FNR, top "." key ": comment does not start with chosen:, derived:, or defaulted:")
  }
  next
}

# Body: headings outside fenced code blocks.
/^```/ { in_fence = !in_fence; next }
!in_fence && /^## / {
  h = substr($0, 4); h = trim(h)
  if (h in seen) fail(design_name, FNR, "duplicate heading \"## " h "\"")
  seen[h]++
}

END {
  if (!fm_done || in_fm) fail(design_name, NR, "front matter is not closed with ---")
  for (i = 1; i <= n_required; i++) if (!(required[i] in seen)) fail(design_name, 0, "missing required heading \"## " required[i] "\"")
  printf "check: %s (%d failures); chosen %d, derived %d, defaulted %d, open %d\n", (failures ? "FAIL" : "PASS"), failures, n_chosen, n_derived, n_defaulted, n_open
  exit (failures ? 1 : 0)
}
' "$picks_arg" phase=2 "$design_arg"
