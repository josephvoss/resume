# resume

Source code for updating and building my resume. Content is stored in
`resume.json` following the [jsonresume](https://jsonresume.org/) effort, and
letting me worry about content first and typesetting later. Optionally supports
variants that are deep merged from `variants` to render different versions.

Renders to PDF using [Typst](https://typst.app), using the templates stored
under `templates`.

## Usage

```sh
make              # build everything
make pdf-full     # full CV PDF only
make blog-short   # short blog markdown only
make clean        # remove output/
make validate     # validate resume.json schema (requires ajv-cli)
```

## Adding a variant

1. Create `variants/yourvariant.json` with include options (see existing variants for reference)
2. Add `yourvariant` to `VARIANTS` in the Makefile
