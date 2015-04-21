%{
#include <stdio.h>
#include "y.tab.h"
#include "traitement.h"
#define YY_NO_INPUT

extern char * yylval_char;  
extern void yyerror(const char *);  /* prints grammar violation message */


 
%}

%option nounput

%s TAB
%x TAB1

%%
"\\begin{document}"      {return(BEGIN_DOC); }
"\\end{document}"        {return(END_DOC); }

"\\begin{itemize}"       {return(BEGIN_ITEMIZE); }
"\\end{itemize}"         {return(END_ITEMIZE); }

"\\begin{enumerate}"     {return(BEGIN_ENUMERATE); }
"\\end{enumerate}"       {return(END_ENUMERATE); }

"\\item"                 {return(ITEM); }
  
"\\begin{tabular}"       {BEGIN TAB; return(BEGIN_TABULAR);}
<TAB>"\\end{tabular}"         {BEGIN INITIAL; return(END_TABULAR);}

<TAB>"\\\\"                   {return(NEW_LINE); }
<TAB>"&"                      {return(NEW_CASE); }
<TAB>"\{"[lrc]+"\}"          ;
  
"\\backslash"            {fprintf(flot_html,"\\"); printf("\\"); }
"\\{"                    {fprintf(flot_html,"{"); printf("{"); }
"\\}"                    {fprintf(flot_html,"}"); printf("}"); }
"\\["                    {fprintf(flot_html,"["); printf("["); }
"\\]"                    {fprintf(flot_html,"]"); printf("]"); }
"\\&"                    {fprintf(flot_html,"&"); printf("&"); }
"\\$"                    {fprintf(flot_html,"$"); printf("$"); }

.                        {yylval_char = strcpy(yylval_char, yytext);printf(yytext);return(BODY);}


%%

  
