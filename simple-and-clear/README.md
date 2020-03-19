Latex locally is really hard. Add these files to overleaf and let them compile
it for you.

Build HTML using htlatex locally

```
cd src
htlatex resume.tex
(Hit enter a lot)
mv resume.html ..
find ./ -type f -not -name resume.tex -not -name resume.cls -delete
```
