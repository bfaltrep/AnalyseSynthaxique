
LDLIBS=-ly -lfl
CFLAGS=-Wall -Werror -g

YACC=bison -d -v

doc_latex : doc_latex.c lex.yy.c traitement.c

lex.yy.c : doc_latex.lex
	flex doc_latex.lex

doc_latex.tab.c : doc_latex.y traitement.h 
	$(YACC) doc_latex.y

clean:
	rm -rf *.o doc_latex.c lex.yy.c doc_latex.tab.c doc_latex.tab.h *~ *.output *.tab.h  *.html *.css
