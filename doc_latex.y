%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "traitement.h"
  
int yylex();

//-- locals functions
void yyerror(const char *s);


%}

%output "y.tab.c"

%token BEGIN_DOC END_DOC 
%token BEGIN_ITEMIZE END_ITEMIZE
%token BEGIN_ENUMERATE END_ENUMERATE
%token ITEM
%token BEGIN_TABULAR END_TABULAR
%token NEW_CASE
%token NEW_LINE
%token BODY

%%

document: BEGIN_DOC body END_DOC
;

body: BODY body
| itemize body
| enumerate body
| tabular body
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

tabular: BEGIN_TABULAR {fprintf(flot_html,"<table>");} body_tabular END_TABULAR {fprintf(flot_html,"</table>");}

body_tabular: {fprintf(flot_html,"<tr>");} case_ NEW_LINE {fprintf(flot_html,"</tr>");} body_tabular
;

case_: {fprintf(flot_html,"<td>");} body NEW_CASE {fprintf(flot_html,"</td>");} case_
;

%%

void yyerror(const char *s)
{
  fflush(stdout);
  fprintf(stderr, "*** %s\n", s);
}

int main()
{   
  create_files();
  yyparse();
  finish();
  return EXIT_SUCCESS;
    
}
