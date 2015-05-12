

LDLIBS=-ly -lfl -lm
CFLAGS=  -g -Wall -Werror -D_GNU_SOURCE

YACC=bison -d -v

all : documentation doc_latex

documentation : documentation.c lex.yy.c traitement.c ./pile/stack_array.c ./list/list.c

lex.yy.c : documentation.lex 
	flex documentation.lex

documentation.tab.c : documentation.y traitement.h
	$(YACC) documentation.y


doc_latex : doc_latex.c lex_latex.yy.c traitement.c ./pile/stack_array.c ./list/list.c

lex_latex.yy.c : doc_latex.lex
	flex -olex_latex.yy.c doc_latex.lex

doc_latex.tab.c : doc_latex.y traitement.h

clean:
	rm -rf *.o doc_latex.c documentation.c lex.yy.c doc_latex.tab.c documentation.tab.c *~ *.output *.tab.h  *.html *.css *.js ./pile/*~ ./pile/*.o ./list/*~ ./list/*.o doc_latex *.toc *.log 

