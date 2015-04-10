A   [a-zA-Z_0-9]
L   [a-zA-Z_]

%{
#include <stdio.h>
#include "y.tab.h"
  
extern void yyerror(const char *);  /* prints grammar violation message */

 void reecrire_yylval_char (){
  yylval_char = strcpy(yylval_char, yytext);
}
 
%}
%option nounput

%%
//On place ici tous les "mots clés" de LateX, on retrouve EXEMPLE dans le bison.
//"\exemple"           {return(EXEMPLE); }
"\begin_document"    {return(BEGIN_DOC); }
"\end_document"      {return(END_DOC); }


  

"\\"                 {printf("\n");}

%%

  
