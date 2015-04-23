%{
#include <stdio.h>
#include <stdbool.h>
#include "y.tab.h"
#include "traitement.h"
#include "Pile/stack.h"
#define YY_NO_INPUT

extern char * yylval_char;
extern char * param_tabular;
extern int index_param_tabular;
extern void tabular_param(char * param_tabular,char * param, int length);
extern void yyerror(const char *);  /* prints grammar violation message */

int param(); 

 
%}

%option nounput
%option stack
%option noyy_top_state

%s TAB
%s FAT ITALIC UNDERLINE COLOR COMMENTAIRE
%s SECTION SUBSECTION SUBSUBSECTION
%s MAT
%x PARAMTAB
%x COLOR1

%%

"\\begin{document}"      {return(BEGIN_DOC); }
"\\end{document}"        {return(END_DOC); }

"\\documentclass"("["[[:alnum:],]*"]")+("{"[[:alnum:],]*"}")+ {;}
"\\usepackage"("["[[:alnum:],]*"]")*("{"[[:alnum:],]*"}")* {;}

"\\begin{itemize}"       {return(BEGIN_ITEMIZE); }
"\\end{itemize}"         {return(END_ITEMIZE); }

"\\begin{enumerate}"     {return(BEGIN_ENUMERATE); }
"\\end{enumerate}"       {return(END_ENUMERATE); }

"\\item"                 {return(ITEM); }

"\\begin{tabular}"       {yy_push_state(PARAMTAB); return(BEGIN_TABULAR); }
<TAB>"\\end{tabular}"    {yy_pop_state();return(END_TABULAR); }

<TAB>"\\\\"              {index_param_tabular=0;return(NEW_LINE); }
<TAB>"&"                 {++index_param_tabular;return param(); }

<PARAMTAB>"\{"[lrc]+"\}" {yy_pop_state();yy_push_state(TAB);tabular_param(param_tabular,yytext,(int)yyleng);index_param_tabular=0;return param(); }



"\\textbackslash"        {fprintf(flot_html,"\\"); printf("\\"); }
"\\{"                    {fprintf(flot_html,"{"); printf("{"); }
"\\}"                    {fprintf(flot_html,"}"); printf("}"); }
"$\\left["               {yy_push_state(MAT);fprintf(flot_html,"["); printf("["); }
<MAT>"\\right]$"         {yy_pop_state();fprintf(flot_html,"]"); printf("]"); }
"\\&"                    {fprintf(flot_html,"&"); printf("&"); }
"\\$"                    {fprintf(flot_html,"$"); printf("$"); }
"\\_"                    {fprintf(flot_html,"_"); printf("_"); }
"\\textasciitilde"       {fprintf(flot_html,"~"); printf("~"); }
"\\textasciicircum"      {fprintf(flot_html,"^"); printf("^"); }



"\\texttt{"|"{\\bf"      {yy_push_state(FAT);return(FORME_FAT); }
<FAT>"}"                 {yy_pop_state();fprintf(flot_html,"</b>"); }
"\\textit{"|"{\\itshape" {yy_push_state(ITALIC);return(FORME_ITALIC); }
<ITALIC>"}"              {yy_pop_state();fprintf(flot_html,"</i>"); }
"\\underline{"           {yy_push_state(UNDERLINE);return(FORME_UNDERLINE); }
<UNDERLINE>"}"           {yy_pop_state();fprintf(flot_html,"</u>"); }
"\\textcolor{"[[:alpha:]]+ {yy_push_state(COLOR1); fprintf(flot_html,"<font color=%s>",yytext+11); printf("%s\n",yytext+11); }
<COLOR1>"}{"             {yy_pop_state(); yy_push_state(COLOR);}
<COLOR>"}"               {yy_pop_state();fprintf(flot_html,"</font>"); }


"%"                      {yy_push_state(COMMENTAIRE);fprintf(flot_html,"<!--"); }
<COMMENTAIRE>"\n"        {yy_pop_state();fprintf(flot_html,"-->"); }



"\\section{"             {yy_push_state(SECTION);fprintf(flot_html,"<h1>"); }
"\\subsection{"          {yy_push_state(SUBSECTION); fprintf(flot_html,"<h2>"); }
"\\subsubsection{"       {yy_push_state(SUBSUBSECTION); fprintf(flot_html,"<h3>"); }
<SECTION>"}"             {yy_pop_state(); fprintf(flot_html,"</h1>"); }
<SUBSECTION>"}"          {yy_pop_state(); fprintf(flot_html,"</h2>"); }
<SUBSUBSECTION>"}"       {yy_pop_state(); fprintf(flot_html,"</h3>"); }

.                        {yylval_char = strcpy(yylval_char, yytext);printf(yytext);return(BODY); }


%%

int param(){
  if (param_tabular[index_param_tabular]=='l'){
    return(NEW_CASE_L);}
  else if (param_tabular[index_param_tabular]=='c'){
    return(NEW_CASE_C);}
  else{
    return(NEW_CASE_R);}
}
