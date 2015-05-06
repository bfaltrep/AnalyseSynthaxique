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
void remplir_queue(queue q, int n, char s);
void create_tdm();
  
queue q;
 
%}

%option nounput
%option stack
%option noyy_top_state

%s TAB
%s FAT ITALIC UNDERLINE COLOR COMMENT
%s SECTION SUBSECTION SUBSUBSECTION
%s EQUATION
%x MATH_ML MATH_ML_SQRT MATH_ML_FRAC1 MATH_ML_FRAC2 MATH_ML_SUP MATH_ML_SUB
%x LAB
%x PARAMTAB
%x COLOR1
%x IMAGE

%%

"\\begin{document}"          {fprintf(flot_html,"<p style=\"text-indent:2em\">"); q = queue_create(); return(BEGIN_DOC); }
"\\end{document}"            {fprintf(flot_html,"</p>"); queue_destroy(q); return(END_DOC); }


"\\documentclass"("["[[:alnum:],]*"]")+("{"[[:alnum:],]*"}")+ {;}
"\\usepackage"("["[[:alnum:],]*"]")*("{"[[:alnum:],]*"}")* {;}

"\\includegraphics"[[:alnum:]\[\]]*"{" {yy_push_state(IMAGE);}
<IMAGE>[[:alnum:]._]+"}"     {printf("%s",yytext);yytext[yyleng-1]='\0';printf("%s",yytext);fprintf(flot_html,"<p><a href=%s><img src=%s></a></p>",yytext,yytext);yy_pop_state();}


"\\begin{itemize}"           {return(BEGIN_ITEMIZE); }
"\\end{itemize}"             {return(END_ITEMIZE); }

"\\begin{enumerate}"         {return(BEGIN_ENUMERATE); }
"\\end{enumerate}"           {return(END_ENUMERATE); }

"\\item"                     {return(ITEM); }

"\\begin{tabular}"           {yy_push_state(PARAMTAB); return(BEGIN_TABULAR); }
<TAB>"\\end{tabular}"        {yy_pop_state();return(END_TABULAR); }

<TAB>"\\\\"                  {index_param_tabular=0;return(NEW_LINE); }
<TAB>"&"                     {++index_param_tabular;return param(); }

<PARAMTAB>"\{"[lrc]+"\}"     {yy_pop_state();yy_push_state(TAB);tabular_param(param_tabular,yytext,(int)yyleng);index_param_tabular=0;return param(); }


"\\begin{equation}"|"\\begin{equation*}"|"$$"      {yy_push_state(EQUATION); return(BEGIN_EQUATION); }
<EQUATION>"\\end{equation}"|"\\end{equation*}"|"$$"        {yy_pop_state(); return(END_EQUATION); }

<EQUATION>"\\label{"         {yy_push_state(LAB); return(LABEL); }
<LAB>"}"                     {yy_pop_state(); fprintf(flot_html,")</t>"); }

"\\("|"$"|"\\begin{math}"    {yy_push_state(MATH_ML); return(BEGIN_MATH_ML);}
<MATH_ML>"\\)"|"$"|"\\end{math}"   {yy_pop_state(); ;return(END_MATH_ML);}
<MATH_ML_SUP>"\\)"|"$"|"\\end{math}"   {fprintf(flot_html,"</sup>");yy_pop_state();yy_pop_state();return(END_MATH_ML);}
<MATH_ML_SUB>"\\)"|"$"|"\\end{math}"   {fprintf(flot_html,"</sub>");yy_pop_state();yy_pop_state();return(END_MATH_ML);}


<MATH_ML>[[:alpha:]]+        |
<MATH_ML_SQRT>[[:alpha:]]+   |
<MATH_ML_FRAC1>[[:alpha:]]+  |
<MATH_ML_FRAC2>[[:alpha:]]+  |
<MATH_ML_SUP>[[:alpha:]]+    |
<MATH_ML_SUB>[[:alpha:]]+    {fprintf(flot_html,"<mi>%s</mi>",yytext);}

<MATH_ML>[[:digit:]]+        |
<MATH_ML_SQRT>[[:digit:]]+   |    
<MATH_ML_FRAC1>[[:digit:]]+  |   
<MATH_ML_FRAC2>[[:digit:]]+  |  
<MATH_ML_SUP>[[:digit:]]+    |
<MATH_ML_SUB>[[:digit:]]+    {fprintf(flot_html,"<mn>%s</mn>",yytext);}

<MATH_ML>[[:blank:]]+        |
<MATH_ML_SQRT>[[:blank:]]+   |
<MATH_ML_FRAC1>[[:blank:]]+  |
<MATH_ML_FRAC2>[[:blank:]]+  |
<MATH_ML_SUP>[[:blank:]]+    |
<MATH_ML_SUB>[[:blank:]]+    {fprintf(flot_html," ");}

<MATH_ML>"^"                 |
<MATH_ML_SQRT>"^"            |
<MATH_ML_FRAC1>"^"           | 
<MATH_ML_FRAC2>"^"           |
<MATH_ML_SUP>"^"             |
<MATH_ML_SUB>"^"             {yy_push_state(MATH_ML_SUP);fprintf(flot_html,"<sup>");}
<MATH_ML_SUP>"}"             {yy_pop_state();fprintf(flot_html,"</sup>");}

<MATH_ML>"_"                 |
<MATH_ML_SQRT>"_"            |
<MATH_ML_FRAC1>"_"           |
<MATH_ML_FRAC2>"_"           |
<MATH_ML_SUP>"_"             |
<MATH_ML_SUB>"_"             {yy_push_state(MATH_ML_SUB);fprintf(flot_html,"<sub>");}
<MATH_ML_SUB>"}"             {yy_pop_state();fprintf(flot_html,"</sub>");}

<MATH_ML>"\\frac{"           |
<MATH_ML_SQRT>"\\frac{"      |
<MATH_ML_FRAC1>"\\frac{"     |
<MATH_ML_FRAC2>"\\frac{"     |
<MATH_ML_SUP>"\\frac{"       |
<MATH_ML_SUB>"\\frac{"       {yy_push_state(MATH_ML_FRAC1);fprintf(flot_html,"<mfrac><mrow>");}
<MATH_ML_FRAC1>"}{"          {yy_pop_state();yy_push_state(MATH_ML_FRAC2);fprintf(flot_html,"</mrow><mrow>");}
<MATH_ML_FRAC2>"}"           {yy_pop_state();fprintf(flot_html,"</mrow></mfrac>");}

<MATH_ML>"\\sqrt{"           |
<MATH_ML_SQRT>"\\sqrt{"      |
<MATH_ML_FRAC1>"\\sqrt{"     |
<MATH_ML_FRAC2>"\\sqrt{"     |
<MATH_ML_SUP>"\\sqrt{"       |
<MATH_ML_SUB>"\\sqrt{"       {yy_push_state(MATH_ML_SQRT);fprintf(flot_html,"<msqrt>");}
<MATH_ML_SQRT>"}"            {yy_pop_state();fprintf(flot_html,"</msqrt>");}


<MATH_ML>"{"                 {fprintf(flot_html,"<mrow>");}
<MATH_ML>"}"                 {fprintf(flot_html,"</mrow>");}

<MATH_ML>"("                 |
<MATH_ML_SQRT>"("            | 
<MATH_ML_FRAC1>"("           |  
<MATH_ML_FRAC2>"("           |  
<MATH_ML_SUP>"("             |
<MATH_ML_SUB>"("             {fprintf(flot_html,"<mrow><mo>(</mo><mrow>");}

<MATH_ML>")"                 |
<MATH_ML_SQRT>")"            |
<MATH_ML_FRAC1>")"           |
<MATH_ML_FRAC2>")"           |
<MATH_ML_SUP>")"             |
<MATH_ML_SUB>")"             {fprintf(flot_html,"</mrow><mo>)</mo></mrow>");}


<MATH_ML>"-"                 |
<MATH_ML_SQRT>"-"            |
<MATH_ML_FRAC1>"-"           |
<MATH_ML_FRAC2>"-"           |
<MATH_ML_SUP>"-"             |
<MATH_ML_SUB>"-"             {fprintf(flot_html,"<mo>&minus;</mo>");}

<MATH_ML>"\\times"           |
<MATH_ML_SQRT>"\\times"      |
<MATH_ML_FRAC1>"\\times"     |
<MATH_ML_FRAC2>"\\times"     |
<MATH_ML_SUP>"\\times"       |
<MATH_ML_SUB>"\\times"       {fprintf(flot_html,"<mo>&times;</mo>");}

<MATH_ML>"\\div"             |
<MATH_ML_SQRT>"\\div"        |
<MATH_ML_FRAC1>"\\div"       |
<MATH_ML_FRAC2>"\\div"       |
<MATH_ML_SUP>"\\div"         |
<MATH_ML_SUB>"\\div"         {fprintf(flot_html,"<mo>&divide;</mo>");}

<MATH_ML>"+"|"="|"/"         |
<MATH_ML_SQRT>"+"|"="|"/"    |
<MATH_ML_FRAC1>"+"|"="|"/"   |
<MATH_ML_FRAC2>"+"|"="|"/"   |
<MATH_ML_SUP>"+"|"="|"/"     |
<MATH_ML_SUB>"+"|"="|"/"     {fprintf(flot_html,"<mo>%s</mo>",yytext);}

<MATH_ML>"\\pm"              |
<MATH_ML_SQRT>"\\pm"         |
<MATH_ML_FRAC1>"\\pm"        |
<MATH_ML_FRAC2>"\\pm"        |
<MATH_ML_SUP>"\\pm"          |
<MATH_ML_SUB>"\\pm"          {fprintf(flot_html,"<mo>&plusmn;</mo>");}

<MATH_ML>"\\infty"           |
<MATH_ML_SQRT>"\\infty"      |
<MATH_ML_FRAC1>"\\infty"     |
<MATH_ML_FRAC>"\\infty"      |
<MATH_ML_SUP>"\\infty"       |
<MATH_ML_SUB>"\\infty"       {fprintf(flot_html,"<mo>&infin;</mo>");}


<MATH_ML>"\\neq"             {fprintf(flot_html,"<mo>&ne;</mo>");}
<MATH_ML>"\\equiv"           {fprintf(flot_html,"<mo>&equiv;</mo>");}
<MATH_ML>"\\sim"             {fprintf(flot_html,"<mo>&sim;</mo>");}
<MATH_ML>"\\approx"          {fprintf(flot_html,"<mo>&asymp;</mo>");}
<MATH_ML>"<"                 {fprintf(flot_html,"<mo>&lt;</mo>");}
<MATH_ML>"\\ll"              {fprintf(flot_html,"<mo>&lt;&lt;</mo>");}
<MATH_ML>"\\leq"             {fprintf(flot_html,"<mo>&le;</mo>");}
<MATH_ML>">"                 {fprintf(flot_html,"<mo>&gt;</mo>");}
<MATH_ML>"\\gg"              {fprintf(flot_html,"<mo>&gt;&gt;</mo>");}
<MATH_ML>"\\geq"             {fprintf(flot_html,"<mo>&ge;</mo>");}
<MATH_ML>"\\pm"              {fprintf(flot_html,"<mo>&plusmn;</mo>");}
<MATH_ML>"\\cdot"            {fprintf(flot_html,"<mo>.</mo>");}
<MATH_ML>"\\cdots"           {fprintf(flot_html,"<mo>...</mo>");}
<MATH_ML>"\|"                {fprintf(flot_html,"<mo>||</mo>");}
<MATH_ML>":"                 {fprintf(flot_html,"<mo>:</mo>");}
<MATH_ML>"\%"                {fprintf(flot_html,"<mo>%%</mo>");}
<MATH_ML>"!"                 {fprintf(flot_html,"!");}

<MATH_ML>"\\neg"             {fprintf(flot_html,"<mo>&not</mo>;");}
<MATH_ML>"\\wedge"           {fprintf(flot_html,"<mo>&and;</mo>");}
<MATH_ML>"\\vee"             {fprintf(flot_html,"<mo>&or;</mo>");}
<MATH_ML>"\\oplus"           {fprintf(flot_html,"<mo>&oplus;</mo>");}
<MATH_ML>"\\Rightarrow"      {fprintf(flot_html,"<mo>&rArr;</mo>");}
<MATH_ML>"\\Leftarrow"       {fprintf(flot_html,"<mo>&lArr;</mo>");}
<MATH_ML>"\\Leftrightarrow"  {fprintf(flot_html,"<mo>&hArr;</mo>");}
<MATH_ML>"\\exists"          {fprintf(flot_html,"<mo>&exist;</mo>");}
<MATH_ML>"\\forall"          {fprintf(flot_html,"<mo>&forall;</mo>");}
<MATH_ML>"\\&"               {fprintf(flot_html,"<mo>&amp;</mo>");}

<MATH_ML>"\\cap"             {fprintf(flot_html,"<mo>&cap;</mo>");}
<MATH_ML>"\\cup"             {fprintf(flot_html,"<mo>&cup;</mo>");}
<MATH_ML>"\\supset"          {fprintf(flot_html,"<mo>&sup;</mo>");}
<MATH_ML>"\\subset"          {fprintf(flot_html,"<mo>&sub;</mo>");}
<MATH_ML>"\\emptyset"        {fprintf(flot_html,"<mo>&empty;</mo>");}
<MATH_ML>"\\in"              {fprintf(flot_html,"<mo>&isin;</mo>");}
<MATH_ML>"\\notin"           {fprintf(flot_html,"<mo>&notin;</mo>");}

<MATH_ML>"\\prime"           {fprintf(flot_html,"<mo>&prime;</mo>");}
<MATH_ML>"\\rfloor"          {fprintf(flot_html,"<mo>&rfloor;</mo>");}
<MATH_ML>"\\lfloor"          {fprintf(flot_html,"<mo>&lfloor;</mo>");}

<MATH_ML>"\\varnothing"      {fprintf(flot_html,"<mo>&#2205;</mo>");}







"\\textbackslash "           {fprintf(flot_html,"\\"); printf("\\"); }
"\\textbackslash\\textbackslash" {fprintf(flot_html,"\\\\"); printf("\\\\"); }
"\\{"                        {fprintf(flot_html,"{"); printf("{"); }
"\\}"                        {fprintf(flot_html,"}"); printf("}"); }
"\["                         {fprintf(flot_html,"["); printf("["); }
"\]"                         {fprintf(flot_html,"]"); printf("]"); }
"\\&"                        {fprintf(flot_html,"&"); printf("&"); }
"\\$"                        {fprintf(flot_html,"$"); printf("$"); }
"\\_"                        {fprintf(flot_html,"_"); printf("_"); }
"\\textasciitilde "          {fprintf(flot_html,"~"); printf("~"); }
"\\textasciicircum "         {fprintf(flot_html,"^"); printf("^"); }




"\\texttt{"|"{\\bf"          {yy_push_state(FAT);return(FORME_FAT); }
<FAT>"}"                     {yy_pop_state();fprintf(flot_html,"</b>"); }
"\\textit{"|"{\\itshape"     {yy_push_state(ITALIC);return(FORME_ITALIC); }
<ITALIC>"}"                  {yy_pop_state();fprintf(flot_html,"</i>"); }
"\\underline{"               {yy_push_state(UNDERLINE);return(FORME_UNDERLINE); }
<UNDERLINE>"}"               {yy_pop_state();fprintf(flot_html,"</u>"); }
"\\textcolor{"[[:alpha:]]+   {yy_push_state(COLOR1); fprintf(flot_html,"<font color=%s>",yytext+11); }
<COLOR1>"}{"                 {yy_pop_state(); yy_push_state(COLOR);}
<COLOR>"}"                   {yy_pop_state();fprintf(flot_html,"</font>"); }


"%"                          {yy_push_state(COMMENT);fprintf(flot_html,"<!--"); }
<COMMENT>("\n")+             {yy_pop_state();fprintf(flot_html,"-->"); }



"\\section{"                 {yy_push_state(SECTION);fprintf(flot_html,"<h1>"); }
"\\subsection{"              {yy_push_state(SUBSECTION); fprintf(flot_html,"<h2>"); }
"\\subsubsection{"           {yy_push_state(SUBSUBSECTION); fprintf(flot_html,"<h3>"); }

<SECTION>"}"                 {yy_pop_state(); fprintf(flot_html,"</h1>"); }
<SUBSECTION>"}"              {yy_pop_state(); fprintf(flot_html,"</h2>"); }
<SUBSUBSECTION>"}"           {yy_pop_state(); fprintf(flot_html,"</h3>"); }

<SECTION>.                   {yylval_char = strcpy(yylval_char, yytext); remplir_queue(q,1,yylval_char[0]); printf(yytext); return(BODY); }
<SUBSECTION>.                {yylval_char = strcpy(yylval_char, yytext); remplir_queue(q,2,yylval_char[0]); printf(yytext); return(BODY); }
<SUBSUBSECTION>.             {yylval_char = strcpy(yylval_char, yytext); remplir_queue(q,3,yylval_char[0]); printf(yytext); return(BODY); }

[\t\v\f\n\r]                 {fprintf(flot_html," ");}
[\t\v\f\n\r][\t\v\f\n\r]+    {fprintf(flot_html,"</p><p style=\"text-indent:2em\">");}
"\\\\"|"\\newline"           {fprintf(flot_html, "<br>");}

"\\tableofcontents"          {create_tdm(); }
  
.                            {yylval_char = strcpy(yylval_char, yytext); printf(yytext); return(BODY); }


%%

int param(){
  if (param_tabular[index_param_tabular]=='l'){
    return(NEW_CASE_L);}
  else if (param_tabular[index_param_tabular]=='c'){
    return(NEW_CASE_C);}
  else{
    return(NEW_CASE_R);}
}

void remplir_queue(queue q, int n, char s)
{
  queue_push(q,n,s);
}

void create_tdm()
{
  while(!queue_empty(q))
    {
      switch(queue_front_val1(q))
	{
	case 1:
	  fprintf(flot_html,"%c",queue_front_val2(q));
	  break;
	case 2:
	  fprintf(flot_html,"<t class=\"subsection\">");
	  fprintf(flot_html,"%c",queue_front_val2(q));
	  fprintf(flot_html,"</t>");
	  break;
	case 3:
	  fprintf(flot_html,"<t class=\"subsubsection\">");
	  fprintf(flot_html,"%c",queue_front_val2(q));
	  fprintf(flot_html,"</t>");
	  break;
	default:fprintf(flot_html,"Erreur de Tdm");
	  }
      queue_pop(q);
    }
}
