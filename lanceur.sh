make clean
make all
./doc_latex Index index.html < rapport_index.tex
./doc_latex LateX latex.html < rapport_latex.tex
./documentation < txt.c
firefox index.html  &
