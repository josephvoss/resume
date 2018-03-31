sed -i "/\RequirePackage{fontspec}/s/^/%/" ./simpleresumecv.cls
htlatex resume.tex "xhtml, charset=utf-8" " -cunihtf -utf8"
sed -i s/$(echo -e "\\u0393")/$(echo -e "\\u2022")/ ./resume.html
sed -i '1d' ./resume.html
sed -i '1d' ./resume.html

