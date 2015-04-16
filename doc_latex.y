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

%token BODY

%%

document: BEGIN_DOC body END_DOC
;

body: BODY body
| BODY itemize body
| BODY enumerate body
| 
;

itemize: BEGIN_ITEMIZE body_itemize END_ITEMIZE
;

body_itemize: ITEM body body_itemize
|
;

enumerate: BEGIN_ENUMERATE body_enumerate END_ENUMERATE
;

body_enumerate: ITEM body body_enumerate
|
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
