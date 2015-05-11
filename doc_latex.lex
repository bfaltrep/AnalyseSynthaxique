%{
#include <stdio.h>
#include <stdbool.h>
#include <time.h>
#include <fcntl.h>
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
void date(void);
void empiler(char *);
void scan_cmd(char *);
void scan_cmd2(char *);

FILE * file=NULL;
char file_name[80];
stack file_stack;
long pos;
int par=0;
 
%}

%option nounput
%option stack
%option noyy_top_state

%s TAB
%s FAT ITALIC UNDERLINE COLOR COMMENT TITLE AUTHOR
%s SECTION SUBSECTION SUBSUBSECTION
%s SECTION_S SUBSECTION_S SUBSUBSECTION_S
%s EQUATION
%s PARAM_CMD
%x NB_PARAM_CMD
%x NEW_CMD
%x NEW_ENV
%x MATH_ML MATH_ML_SQRT MATH_ML_FRAC1 MATH_ML_FRAC2 MATH_ML_SUP MATH_ML_SUB
%s REF LABEL
%x REF_NAME LABEL_NAME LABEL_STAR
%x PARAMTAB
%x COLOR1
%x IMAGE

%%

"\\begin{document}"          {fprintf(flot_html_latex,"<p style=\"text-indent:2em\">"); return(BEGIN_DOC); }
"\\end{document}"            {fprintf(flot_html_latex,"</p>"); return(END_DOC); }


"\\documentclass"("["[[:alnum:],]*"]")+("{"[[:alnum:],]*"}")+ {;}
"\\usepackage"("["[[:alnum:],]*"]")*("{"[[:alnum:],]*"}")* {;}

"\\includegraphics"[[:alnum:]\[\]]*"{" {yy_push_state(IMAGE);}

<IMAGE>[[:alnum:]._]+"}"     {yytext[yyleng-1]='\0';fprintf(flot_html_latex,"<p><a href=%s><img src=%s></a></p>",yytext,yytext);yy_pop_state();}


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


"\\begin{equation}"|"$$"     {yy_push_state(EQUATION); return(BEGIN_EQUATION); }
<EQUATION>"\\end{equation}"|"$$"  {yy_pop_state(); return(END_EQUATION); }

"\\begin{equation*}"         {return(BEGIN_EQUATION); }
"\\end{equation*}"           {return(END_EQUATION); }

"\\ref{"[[:alnum:]]+         {yy_push_state(REF_NAME); fprintf(flot_html_latex,"<A HREF=\"#%s\">",yytext+5); }
<REF_NAME>"}{"               {yy_pop_state(); yy_push_state(REF); }
<REF>"}"                     {yy_pop_state(); fprintf(flot_html_latex,"</A>"); }

"\\label{"[[:alnum:]]+       {yy_push_state(LABEL_NAME); fprintf(flot_html_latex,"<A NAME=\"%s\">",yytext+7); }
<LABEL_NAME>"}{"             {yy_pop_state(); yy_push_state(LABEL); }
<LABEL>"}"                   {yy_pop_state(); fprintf(flot_html_latex,"</A>"); }

"\\label*{"[[:alnum:]]+      {yy_push_state(LABEL_STAR); fprintf(flot_html_latex,"<A NAME=\"%s\">",yytext+8); }
<LABEL_STAR>"}"              {yy_pop_state(); fprintf(flot_html_latex,"</A>"); }

"\\("|"$"|"\\begin{math}"    {yy_push_state(MATH_ML); return(BEGIN_MATH_ML);}
<MATH_ML>"\\)"|"$"|"\\end{math}"   {yy_pop_state(); ;return(END_MATH_ML);}
<MATH_ML_SUP>"\\)"|"$"|"\\end{math}"   {fprintf(flot_html_latex,"</sup>");yy_pop_state();yy_pop_state();return(END_MATH_ML);}
<MATH_ML_SUB>"\\)"|"$"|"\\end{math}"   {fprintf(flot_html_latex,"</sub>");yy_pop_state();yy_pop_state();return(END_MATH_ML);}

<MATH_ML>[[:alpha:]]+        |
<MATH_ML_SQRT>[[:alpha:]]+   |
<MATH_ML_FRAC1>[[:alpha:]]+  |
<MATH_ML_FRAC2>[[:alpha:]]+  |
<MATH_ML_SUP>[[:alpha:]]+    |
<MATH_ML_SUB>[[:alpha:]]+    {fprintf(flot_html_latex,"<mi>%s</mi>",yytext);return(MATH_BODY);}

<MATH_ML>[[:digit:]]+        |
<MATH_ML_SQRT>[[:digit:]]+   |    
<MATH_ML_FRAC1>[[:digit:]]+  |   
<MATH_ML_FRAC2>[[:digit:]]+  |  
<MATH_ML_SUP>[[:digit:]]+    |
<MATH_ML_SUB>[[:digit:]]+    {fprintf(flot_html_latex,"<mn>%s</mn>",yytext);return(MATH_BODY);}

<MATH_ML>[[:blank:]]+        |
<MATH_ML_SQRT>[[:blank:]]+   |
<MATH_ML_FRAC1>[[:blank:]]+  |
<MATH_ML_FRAC2>[[:blank:]]+  |
<MATH_ML_SUP>[[:blank:]]+    |
<MATH_ML_SUB>[[:blank:]]+    {fprintf(flot_html_latex," ");return(MATH_BODY);}

<MATH_ML>"^"                 |
<MATH_ML_SQRT>"^"            |
<MATH_ML_FRAC1>"^"           | 
<MATH_ML_FRAC2>"^"           |
<MATH_ML_SUP>"^"             |
<MATH_ML_SUB>"^"             {return(MATH_SUP);}
<MATH_ML>"^{"                |
<MATH_ML_SQRT>"^{"           |
<MATH_ML_FRAC1>"^{"          | 
<MATH_ML_FRAC2>"^{"          |
<MATH_ML_SUP>"^{"            |
<MATH_ML_SUB>"^{"            {yy_push_state(MATH_ML_SUP);return(MATH_SUP_BEG);}
<MATH_ML_SUP>"}"             {yy_pop_state();return(MATH_SUP_END);}

<MATH_ML>"_"                 |
<MATH_ML_SQRT>"_"            |
<MATH_ML_FRAC1>"_"           |
<MATH_ML_FRAC2>"_"           |
<MATH_ML_SUP>"_"             |
<MATH_ML_SUB>"_"             {return(MATH_SUB);}
<MATH_ML>"_{"                |
<MATH_ML_SQRT>"_{"           |
<MATH_ML_FRAC1>"_{"          |
<MATH_ML_FRAC2>"_{"          |
<MATH_ML_SUP>"_{"            |
<MATH_ML_SUB>"_{"            {yy_push_state(MATH_ML_SUB);return(MATH_SUB_BEG);}
<MATH_ML_SUB>"}"             {yy_pop_state();return(MATH_SUB_END);}

<MATH_ML>"\\frac{"           |
<MATH_ML_SQRT>"\\frac{"      |
<MATH_ML_FRAC1>"\\frac{"     |
<MATH_ML_FRAC2>"\\frac{"     |
<MATH_ML_SUP>"\\frac{"       |
<MATH_ML_SUB>"\\frac{"       {yy_push_state(MATH_ML_FRAC1);return(MATH_FRAC_BEG);}
<MATH_ML_FRAC1>"}{"          {yy_pop_state();yy_push_state(MATH_ML_FRAC2);return(MATH_FRAC_INTER);}
<MATH_ML_FRAC2>"}"           {yy_pop_state();return(MATH_FRAC_END);}

<MATH_ML>"\\sqrt{"           |
<MATH_ML_SQRT>"\\sqrt{"      |
<MATH_ML_FRAC1>"\\sqrt{"     |
<MATH_ML_FRAC2>"\\sqrt{"     |
<MATH_ML_SUP>"\\sqrt{"       |
<MATH_ML_SUB>"\\sqrt{"       {yy_push_state(MATH_ML_SQRT);return(MATH_SQRT_BEG);}
<MATH_ML_SQRT>"}"            {yy_pop_state();return(MATH_SQRT_ROOT_END);}

<MATH_ML>"{"                 {fprintf(flot_html_latex,"<mrow>");}
<MATH_ML>"}"                 {fprintf(flot_html_latex,"</mrow>");}

<MATH_ML>"("                 |
<MATH_ML_SQRT>"("            | 
<MATH_ML_FRAC1>"("           |  
<MATH_ML_FRAC2>"("           |  
<MATH_ML_SUP>"("             |
<MATH_ML_SUB>"("             {fprintf(flot_html_latex,"<mrow><mo>(</mo><mrow>");}

<MATH_ML>")"                 |
<MATH_ML_SQRT>")"            |
<MATH_ML_FRAC1>")"           |
<MATH_ML_FRAC2>")"           |
<MATH_ML_SUP>")"             |
<MATH_ML_SUB>")"             {fprintf(flot_html_latex,"</mrow><mo>)</mo></mrow>");}


<MATH_ML>"-"                 |
<MATH_ML_SQRT>"-"            |
<MATH_ML_FRAC1>"-"           |
<MATH_ML_FRAC2>"-"           |
<MATH_ML_SUP>"-"             |
<MATH_ML_SUB>"-"             {fprintf(flot_html_latex,"<mo>&minus;</mo>");}

<MATH_ML>"\\times"           |
<MATH_ML_SQRT>"\\times"      |
<MATH_ML_FRAC1>"\\times"     |
<MATH_ML_FRAC2>"\\times"     |
<MATH_ML_SUP>"\\times"       |
<MATH_ML_SUB>"\\times"       {fprintf(flot_html_latex,"<mo>&times;</mo>");}

<MATH_ML>"\\div"             |
<MATH_ML_SQRT>"\\div"        |
<MATH_ML_FRAC1>"\\div"       |
<MATH_ML_FRAC2>"\\div"       |
<MATH_ML_SUP>"\\div"         |
<MATH_ML_SUB>"\\div"         {fprintf(flot_html_latex,"<mo>&divide;</mo>");}

<MATH_ML>"+"|"="|"/"         |
<MATH_ML_SQRT>"+"|"="|"/"    |
<MATH_ML_FRAC1>"+"|"="|"/"   |
<MATH_ML_FRAC2>"+"|"="|"/"   |
<MATH_ML_SUP>"+"|"="|"/"     |
<MATH_ML_SUB>"+"|"="|"/"     {fprintf(flot_html_latex,"<mo>%s</mo>",yytext);}

<MATH_ML>"\\pm"              |
<MATH_ML_SQRT>"\\pm"         |
<MATH_ML_FRAC1>"\\pm"        |
<MATH_ML_FRAC2>"\\pm"        |
<MATH_ML_SUP>"\\pm"          |
<MATH_ML_SUB>"\\pm"          {fprintf(flot_html_latex,"<mo>&plusmn;</mo>");}

<MATH_ML>"\\infty"           |
<MATH_ML_SQRT>"\\infty"      |
<MATH_ML_FRAC1>"\\infty"     |
<MATH_ML_FRAC2>"\\infty"     |
<MATH_ML_SUP>"\\infty"       |
<MATH_ML_SUB>"\\infty"       {fprintf(flot_html_latex,"<mo>&infin;</mo>");}


<MATH_ML>"\\neq"             {fprintf(flot_html_latex,"<mo>&ne;</mo>");}
<MATH_ML>"\\equiv"           {fprintf(flot_html_latex,"<mo>&equiv;</mo>");}
<MATH_ML>"\\sim"             {fprintf(flot_html_latex,"<mo>&sim;</mo>");}
<MATH_ML>"\\approx"          {fprintf(flot_html_latex,"<mo>&asymp;</mo>");}
<MATH_ML>"<"                 {fprintf(flot_html_latex,"<mo>&lt;</mo>");}
<MATH_ML>"\\ll"              {fprintf(flot_html_latex,"<mo>&lt;&lt;</mo>");}
<MATH_ML>"\\leq"             {fprintf(flot_html_latex,"<mo>&le;</mo>");}
<MATH_ML>">"                 {fprintf(flot_html_latex,"<mo>&gt;</mo>");}
<MATH_ML>"\\gg"              {fprintf(flot_html_latex,"<mo>&gt;&gt;</mo>");}
<MATH_ML>"\\geq"             {fprintf(flot_html_latex,"<mo>&ge;</mo>");}
<MATH_ML>"\\cdot"            {fprintf(flot_html_latex,"<mo>.</mo>");}
<MATH_ML>"\\cdots"           {fprintf(flot_html_latex,"<mo>...</mo>");}
<MATH_ML>"\|"                {fprintf(flot_html_latex,"<mo>||</mo>");}
<MATH_ML>":"                 {fprintf(flot_html_latex,"<mo>:</mo>");}
<MATH_ML>"\%"                {fprintf(flot_html_latex,"<mo>%%</mo>");}
<MATH_ML>"!"                 {fprintf(flot_html_latex,"!");}

<MATH_ML>"\\neg"             {fprintf(flot_html_latex,"<mo>&not</mo>;");}
<MATH_ML>"\\wedge"           {fprintf(flot_html_latex,"<mo>&and;</mo>");}
<MATH_ML>"\\vee"             {fprintf(flot_html_latex,"<mo>&or;</mo>");}
<MATH_ML>"\\oplus"           {fprintf(flot_html_latex,"<mo>&oplus;</mo>");}
<MATH_ML>"\\Rightarrow"      {fprintf(flot_html_latex,"<mo>&rArr;</mo>");}
<MATH_ML>"\\Leftarrow"       {fprintf(flot_html_latex,"<mo>&lArr;</mo>");}
<MATH_ML>"\\Leftrightarrow"  {fprintf(flot_html_latex,"<mo>&hArr;</mo>");}
<MATH_ML>"\\exists"          {fprintf(flot_html_latex,"<mo>&exist;</mo>");}
<MATH_ML>"\\forall"          {fprintf(flot_html_latex,"<mo>&forall;</mo>");}
<MATH_ML>"\\&"               {fprintf(flot_html_latex,"<mo>&amp;</mo>");}

<MATH_ML>"\\cap"             {fprintf(flot_html_latex,"<mo>&cap;</mo>");}
<MATH_ML>"\\cup"             {fprintf(flot_html_latex,"<mo>&cup;</mo>");}
<MATH_ML>"\\supset"          {fprintf(flot_html_latex,"<mo>&sup;</mo>");}
<MATH_ML>"\\subset"          {fprintf(flot_html_latex,"<mo>&sub;</mo>");}
<MATH_ML>"\\emptyset"        {fprintf(flot_html_latex,"<mo>&empty;</mo>");}
<MATH_ML>"\\in"              {fprintf(flot_html_latex,"<mo>&isin;</mo>");}
<MATH_ML>"\\notin"           {fprintf(flot_html_latex,"<mo>&notin;</mo>");}

<MATH_ML>"\\prime"           {fprintf(flot_html_latex,"<mo>&prime;</mo>");}
<MATH_ML>"\\rfloor"          {fprintf(flot_html_latex,"<mo>&rfloor;</mo>");}
<MATH_ML>"\\lfloor"          {fprintf(flot_html_latex,"<mo>&lfloor;</mo>");}

<MATH_ML>"\\varnothing"      {fprintf(flot_html_latex,"<mo>&#2205;</mo>");}



"\\textbackslash "           {fprintf(flot_html_latex,"\\");}
"\\textbackslash\\textbackslash" {fprintf(flot_html_latex,"\\\\");}
"\\{"                        {fprintf(flot_html_latex,"{");}
"\\}"                        {fprintf(flot_html_latex,"}");}
"\["                         {fprintf(flot_html_latex,"[");}
"\]"                         {fprintf(flot_html_latex,"]");}
"\\&"                        {fprintf(flot_html_latex,"&");}
"\\$"                        {fprintf(flot_html_latex,"$");}
"\\_"                        {fprintf(flot_html_latex,"_");}
"\\textasciitilde "          {fprintf(flot_html_latex,"~");}
"\\textasciicircum "         {fprintf(flot_html_latex,"^");}


"\\title{"                   {yy_push_state(TITLE);return(FORME_TITLE); }
<TITLE>"}"                   {yy_pop_state(); fprintf(flot_html_latex,"</t></center>");}

"\\date{\\today}"            {date(); }

"\\author{"                  {yy_push_state(AUTHOR);return(FORME_AUTHOR); }
<AUTHOR>"}"                  {yy_pop_state(); fprintf(flot_html_latex,"</t></center>");}

"\\texttt{"|"{\\bf"          {yy_push_state(FAT);return(FORME_FAT); }
<FAT>"}"                     {yy_pop_state();fprintf(flot_html_latex,"</b>"); }
"\\textit{"|"{\\itshape"     {yy_push_state(ITALIC);return(FORME_ITALIC); }
<ITALIC>"}"                  {yy_pop_state();fprintf(flot_html_latex,"</i>"); }
"\\underline{"               {yy_push_state(UNDERLINE);return(FORME_UNDERLINE); }
<UNDERLINE>"}"               {yy_pop_state();fprintf(flot_html_latex,"</u>"); }

"\\textcolor{"[[:alpha:]]+   {yy_push_state(COLOR1); fprintf(flot_html_latex,"<font color=%s>",yytext+11); }
<COLOR1>"}{"                 {yy_pop_state(); yy_push_state(COLOR);}
<COLOR>"}"                   {yy_pop_state();fprintf(flot_html_latex,"</font>"); }


"%"                          {yy_push_state(COMMENT);fprintf(flot_html_latex,"<!--"); }
<COMMENT>("\n")+             {yy_pop_state();fprintf(flot_html_latex,"-->"); }

"\\section{"                 {yy_push_state(SECTION);fprintf(flot_html_latex,"<h1 class=\"tdm_part\">"); }
"\\subsection{"              {yy_push_state(SUBSECTION); fprintf(flot_html_latex,"<h2 class=\"tdm_part\">"); }
"\\subsubsection{"           {yy_push_state(SUBSUBSECTION); fprintf(flot_html_latex,"<h3 class=\"tdm_part\">"); }

<SECTION>"}"                 {yy_pop_state(); fprintf(flot_html_latex,"</h1>"); }
<SUBSECTION>"}"              {yy_pop_state(); fprintf(flot_html_latex,"</h2>"); }
<SUBSUBSECTION>"}"           {yy_pop_state(); fprintf(flot_html_latex,"</h3>"); }

<SECTION>.                   {yylval_char = strcpy(yylval_char, yytext);return(BODY); }
<SUBSECTION>.                {yylval_char = strcpy(yylval_char, yytext);return(BODY); }
<SUBSUBSECTION>.             {yylval_char = strcpy(yylval_char, yytext);return(BODY); }

"\\section*{"                 {yy_push_state(SECTION_S); fprintf(flot_html_latex,"<h1>"); }
"\\subsection*{"              {yy_push_state(SUBSECTION_S); fprintf(flot_html_latex,"<h2>"); }
"\\subsubsection*{"           {yy_push_state(SUBSUBSECTION_S); fprintf(flot_html_latex,"<h3>"); }

<SECTION_S>"}"               {yy_pop_state(); fprintf(flot_html_latex,"</h1>"); }
<SUBSECTION_S>"}"            {yy_pop_state(); fprintf(flot_html_latex,"</h2>"); }
<SUBSUBSECTION_S>"}"         {yy_pop_state(); fprintf(flot_html_latex,"</h3>"); }

<SECTION_S>.                 {yylval_char = strcpy(yylval_char, yytext); return(BODY); }
<SUBSECTION_S>.              {yylval_char = strcpy(yylval_char, yytext); return(BODY); }
<SUBSUBSECTION_S>.           {yylval_char = strcpy(yylval_char, yytext); return(BODY); }

[\t\v\f\n\r]                 {fprintf(flot_html_latex," ");}
[\t\v\f\n\r][\t\v\f\n\r]+    {fprintf(flot_html_latex,"</p><p style=\"text-indent:2em\">");}
"\\\\"|"\\newline"           {fprintf(flot_html_latex, "<br>");}

"\\tableofcontents"          {fprintf(flot_html_latex, "<div id=\"tdm\"></div>"); }

"\\newcommand{\\"[[:alpha:]]+"}{"  {++par;strcpy(file_name,"Latex_com_");strncat(file_name,yytext+13,strlen(yytext+12)-3);printf("%s",file_name);empiler(file_name);file=fopen(file_name,"w+");fprintf(file,"\\begin{document}\n");yy_push_state(NEW_CMD);return(COMMANDE_BEG);}

"\\newcommand{\\"[[:alpha:]]+"}["[[:digit:]]"]{"  {++par;strcpy(file_name,"Latex_com_");strncat(file_name,yytext+13,strlen(yytext+12)-6);strcat(file_name,"_");strncat(file_name,&yytext[yyleng-3],1);printf("%s",file_name);empiler(file_name);file=fopen(file_name,"w+");fprintf(file,"\\begin{document}\n");yy_push_state(NEW_CMD);return(COMMANDE_BEG);}

<NEW_CMD>"{"                 {++par;fputs(yytext,file);}

<NEW_CMD>"}"                 {--par;{if (par==0){yy_pop_state();fprintf(file,"\n\\end{document}\n");fclose(file);return(COMMANDE_END);} else {fputs(yytext,file);}}}

<NEW_CMD>[^{}]               {fputs(yytext,file);}

"\\newenvironment{"[[:alpha:]]+"}{"  {++par;strcpy(file_name,"Latex_env_");strncat(file_name,yytext+12,strlen(yytext+12)-2);printf("%s",file_name);empiler(file_name);file=fopen(file_name,"w+");fprintf(file,"\\begin{document}\n");yy_push_state(NEW_ENV);return(ENVIRONMENT_BEG);}

"\\newenvironment{"[[:alpha:]]+"}["[[:digit:]]"]{"  {++par;strcpy(file_name,"Latex_env_");strncat(file_name,yytext+12,strlen(yytext+12)-5);strcat(file_name,"_");strncat(file_name,&yytext[yyleng-3],1);empiler(file_name);;file=fopen(file_name,"w+");fprintf(file,"\\begin{document}\n");yy_push_state(NEW_ENV);return(ENVIRONMENT_BEG);}

<NEW_ENV>"{"                 {++par;fputs(yytext,file);}

<NEW_ENV>"}"                 {--par;{if (par==0){yy_pop_state();fprintf(file,"\n\\end{document}\n");fclose(file);return(ENVIRONMENT_END);} else {fputs(yytext,file);}}}

<NEW_ENV>[^{}]               {fputs(yytext,file);}


"\\"[[:alpha:]]+             {scan_cmd(yytext+1);}

.                            {yylval_char = strcpy(yylval_char, yytext); return(BODY); }


%%

int param(){
  if (param_tabular[index_param_tabular]=='l'){
    return(NEW_CASE_L);}
  else if (param_tabular[index_param_tabular]=='c'){
    return(NEW_CASE_C);}
  else{
    return(NEW_CASE_R);}
}

void date(void)
{
    time_t secondes;
    struct tm instant;
    time(&secondes);
    instant=*localtime(&secondes);
    fprintf(flot_html_latex,"<center>%d/%d/%d</center>", instant.tm_mday, instant.tm_mon+1, instant.tm_year+1900); 
}

void empiler(char * s){
  char * tmp;
  asprintf(&tmp, s);
  stack_push(file_stack,tmp);
}

void scan_cmd(char * tex){
  strcpy(file_name,"Latex_com_");
  strcat(file_name,tex);
  FILE * fp_in = fopen(file_name,"r");
  if (fp_in){
    YY_BUFFER_STATE test = yy_create_buffer(fp_in,YY_BUF_SIZE);
    yypush_buffer_state(test);
    yyparse();
    yypop_buffer_state();
  }
  else{
    fclose(fp_in);
    strcpy(file_name,"Latex_env_");
    strcat(file_name,tex);
    FILE * fp_in2 = fopen(file_name,"r");
    if (fp_in2){
      printf("env \n");
      YY_BUFFER_STATE test2 = yy_create_buffer(fp_in2,YY_BUF_SIZE);
      yypush_buffer_state(test2);
      yyparse();
      yypop_buffer_state();
    }
    else{
      fclose(fp_in2);
      yyerror("pas de commande correspondant à cette macro\n");
    }
  }
}

void scan_cmd2(char * tex){
  strcpy(file_name,"Latex_com_");
  strncat(file_name,tex,strlen(tex)-3);
  FILE * fp_in = fopen(file_name,"r");
  if (fp_in){
    YY_BUFFER_STATE test = yy_create_buffer(fp_in,YY_BUF_SIZE);
    yypush_buffer_state(test);
    yyparse();
    yypop_buffer_state();
  }
  else{
    yyerror("pas de commande correspondant à cette macro\n");
  }
  fclose(fp_in);
}
