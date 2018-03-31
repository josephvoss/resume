sed -i "/\RequirePackage{fontspec}/s/%//" ./simpleresumecv.cls
latexmk -xelatex resume.tex
pdftk resume.pdf cat 1 output outfile.pdf
mv outfile.pdf resume.pdf
