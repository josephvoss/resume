#!/usr/bin/env bash
# blog.md.sh — Generate Markdown resume content from resume.json
# Usage: ./templates/blog.md.sh [variant] > output/resume-blog.md
#
# Requires: jq
# The output is plain Markdown suitable for embedding in Hugo, Astro, Jekyll, etc.
# Frontmatter is omitted intentionally — add it in your SSG layout.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"
DATA="$ROOT/resume.json"
VARIANT="${1:-$ROOT/variants/full.json}"

jq -r --slurpfile variant "$VARIANT" '
  def fmt_date(d):
    if d == null or d == "" then "Present"
    else
      (d | split("-")) as $p |
      if ($p | length) >= 2 then
        (["Jan","Feb","Mar","Apr","May","Jun",
          "Jul","Aug","Sep","Oct","Nov","Dec"][($p[1] | tonumber) - 1]) + " " + $p[0]
      else $p[0]
      end
    end;

  def date_range(s; e): fmt_date(s) + " – " + fmt_date(e);

  ($variant[0].include // {}) as $inc |
  ($inc.publications // true) as $show_pub |
  ($inc.work_limit // 999) as $wlimit |

  "## Education\n",
  (.education[] |
    "**\(.studyType), \(.area)**  \n\(.institution) · " +
    date_range(.startDate; .endDate) + "\n"
  ),

  "\n## Experience\n",
  (.work[:.wlimit] |
    .[] |
    "### \(.position)\n**\(.name)** · " + date_range(.startDate; .endDate) + "\n\n" +
    (.highlights | map("- " + .) | join("\n")) + "\n"
  ),

  "\n## Skills\n",
  (.skills | map(.name + ": " + (.keywords | join(", "))) | join("  ·  ") + "\n"),

  if $show_pub then
    "\n## Publications\n",
    (.publications[] |
      (.authors[0]) as $first |
      (.authors[1:] | join(", ")) as $rest |
      (if (.authors | length) > 1 then $first + ", " + $rest else $first end) as $authors |
      "- \($authors) (\(.releaseDate)). \"\(.name).\" *\(.publisher).* <\(.url)>\n"
    )
  else "" end
' "$DATA"
