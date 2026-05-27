# Makefile — josephvoss/resume
#
# Targets:
#   make               — build all variants (PDF + blog markdown)
#   make pdf           — all PDF variants
#   make blog          — all blog markdown variants
#   make pdf-full      — full CV PDF
#   make pdf-short     — short one-page PDF
#   make blog-full     — full blog markdown
#   make blog-short    — short blog markdown
#   make clean         — remove output/
#   make validate      — validate resume.json against JSON Resume schema (requires ajv-cli)

DATA     := resume.json
VARIANTS := full short
TEMPLATE := templates/resume.typ
BLOG_SH  := templates/blog.md.sh
OUTDIR   := output

TYPST    := typst
JQ       := jq

FONT_PATHS := --font-path /System/Library/Fonts \
              --font-path /System/Library/Fonts/Supplemental \
              --font-path $(HOME)/Library/Fonts

# ── default ───────────────────────────────────────────────────────────────────

.PHONY: all
all: pdf blog

# ── PDF ───────────────────────────────────────────────────────────────────────

.PHONY: pdf
pdf: $(addprefix pdf-, $(VARIANTS))

.PHONY: $(addprefix pdf-, $(VARIANTS))
$(addprefix pdf-, $(VARIANTS)): pdf-%: $(OUTDIR)/resume-%.pdf

$(OUTDIR)/resume-%.pdf: $(DATA) variants/%.json $(TEMPLATE) | $(OUTDIR)
	$(TYPST) compile \
		--input data=../$(DATA) \
		--input variant=../variants/$*.json \
		--root . \
		$(FONT_PATHS) \
		$(TEMPLATE) \
		$@

# ── Blog Markdown ─────────────────────────────────────────────────────────────

.PHONY: blog
blog: $(addprefix blog-, $(VARIANTS))

.PHONY: $(addprefix blog-, $(VARIANTS))
$(addprefix blog-, $(VARIANTS)): blog-%: $(OUTDIR)/resume-%.md

$(OUTDIR)/resume-%.md: $(DATA) variants/%.json $(BLOG_SH) | $(OUTDIR)
	$(BLOG_SH) variants/$*.json > $@

# ── Utility ───────────────────────────────────────────────────────────────────

$(OUTDIR):
	mkdir -p $(OUTDIR)

.PHONY: clean
clean:
	rm -rf $(OUTDIR)

.PHONY: validate
validate:
	@command -v ajv >/dev/null 2>&1 || { echo "ajv-cli not found. Install with: npm i -g ajv-cli"; exit 1; }
	ajv validate \
		-s https://raw.githubusercontent.com/jsonresume/resume-schema/v1.0.0/schema.json \
		-d $(DATA)

.PHONY: help
help:
	@echo "Targets:"
	@echo "  all         Build all variants (PDF + blog markdown)"
	@echo "  pdf         All PDF variants"
	@echo "  blog        All blog markdown variants"
	@echo "  pdf-full    Full CV PDF"
	@echo "  pdf-short   Short one-page PDF"
	@echo "  blog-full   Full blog markdown"
	@echo "  blog-short  Short blog markdown"
	@echo "  clean       Remove output/"
	@echo "  validate    Validate resume.json against JSON Resume schema"
