
LDLIBS=-ly -lfl
CFLAGS=-Wall -Werror -g

YACC=bison -d -v

documentation : documentation.c lex.yy.c traitement.c

lex.yy.c : documentation.lex
	flex documentation.lex

documentation.tab.c : documentation.y traitement.h 
	$(YACC) documentation.y

clean:
	rm -rf *.o documentation.c lex.yy.c documentation.tab.c documentation.tab.h *~ *.output *.tab.h  *.html *.css
