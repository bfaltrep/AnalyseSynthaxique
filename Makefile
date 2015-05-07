
LDLIBS=-ly -lfl -lm
CFLAGS=  -g -Wall -Werror -D_GNU_SOURCE


YACC=bison -d -v

documentation : documentation.c lex.yy.c traitement.c ./pile/stack_array.c ./list/list.c

lex.yy.c : documentation.lex 
	flex documentation.lex

documentation.tab.c : documentation.y traitement.h 
	$(YACC) documentation.y

txt :
	./documentation < txt.c
	firefox index.html comDoxy.html &
	emacs index.html style.css script.js comDoxy.html txt.c &

clean:
	rm -rf *.o documentation.c lex.yy.c documentation.tab.c documentation.tab.h *~ *.output *.tab.h  *.html *.css *.js ./pile/*~ ./pile/*.o ./list/*~ ./list/*.o 

