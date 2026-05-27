# Resume — Agent Notes

## Rendering

Typst compiles directly to PDF or PNG — no Ghostscript needed.

**PDF (both variants):**
```
make pdf
```

**Single variant PDF:**
```
make pdf-short
make pdf-full
```

**PNG for visual review** (typst outputs one file per page; `{p}` is required for multi-page):
```
typst compile \
  --input data=../resume.json \
  --input variant=../variants/short.json \
  --root . \
  --font-path /System/Library/Fonts \
  --font-path /System/Library/Fonts/Supplemental \
  --font-path ~/Library/Fonts \
  templates/resume.typ \
  "output/review-short-{p}.png"
```

Always render PNG after template edits and read the image to verify spacing before committing.

## Project structure

```
resume.json          — content (JSON Resume schema)
templates/resume.typ — single Typst template
variants/short.json  — one-page: trims jobs, drops publications
variants/full.json   — complete CV, all sections
output/              — compiled artifacts (gitignored or ephemeral)
```

## Variant system

Variants are JSON files that set `include.*` flags read by the template:

| key | type | effect |
|---|---|---|
| `publications` | bool | show/hide publications section |
| `location` | bool | show city/region in contact line |
| `summary` | bool | show/hide profile summary |
| `work_limit` | int | cap number of jobs shown |
| `work_highlights` | `{company: [indices]}` | per-job bullet selection (0-based) |
| `projects` | bool \| string[] | all / none / allowlist by name |

## Template layout notes

- **Header**: two-column `grid` — name bottom-left, title + contact bottom-right.
- **Section rule**: `section()` helper renders bold small-caps label + full-width rule.
- **Entry header**: `entry-header(left-top, left-sub, right-str)` — bold title + date right, subtitle below. `row-gutter` controls vertical space between title and company name.
- **Inline bold**: `**text**` in JSON strings is parsed by `parse-inline()` into Typst `strong()`.
- Spacing is in `em` units. Key values to tune: `row-gutter` in `entry-header`, `v()` calls around summaries and section gaps.

## Fonts

Relies on system Gill Sans. Font paths passed explicitly to `typst compile`. If Gill Sans is missing the output will fall back silently — check the header visually.
