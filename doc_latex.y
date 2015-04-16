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

%token BEGIN_DOC END_DOC
%token PARAM OPT IDENTIFIER
//%token EXEMPLE//


%%

document
: BEGIN_DOC  body END_DOC
;


body
: command l_end_command
;

l_end_command
: command l_end_command
|
;

command
: IDENTIFIER PARAM  // \begin{document}
| IDENTIFIER OPT  
| IDENTIFIER PARAM OPT
| IDENTIFIER // \newpage

;



