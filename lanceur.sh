make clean
make all
./doc_latex Index index.html < rapport_index.tex
./doc_latex LateX latex.html < rapport_latex.tex
./doc_latex LateX rapport_c.html < rapport_c.tex
./documentation < txt.c

firefox index.html  &
