%{
#include <stdio.h>
#include "y.tab.h"
#include "traitement.h"
#define YY_NO_INPUT
extern void yyerror(const char *);  /* prints grammar violation message */

%}

%option nounput

%%
"\\begin{document}"    {return(BEGIN_DOC); }
"\\end{document}"      {return(END_DOC); }

"\\begin{itemize}"     {return(BEGIN_ITEMIZE); }
"\\end{itemize}"       {return(END_ITEMIZE); }

"\\begin{enumerate}"     {return(BEGIN_ENUMERATE); }
"\\end{enumerate}"       {return(END_ENUMERATE); }
  
"\\item"               {return(ITEM); }

.                      {ECHO; fprintf(flot_html, yytext);return(BODY);}


%%

  
