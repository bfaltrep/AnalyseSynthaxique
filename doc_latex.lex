%{
#include <stdio.h>
#include "y.tab.h"
#include "traitement.h"
#define YY_NO_INPUT

extern char * yylval_char;
extern char * param_tabular;
extern int index_param_tabular;
int param();
extern void tabular_param(char * param_tabular,char * param, int length);
extern void yyerror(const char *);  /* prints grammar violation message */

 
%}

%option nounput
%option stack
%option noyy_top_state noyy_pop_state

%s TAB FAT SECTION SUBSECTION SUBSUBSECTION
%x PARAMTAB

%%
"\\begin{document}"      {return(BEGIN_DOC); }
"\\end{document}"        {return(END_DOC); }

"\\begin{itemize}"       {return(BEGIN_ITEMIZE); }
"\\end{itemize}"         {return(END_ITEMIZE); }

"\\begin{enumerate}"     {return(BEGIN_ENUMERATE); }
"\\end{enumerate}"       {return(END_ENUMERATE); }

"\\item"                 {return(ITEM); }
  
"\\begin{tabular}"       {yy_push_state(PARAMTAB); return(BEGIN_TABULAR);}
<TAB>"\\end{tabular}"    {BEGIN INITIAL;return(END_TABULAR);}

<TAB>"\\\\"              {index_param_tabular=0;return(NEW_LINE); }
<TAB>"&"                 {++index_param_tabular;return param();}
<PARAMTAB>"\{"[lrc]+"\}"          {yy_push_state(TAB);tabular_param(param_tabular,yytext,(int)yyleng);index_param_tabular=0;return param();}

"\\backslash"            {fprintf(flot_html,"\\"); printf("\\"); }
"\\{"                    {fprintf(flot_html,"{"); printf("{"); }
"\\}"                    {fprintf(flot_html,"}"); printf("}"); }
"\\["                    {fprintf(flot_html,"["); printf("["); }
"\\]"                    {fprintf(flot_html,"]"); printf("]"); }
"\\&"                    {fprintf(flot_html,"&"); printf("&"); }
"\\$"                    {fprintf(flot_html,"$"); printf("$"); }

"\\texttt{"              {yy_push_state(FAT); fprintf(flot_html,"<b>"); }
"{\\bf"                  {yy_push_state(FAT); fprintf(flot_html,"<b>"); }
<FAT>"}"                 {fprintf(flot_html,"</b>"); }


"\\section{"             {yy_push_state(SECTION);fprintf(flot_html,"<h1>"); }
"\\subsection{"          {yy_push_state(SUBSECTION); fprintf(flot_html,"<h2>"); }
"\\subsubsection{"       {yy_push_state(SUBSUBSECTION); fprintf(flot_html,"<h3>"); }
<SECTION>"}"             {BEGIN INITIAL; fprintf(flot_html,"</h1>"); }
<SUBSECTION>"}"          {BEGIN INITIAL; fprintf(flot_html,"</h2>"); }
<SUBSUBSECTION>"}"       {BEGIN INITIAL; fprintf(flot_html,"</h3>"); }

.                        {yylval_char = strcpy(yylval_char, yytext);printf(yytext);return(BODY);}


%%

int param(){
  if (param_tabular[index_param_tabular]=='l'){
    return(NEW_CASE_L);}
  else if (param_tabular[index_param_tabular]=='c'){
    return(NEW_CASE_C);}
  else{
    return(NEW_CASE_R);}
}
