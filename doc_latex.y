%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "traitement.h"

int yylex();

//-- locals functions
char * yylval_char;
char * param_tabular;
int index_param_tabular;
void tabular_param(char * param_tabular,char * param, int length);
void yyerror(const char *s);


%}

%output "y.tab.c"

%token BEGIN_DOC END_DOC 
%token BEGIN_ITEMIZE END_ITEMIZE
%token BEGIN_ENUMERATE END_ENUMERATE
%token ITEM
%token BEGIN_TABULAR PARAM_TABULAR END_TABULAR
%token NEW_CASE_L NEW_CASE_C NEW_CASE_R NEW_CASE NEW_LINE
%token BEGIN_EQUATION END_EQUATION 
%token BEGIN_MATH_ML END_MATH_ML 
%token LABEL
%token FORME_FAT FORME_ITALIC FORME_UNDERLINE FORME_TITLE FORME_AUTHOR
%token BEG_PARAGRAPH END_PARAGRAPH
%token BODY

%%


document: BEGIN_DOC body END_DOC
;

body: BODY {fprintf(flot_html,yylval_char); } body
| itemize body
| enumerate body
| tabular body
| equation body
| math body
| LABEL {fprintf(flot_html,"<t class=\"label_equation\">\(");} body
| FORME_TITLE {fprintf(flot_html,"<center><t class=\"title\">");} body
| FORME_AUTHOR{fprintf(flot_html,"<center><t class=\"author\">");} body 
| FORME_FAT {fprintf(flot_html,"<b>");} body
| FORME_ITALIC {fprintf(flot_html,"<i>");} body
| FORME_UNDERLINE {fprintf(flot_html,"<u>");} body
|
;

itemize: BEGIN_ITEMIZE {fprintf(flot_html,"<ul>");} body_itemize END_ITEMIZE {fprintf(flot_html,"</ul>");}
;

body_itemize: {fprintf(flot_html,"<li>");} ITEM body {fprintf(flot_html,"</li>");} body_itemize
| 
;

enumerate: BEGIN_ENUMERATE  {fprintf(flot_html,"<ol>");} body_enumerate END_ENUMERATE {fprintf(flot_html,"</ol>");}
;

body_enumerate: {fprintf(flot_html,"<li>");} ITEM body {fprintf(flot_html,"</li>");} body_enumerate
|
;

tabular: BEGIN_TABULAR {fprintf(flot_html,"<table>");} {fprintf(flot_html,"<tr>");} body_tabular END_TABULAR {fprintf(flot_html,"</tr></table>");}
;

body_tabular: body_tabular_l
|body_tabular_c
|body_tabular_r
|
;

body_tabular_l: new_case_l line_ body_tabular_l2
;

body_tabular_l2: case_l line_ body_tabular_l2
|
;

body_tabular_c: new_case_c line_ body_tabular_c2
;

body_tabular_c2: case_c line_ body_tabular_c2
|
;

body_tabular_r: new_case_r line_ body_tabular_r2
;

body_tabular_r2: case_r line_ body_tabular_r2
|
;

new_case_: new_case_l
|new_case_c
|new_case_r
|
;

new_case_l: NEW_CASE_L case_l
;

new_case_c: NEW_CASE_C case_c
;

new_case_r: NEW_CASE_R case_r
;

case_l:{fprintf(flot_html,"<td align=\"left\">");} body {fprintf(flot_html,"</td>");} new_case_
;

case_c:{fprintf(flot_html,"<td align=\"center\">");} body {fprintf(flot_html,"</td>");} new_case_
;

case_r:{fprintf(flot_html,"<td align=\"right\">");} body {fprintf(flot_html,"</td>");} new_case_
;

line_: NEW_LINE {fprintf(flot_html,"</tr><tr>");}
;

equation: BEGIN_EQUATION {fprintf(flot_html,"<p style=\"text-indent:2em\">");} body END_EQUATION {fprintf(flot_html,"</p>");}
;

math: BEGIN_MATH_ML {fprintf(flot_html,"<math display=\"inline\">");}  END_MATH_ML {fprintf(flot_html,"</mrow></math>");}
;


%%

void yyerror(const char *s)
{
  fflush(stdout);
  fprintf(stderr, "*** %s\n", s);
}

void tabular_param(char * param_tabular,char * param, int length){
  int i =1;
  while (i!=length-1){
      param_tabular[i-1]=param[i];
      ++i;
  }
}

int main()
{
  yylval_char=malloc(sizeof(char)*60);
  param_tabular=malloc(sizeof(char)*10); //pas plus de 10 colonnes
  index_param_tabular=0;
  create_files("Partie LateX","latex.html");
  create_menu();
  yyparse();
  finish();
  free(yylval_char);
  free(param_tabular);
  return EXIT_SUCCESS;
    
}
