---
version: alpha
name: Fixture Site
description: Minimal DESIGN.md that passes check-design-md.sh.
colors:
  primary: "#24363f"                  # chosen: site 1 (example.com)
  on-primary: "#ffffff"               # derived: M3 on-primary T100, sec.1
  scrim: "#000000"                    # derived: M3 scrim neutral T0, sec.1; 50% opacity defaulted, sec.8
  # warning: open (TODO: decide), see Known Gaps
typography:
  body-lg:
    fontFamily: Noto Sans JP          # chosen: user
    fontSize: 16px                    # derived: M3 body-large, sec.2
    lineHeight: 1.75                  # defaulted: Japanese body line-height, sec.8
rounded:
  none: 0                             # derived: M3 shape none, sec.4
  md: 12px                            # derived: M3 shape medium, sec.4; feel "soft" row is the sec.8 default
spacing:
  section: 96px                       # defaulted: section padding by feel, sec.8; for feel "airy"
  container: 1120px                   # defaulted: container and side margins, sec.8
  content-wide: 740px                 # derived: DADS 8-col offset column, sec.9
elevation:
  level0: none                        # derived: M3 elevation level0, sec.4
motion:
  duration-short: 200ms               # derived: M3 short4, sec.5
breakpoints:
  md: 768px                           # derived: Tailwind md, sec.3
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    height: 48px                      # = 48dp touch target
---

## Agent Guide
x
## Hard Baseline
x
## Layout Heuristics
x
## Overview
x
## Colors
x
## Typography
x
## Layout
x
## Elevation & Depth
x
## Shapes
x
## Components
```md
## Agent Guide
(a heading inside a code fence is not a heading)
```
## Interaction States
x
## Motion
x
## Responsive Behavior
x
## Imagery & Iconography
x
## Voice & Content
x
## Accessibility
x
## Do's and Don'ts
x
## Intent
x
## Sources
x
## Iteration Guide
x
## Known Gaps
x
## Brief (Japanese)
x
