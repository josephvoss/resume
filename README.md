My Resume
=============

Latex formatted resume using Zach Scrivena's Template, found [here](https://github.com/zachscrivena/simple-resume-cv/)

## Overview

The main XeLaTeX source file is `CV.tex`; the compiled document is `CV.pdf`.

Instructions for compiling the document (TeX &rarr;(XeLaTeX)&rarr; PDF):

- **Method 1:** Use `latexmk` for fully automated document generation:
	- `latexmk -xelatex "CV.tex"`
	(add the `-pvc` switch to automatically recompile on changes)

- **Method 2:** Use `XeLaTeX` directly:
	- `xelatex "CV.tex"`
	(run multiple times to resolve cross-references if needed)

## License

This is free and unencumbered software released into the public domain.
For more information, please see the file `LICENSE` or refer to <http://unlicense.org>.

## Recent Changes

- Release v3.0
	- Provides better support for other packages (e.g., biblatex) by removing the use of the longtable package for layout.
	- Note that this release introduces breaking changes; documents created using earlier releases of this template will need some minor changes to compile successfully.
