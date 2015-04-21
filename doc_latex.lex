%{
#include <stdio.h>
#include "y.tab.h"
#include "traitement.h"
#define YY_NO_INPUT

extern char * yylval_char;  
extern void yyerror(const char *);  /* prints grammar violation message */

 
%}

%option nounput

%s TAB FAT SECTION SUBSECTION SUBSUBSECTION
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

"\\texttt{"              {BEGIN FAT; fprintf(flot_html,"<b>"); }
<FAT>"}"                 {BEGIN INITIAL; fprintf(flot_html,"</b>"); }

"\\section{"             {BEGIN SECTION; fprintf(flot_html,"<h1>"); }
"\\subsection{"          {BEGIN SUBSECTION; fprintf(flot_html,"<h2>"); }
"\\subsubsection{"       {BEGIN SUBSUBSECTION; fprintf(flot_html,"<h3>"); }
<SECTION>"}"             {BEGIN INITIAL; fprintf(flot_html,"</h1>"); }
<SUBSECTION>"}"          {BEGIN INITIAL; fprintf(flot_html,"</h2>"); }
<SUBSUBSECTION>"}"       {BEGIN INITIAL; fprintf(flot_html,"</h3>"); }

.                        {yylval_char = strcpy(yylval_char, yytext);printf(yytext);return(BODY);}


%%

  
