
LDLIBS=-ly -lfl
CFLAGS=-Wall -Werror -g

YACC=bison -d -v

doc_latex : doc_latex.c lex_latex.yy.c traitement.c ./File/queue.h ./File/queue.c

lex_latex.yy.c : doc_latex.lex
	flex -olex_latex.yy.c doc_latex.lex

doc_latex.tab.c : doc_latex.y traitement.h

clean:
	rm -rf *.o doc_latex.c lex.yy.c doc_latex.tab.c doc_latex.tab.h *~ *.output *.tab.h  *.html *.css *.js doc_latex
