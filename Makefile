
CFLAGS = -ly -lfl

YACC = bison -d -v


calculette : documentation.tab.c lex.yy.c
	gcc documentation.tab.c lex.yy.c $(CFLAGS) -o documentation


lex.yy.c : documentation.lex
	flex documentation.lex


documentation.tab.c : documentation.y
	$(YACC) documentation.y
documentation.tab.h : documentation.y
	$(YACC) documentation.y
documentation.output : documentation.y
	$(YACC) documentation.y


clean:
	rm -rf *.o *.c *~ *.output *.tab.h *.css *.html
