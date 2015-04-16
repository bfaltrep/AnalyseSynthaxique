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

//ce lien peut t'être utile ;)
//http://tex.loria.fr/general/aide-memoire-latex-seguin1998.pdf
"\begin"    {test_argumment(); test_option(); return(BEGIN_DOC); }
"\end"      {return(END_DOC); }


"\title"    {return(END_DOC); }

.          {ECHO;}


"\\"                 {printf("\n");}

%%

  
