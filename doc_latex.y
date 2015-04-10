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

//-- var globales
char * yylval_char;

%}

%output "y.tab.c"

//%token EXEMPLE//
%token BEGIN_DOC END_DOC IDENTIFIER

%%

document
: BEGIN_DOC  body END_DOC
;


body
: instruction l_end_instruction
;

instruction
: IDENTIFIER '[' PARAM ']'
| IDENTIFIER TEXT
;

l_end_instruction
: instruction l_end_instruction
|
;
