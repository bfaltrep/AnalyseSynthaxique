%{
#include <stdio.h>
#include <stdbool.h>
#include "y.tab.h"
#include "traitement.h"
#include "Pile/stack.h"
#include "File/queue.h"
#define YY_NO_INPUT

extern char * yylval_char;
extern char * param_tabular;
extern int index_param_tabular;
extern void tabular_param(char * param_tabular,char * param, int length);
extern void yyerror(const char *);  /* prints grammar violation message */
 
 
int param();
void create_tdm();
  
queue q;
 
%}

%option nounput
%option stack
%option noyy_top_state

%s TAB
%s FAT ITALIC UNDERLINE COLOR COMMENT
%s SECTION SUBSECTION SUBSUBSECTION
%s EQUATION MATH_ML
%x LAB
%x PARAMTAB
%x COLOR1
%x IMAGE

%%

"\\begin{document}"      {fprintf(flot_html,"<p style=\"text-indent:2em\">"); q = queue_create(); return(BEGIN_DOC); }
"\\end{document}"        {fprintf(flot_html,"</p>"); queue_destroy(q); return(END_DOC); }


"\\documentclass"("["[[:alnum:],]*"]")+("{"[[:alnum:],]*"}")+ {;}
"\\usepackage"("["[[:alnum:],]*"]")*("{"[[:alnum:],]*"}")* {;}

"\\includegraphics"[[:alnum:]\[\]]*"{" {yy_push_state(IMAGE);}
<IMAGE>[[:alnum:]._]+"}"   {printf("%s",yytext);yytext[yyleng-1]='\0';printf("%s",yytext);fprintf(flot_html,"<p><a href=%s><img src=%s></a></p>",yytext,yytext);yy_pop_state();}


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


"\\begin{equation}"|"\\begin{equation*}"|"$$"      {yy_push_state(EQUATION); return(BEGIN_EQUATION); }
<EQUATION>"\\end{equation}"|"\\end{equation*}"|"$$"        {yy_pop_state(); return(END_EQUATION); }

<EQUATION>"\\label{"     {yy_push_state(LAB); return(LABEL); }
<LAB>"}"                 {yy_pop_state(); fprintf(flot_html,")</t>"); }

"\\("|"$"|"\\begin{math}"  {yy_push_state(MATH_ML); return(BEGIN_MATH_ML);}
<MATH_ML>"\\)"|"$"|"\\end{math}"   {yy_pop_state(); return(END_MATH_ML);}

"\\textbackslash "        {fprintf(flot_html,"\\"); printf("\\"); }
"\\textbackslash\\textbackslash" {fprintf(flot_html,"\\\\"); printf("\\\\"); }
"\\{"                    {fprintf(flot_html,"{"); printf("{"); }
"\\}"                    {fprintf(flot_html,"}"); printf("}"); }
"\["                      {fprintf(flot_html,"["); printf("["); }
"\]"                      {fprintf(flot_html,"]"); printf("]"); }
"\\&"                    {fprintf(flot_html,"&"); printf("&"); }
"\\$"                    {fprintf(flot_html,"$"); printf("$"); }
"\\_"                    {fprintf(flot_html,"_"); printf("_"); }
"\\textasciitilde "       {fprintf(flot_html,"~"); printf("~"); }
"\\textasciicircum "      {fprintf(flot_html,"^"); printf("^"); }




"\\texttt{"|"{\\bf"      {yy_push_state(FAT);return(FORME_FAT); }
<FAT>"}"                 {yy_pop_state();fprintf(flot_html,"</b>"); }
"\\textit{"|"{\\itshape" {yy_push_state(ITALIC);return(FORME_ITALIC); }
<ITALIC>"}"              {yy_pop_state();fprintf(flot_html,"</i>"); }
"\\underline{"           {yy_push_state(UNDERLINE);return(FORME_UNDERLINE); }
<UNDERLINE>"}"           {yy_pop_state();fprintf(flot_html,"</u>"); }
"\\textcolor{"[[:alpha:]]+ {yy_push_state(COLOR1); fprintf(flot_html,"<font color=%s>",yytext+11); }
<COLOR1>"}{"             {yy_pop_state(); yy_push_state(COLOR);}
<COLOR>"}"               {yy_pop_state();fprintf(flot_html,"</font>"); }


"%"                      {yy_push_state(COMMENT);fprintf(flot_html,"<!--"); }
<COMMENT>("\n")+         {yy_pop_state();fprintf(flot_html,"-->"); }



"\\section{"             {yy_push_state(SECTION);fprintf(flot_html,"<h1>"); }
"\\subsection{"          {yy_push_state(SUBSECTION); fprintf(flot_html,"<h2>"); }
"\\subsubsection{"       {yy_push_state(SUBSUBSECTION); fprintf(flot_html,"<h3>"); }

<SECTION>"}"             {yy_pop_state(); fprintf(flot_html,"</h1>"); }
<SUBSECTION>"}"          {yy_pop_state(); fprintf(flot_html,"</h2>"); }
<SUBSUBSECTION>"}"       {yy_pop_state(); fprintf(flot_html,"</h3>"); }

<SECTION>.               {yylval_char = strcpy(yylval_char, yytext); queue_push(q,1,yytext); printf(yytext); return(BODY); }
<SUBSECTION>.            {yylval_char = strcpy(yylval_char, yytext); queue_push(q,2,yytext); printf(yytext); return(BODY); }
<SUBSUBSECTION>.         {yylval_char = strcpy(yylval_char, yytext); queue_push(q,3,yytext); printf(yytext); return(BODY); }

[\t\v\f\n\r]              {fprintf(flot_html," ");}
[\t\v\f\n\r][\t\v\f\n\r]+ {fprintf(flot_html,"</p><p style=\"text-indent:2em\">");}
"\\\\"|"\\newline"        {fprintf(flot_html, "<br>");}

  
.                         {yylval_char = strcpy(yylval_char, yytext); printf(yytext); return(BODY); }


%%

int param(){
  if (param_tabular[index_param_tabular]=='l'){
    return(NEW_CASE_L);}
  else if (param_tabular[index_param_tabular]=='c'){
    return(NEW_CASE_C);}
  else{
    return(NEW_CASE_R);}
}

void create_tdm()
{
  while(!queue_empty(q))
    {
      switch(queue_front_val1(q))
	{
	case 1:
	  fprintf(flot_html,queue_front_val2(q));
	  break;
	case 2:
	  fprintf(flot_html,"<t class=\"subsection\">");
	  fprintf(flot_html,queue_front_val2(q));
	  fprintf(flot_html,"</t>");
	  break;
	case 3:
	  fprintf(flot_html,"<t class=\"subsubsection\">");
	  fprintf(flot_html,queue_front_val2(q));
	  fprintf(flot_html,"</t>");
	  break;
	  }
      queue_pop(q);
    }
}

