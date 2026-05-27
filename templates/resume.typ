// resume.typ — Typst template for josephvoss/resume
// Reads resume.json (JSON Resume schema) + a variant config.
//
// Usage:
//   typst compile --input data=../resume.json --input variant=../variants/full.json \
//     --root . --font-path /System/Library/Fonts \
//               --font-path /System/Library/Fonts/Supplemental \
//     templates/resume.typ output/resume-full.pdf

#let data    = json(sys.inputs.at("data",    default: "../resume.json"))
#let variant = json(sys.inputs.at("variant", default: "../variants/full.json"))

// ── variant helpers ───────────────────────────────────────────────────────────

#let inc = variant.at("include", default: (:))

// booleans
#let include-publications = inc.at("publications", default: true)
#let include-location     = inc.at("location",     default: true)
#let include-summary      = inc.at("summary",      default: true)
#let work-limit           = inc.at("work_limit",   default: 999)

// projects: true = all, false = none, array of names = allowlist
#let projects-setting = inc.at("projects", default: true)

// work_highlights: dict of company name → array of 0-based highlight indices to show.
// absent key = show all highlights for that job.
#let work-highlight-map = inc.at("work_highlights", default: (:))

// ── inline bold parser ────────────────────────────────────────────────────────
// Converts **text** spans inside a plain string to Typst bold runs.
// Only handles **...** (no nesting, no escaping needed for resumes).

#let parse-inline(s) = {
  let parts = s.split("**")
  // parts alternates: plain, bold, plain, bold, ...
  // odd indices (1, 3, …) are bold
  let out = ()
  for (i, part) in parts.enumerate() {
    if calc.odd(i) {
      out.push(strong(part))
    } else {
      out.push(part)
    }
  }
  out.join()
}

// ── design tokens ─────────────────────────────────────────────────────────────

#let accent   = rgb("#1a202c")   // near-black — section headings
#let fg       = rgb("#1a202c")   // near-black body text
#let subtle   = rgb("#4a5568")   // muted grey for secondary labels

// ── page setup ────────────────────────────────────────────────────────────────

#set page(
  paper: "us-letter",
  margin: (top: 0.45in, bottom: 0.4in, left: 0.55in, right: 0.55in),
)

#set text(font: "Baskerville", size: 10.5pt, fill: fg)
#set par(leading: 0.65em, spacing: 0.65em)
#set list(indent: 0.5em, body-indent: 0.4em, spacing: 0.45em)

// ── section heading ───────────────────────────────────────────────────────────

#let section(title) = {
  v(0.5em)
  stack(
    dir: ttb,
    text(weight: "bold", size: 9.5pt, fill: fg, tracking: 1.2pt, upper(title)),
    v(0.2em),
    line(length: 100%, stroke: 0.5pt + rgb("#a0aec0")),
  )
  v(0.1em)
}

// ── job / project entry header ────────────────────────────────────────────────

#let entry-header(left-top, left-sub, right-str) = grid(
  columns: (1fr, auto),
  row-gutter: 0.9em,
  align(left + bottom)[*#left-top*],
  align(right + bottom)[#text(size: 9.5pt, fill: subtle)[#right-str]],
  align(left)[#text(size: 9.5pt, fill: subtle)[#left-sub]],
  [],
)

// ── date formatting ───────────────────────────────────────────────────────────

#let fmt-date(d) = {
  if d == none or d == "" { "Present" }
  else {
    let parts = d.split("-")
    let months = ("Jan","Feb","Mar","Apr","May","Jun",
                  "Jul","Aug","Sep","Oct","Nov","Dec")
    if parts.len() >= 2 {
      months.at(int(parts.at(1)) - 1) + " " + parts.at(0)
    } else {
      parts.at(0)
    }
  }
}

#let date-range(start, end) = {
  fmt-date(start) + " – " + fmt-date(end)
}

// ── name / contact header ──────────────────────────────────────────────────────

#{
  let basics = data.basics
  let contact-sep = h(0.6em) + text(fill: subtle)[·] + h(0.6em)

  let contact-items = ()
  if include-location {
    contact-items += (text[#basics.location.city, #basics.location.region],)
  }
  contact-items += (link("mailto:" + basics.email)[#basics.email],)
  contact-items += (link(basics.url)[#basics.url],)
  for p in basics.at("profiles", default: ()) {
    if p.network == "GitHub" {
      contact-items += (link(p.url)[GitHub: #p.username],)
    }
  }

  grid(
    columns: (1fr, auto),
    align(left + bottom)[
      #text(size: 24pt, weight: "bold", fill: fg)[#basics.name]
    ],
    align(right + bottom)[
      #stack(
        dir: ttb,
        spacing: 0.3em,
        align(right)[#text(size: 11pt, fill: subtle)[#basics.label]],
        v(0.75em),
        align(right)[#text(size: 9pt, fill: subtle)[#contact-items.join(contact-sep)]],
      )
    ],
  )
}

// ── top-level summary ────────────────────────────────────────────────────────

#{
  let summary = data.basics.at("summary", default: none)
  if include-summary and summary != none [
    #v(0.75em)
    #text(size: 10pt, fill: subtle)[#summary]
    #v(0.1em)
  ]
}

// ── education ─────────────────────────────────────────────────────────────────

#section("Education")

#for edu in data.education [
  #entry-header(
    edu.studyType + ", " + edu.area,
    edu.institution,
    date-range(edu.startDate, edu.at("endDate", default: none)),
  )
  #v(0.5em)
]

// ── experience ────────────────────────────────────────────────────────────────

#section("Experience")

#let jobs = data.work.slice(0, calc.min(work-limit, data.work.len()))

#for job in jobs {
  let job-name = job.name
  let all-highlights = job.at("highlights", default: ())

  // filter highlights by index if variant specifies them
  let indices = work-highlight-map.at(job-name, default: none)
  let highlights = if indices == none {
    all-highlights
  } else {
    indices.map(i => all-highlights.at(i))
  }

  [
    #entry-header(
      job.position,
      job.name,
      date-range(job.startDate, job.at("endDate", default: none)),
    )
    #let summary = job.at("summary", default: none)
    #if summary != none [
      #v(0.45em)
      #text(size: 9pt, style: "italic", fill: subtle)[#summary]
    ]
    #v(0.4em)
    #for h in highlights [
      - #parse-inline(h)
    ]
    #v(0.55em)
  ]
}

// ── skills ────────────────────────────────────────────────────────────────────

#section("Skills")

#for s in data.skills [
  #text(weight: "bold")[#s.name: ]#text(fill: subtle)[#s.keywords.join(" · ")] \
]

// ── projects ──────────────────────────────────────────────────────────────────

#let show-project(proj) = [
  #entry-header(
    proj.name,
    proj.at("entity", default: ""),
    date-range(proj.at("startDate", default: none), proj.at("endDate", default: none)),
  )
  #let desc = proj.at("description", default: none)
  #if desc != none [
    #v(0.15em)
    #text(size: 9.5pt, style: "italic", fill: subtle)[#desc]
  ]
  #v(0.1em)
  #let highlights = proj.at("highlights", default: ())
  #for h in highlights [
    - #parse-inline(h)
  ]
  #v(0.1em)
]

#if projects-setting != false and "projects" in data {
  let all-projects = data.projects
  let filtered = if projects-setting == true {
    all-projects
  } else {
    // array of names — filter to those names in order they appear in data
    all-projects.filter(p => projects-setting.contains(p.name))
  }

  if filtered.len() > 0 {
    section("Projects")
    for proj in filtered {
      show-project(proj)
    }
  }
}

// ── publications ──────────────────────────────────────────────────────────────

#if include-publications and "publications" in data [
  #section("Publications")

  #for pub in data.publications [
    #let first-author = pub.authors.at(0)
    #let others = pub.authors.slice(1)
    #let author-items = if others.len() > 0 {
      (underline(first-author),) + others
    } else {
      (underline(first-author),)
    }
    #let authors = author-items.join(", ")
    #text(size: 9.5pt)[
      #link(pub.url)[#authors (#pub.releaseDate). "#pub.name." _#pub.publisher._]
    ]
    #v(0.35em)
  ]
]
