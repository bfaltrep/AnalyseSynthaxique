%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <fcntl.h>
  
  /*#ifndef TRAITEMENT_H
    #define TRAITEMENT_H*/
#include "traitement.h"
  //#endif
  
  /*#ifndef STACK_H
    #define STACK_H*/
#include "pile/stack.h"
  //#endif
  
extern int yylex();
extern int yylex_destroy();

//-- locals functions
extern char * yylval_char;
char * param_tabular;
int index_param_tabular;
void tabular_param(char * param_tabular,char * param, int length);
void yyerror(const char *s);
stack file_stack;



%}

%output "y.tab.c"

%token BEGIN_DOC END_DOC
%token COMMANDE_BEG COMMANDE_END
%token ENVIRONMENT_BEG ENVIRONMENT_END
%token NB_PARAM_CMD_BEG NB_PARAM_CMD_END
%token BEGIN_ITEMIZE END_ITEMIZE
%token BEGIN_ENUMERATE END_ENUMERATE
%token ITEM
%token BEGIN_TABULAR PARAM_TABULAR END_TABULAR
%token NEW_CASE_L NEW_CASE_C NEW_CASE_R NEW_CASE NEW_LINE
%token BEGIN_EQUATION END_EQUATION 
%token BEGIN_MATH_ML END_MATH_ML
%token MATH_BODY
%token MATH_SUP_BEG MATH_SUP_END MATH_SUP
%token MATH_SUB_BEG MATH_SUB_END MATH_SUB
%token MATH_SQRT_BEG MATH_SQRT_ROOT_END
%token MATH_ROOT_BEG MATH_ROOT_INTER
%token MATH_FRAC_BEG MATH_FRAC_INTER MATH_FRAC_END
%token FORME_FAT FORME_ITALIC FORME_UNDERLINE FORME_TITLE FORME_AUTHOR
%token BEG_PARAGRAPH END_PARAGRAPH
%token BODY

%%


document: BEGIN_DOC body END_DOC
;

body: BODY {fprintf(flot_html_latex,yylval_char); } body
| COMMANDE_BEG COMMANDE_END body
| ENVIRONMENT_BEG ENVIRONMENT_END body
| NB_PARAM_CMD_BEG NB_PARAM_CMD_END body
| itemize body
| enumerate body
| tabular body
| equation body
| math body
| FORME_TITLE {fprintf(flot_html_latex,"<center><t class=\"title\">");} body
| FORME_AUTHOR{fprintf(flot_html_latex,"<center><t class=\"author\">");} body 
| FORME_FAT {fprintf(flot_html_latex,"<b>");} body
| FORME_ITALIC {fprintf(flot_html_latex,"<i>");} body
| FORME_UNDERLINE {fprintf(flot_html_latex,"<u>");} body
|
;

math_body: MATH_BODY math_body
| MATH_SQRT_BEG {fprintf(flot_html_latex,"<msqrt>");} math_body MATH_SQRT_ROOT_END {fprintf(flot_html_latex,"</msqrt>");} math_body
| MATH_ROOT_BEG {fprintf(flot_html_latex,"<mroot><mrow>");} math_body MATH_ROOT_INTER {fprintf(flot_html_latex,"</mrow><mrow>");} math_body MATH_SQRT_ROOT_END {fprintf(flot_html_latex,"</mrow></mroot>");} math_body
| MATH_FRAC_BEG {fprintf(flot_html_latex,"<mfrac><mrow>");} math_body MATH_FRAC_INTER {fprintf(flot_html_latex,"</mrow><mrow>");} math_body MATH_FRAC_END {fprintf(flot_html_latex,"</mrow></mfrac>");} math_body
| MATH_SUP_BEG {fprintf(flot_html_latex,"<sup>");} math_body MATH_SUP_END {fprintf(flot_html_latex,"</sup>");} math_body
| MATH_SUP {fprintf(flot_html_latex,"<sup>");} MATH_BODY {fprintf(flot_html_latex,"</sup>");} math_body
| MATH_SUB_BEG {fprintf(flot_html_latex,"<sub>");} math_body MATH_SUB_END {fprintf(flot_html_latex,"</sub>");} math_body
| MATH_SUB {fprintf(flot_html_latex,"<sub>");} MATH_BODY {fprintf(flot_html_latex,"</sub>");} math_body
|
;

itemize: BEGIN_ITEMIZE {fprintf(flot_html_latex,"<ul>");} body_itemize END_ITEMIZE {fprintf(flot_html_latex,"</ul>");}
;

body_itemize: {fprintf(flot_html_latex,"<li>");} ITEM body {fprintf(flot_html_latex,"</li>");} body_itemize
| 
;

enumerate: BEGIN_ENUMERATE  {fprintf(flot_html_latex,"<ol>");} body_enumerate END_ENUMERATE {fprintf(flot_html_latex,"</ol>");}
;

body_enumerate: {fprintf(flot_html_latex,"<li>");} ITEM body {fprintf(flot_html_latex,"</li>");} body_enumerate
|
;

tabular: BEGIN_TABULAR {fprintf(flot_html_latex,"<table>");} {fprintf(flot_html_latex,"<tr>");} body_tabular END_TABULAR {fprintf(flot_html_latex,"</tr></table>");}
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

case_l:{fprintf(flot_html_latex,"<td align=\"left\">");} body {fprintf(flot_html_latex,"</td>");} new_case_
;

case_c:{fprintf(flot_html_latex,"<td align=\"center\">");} body {fprintf(flot_html_latex,"</td>");} new_case_
;

case_r:{fprintf(flot_html_latex,"<td align=\"right\">");} body {fprintf(flot_html_latex,"</td>");} new_case_
;

line_: NEW_LINE {fprintf(flot_html_latex,"</tr><tr>");}
;

equation: BEGIN_EQUATION {fprintf(flot_html_latex,"<p style=\"text-indent:2em\">");} body END_EQUATION {fprintf(flot_html_latex,"</p>");}
;

math: BEGIN_MATH_ML {fprintf(flot_html_latex,"<math display=\"inline\">");} math_body END_MATH_ML {fprintf(flot_html_latex,"</mrow></math>");}
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

int main(int argc, char *argv[])
{
  yylval_char=malloc(sizeof(char)*60);
  param_tabular=malloc(sizeof(char)*10); //pas plus de 10 colonnes
  index_param_tabular=0;
  create_files(0, argv[1], argv[2]);
  file_stack = stack_create();
  
  yyparse();
  
  finish_files(0);
  free(yylval_char);
  free(param_tabular);
  while (!stack_empty(file_stack)){
  	remove(stack_top(file_stack));
	//free(stack_top(file_stack));
	stack_pop(file_stack);
  } 
  stack_destroy(file_stack);
  yylex_destroy();
  return EXIT_SUCCESS;
    
}
