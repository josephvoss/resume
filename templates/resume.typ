// resume.typ — Typst template for josephvoss/resume
// Reads resume.json (JSON Resume schema) + a variant config.
//
// Usage:
//   typst compile --input data=../resume.json --input variant=../variants/full.json \
//     --root . --font-path Fonts templates/resume.typ output/resume-full.pdf

#let data    = json(sys.inputs.at("data",    default: "../resume.json"))
#let variant = json(sys.inputs.at("variant", default: "../variants/full.json"))

// ── helpers ──────────────────────────────────────────────────────────────────

#let include-publications = variant.at("include", default: (:)).at("publications", default: true)
#let include-location     = variant.at("include", default: (:)).at("location",     default: true)
#let work-limit           = variant.at("include", default: (:)).at("work_limit",   default: 999)

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

#let date-range(start, end) = [
  #fmt-date(start) #h(0.2em)–#h(0.2em) #fmt-date(end)
]

// ── page setup ────────────────────────────────────────────────────────────────

#set page(
  paper: "us-letter",
  margin: (top: 0.5in, bottom: 0.45in, left: 0.6in, right: 0.6in),
)

#set text(font: "Times New Roman", size: 11pt)
#set par(leading: 0.55em)

// ── section heading ───────────────────────────────────────────────────────────

#let section(title) = {
  v(0.6em)
  text(weight: "bold", size: 11pt, upper(title))
  line(length: 100%, stroke: 0.5pt)
  v(0.2em)
}

// ── name / contact block ──────────────────────────────────────────────────────

#let basics = data.basics

#let contact-items = (link(basics.url)[#basics.url],)
#if include-location {
  contact-items += (basics.location.city + ", " + basics.location.region,)
}
#{ contact-items += (basics.phone, basics.email) }

#align(center)[
  #text(size: 20pt, weight: "bold")[#basics.name]
  #v(0.3em)
  #text(size: 10pt)[
    #contact-items.map(it => [#it]).join([#h(0.5em)•#h(0.5em)])
  ]
]

// ── education ─────────────────────────────────────────────────────────────────

#section("Education")

#for edu in data.education [
  #grid(
    columns: (1fr, auto),
    [*#edu.studyType, #edu.area* \ #edu.institution],
    [#date-range(edu.startDate, edu.at("endDate", default: none))],
  )
]

// ── experience ────────────────────────────────────────────────────────────────

#section("Experience")

#let jobs = data.work.slice(0, calc.min(work-limit, data.work.len()))

#for job in jobs [
  #grid(
    columns: (1fr, auto),
    [*#job.position* \ #job.name],
    [#date-range(job.startDate, job.at("endDate", default: none))],
  )
  #v(0.2em)
  #for h in job.highlights [
    - #h
  ]
  #v(0.4em)
]

// ── skills ────────────────────────────────────────────────────────────────────

#section("Skills")

#for s in data.skills [
  #text(weight: "bold")[#s.name:] #s.keywords.join(" · ") \
]

// ── publications ──────────────────────────────────────────────────────────────

#if include-publications [
  #section("Publications")

  #for pub in data.publications [
    #let first-author = pub.authors.at(0)
    #let others = pub.authors.slice(1)
    #let authors = if pub.authors.len() > 1 {
      underline(first-author) + ", " + others.join(", ")
    } else {
      underline(first-author)
    }
    #link(pub.url)[#authors (#pub.releaseDate). "#pub.name." _#pub.publisher._]
    #v(0.4em)
  ]
]
