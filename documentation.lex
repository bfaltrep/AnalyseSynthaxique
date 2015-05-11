%e  1019
%p  2807
%n  371
%k  284
%a  1213
%o  1117

O   [0-7]
D   [0-9]
NZ  [1-9]
L   [a-zA-Z_]
A   [a-zA-Z_0-9]
H   [a-fA-F0-9]
HP  (0[xX])
E   ([Ee][+-]?{D}+)
P   ([Pp][+-]?{D}+)
FS  (f|F|l|L)
IS  (((u|U)(l|L|ll|LL)?)|((l|L|ll|LL)(u|U)?))
CP  (u|U|L)
SP  (u8|u|U|L)
ES  (\\([\'\"\?\\abfnrtv]|[0-7]{1,3}|x[a-fA-F0-9]+))
WS  [ \t\v\n\f]

%{
  
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <stdbool.h>
#include "y.tab.h"
#include "traitement.h"
#include "pile/stack.h"
#include "list/list.h"
  
  //-- var globales
extern char * yylval_char;
extern char * yylval_string_numb;
extern char * commandeActuelle;
extern int indentation;

//-- fonctions importées
extern void yyerror(const char *);  /* prints grammar violation message */
//extern int sym_type(const char *);  /* returns type from symbol table */

 //-- fonction locale
#define sym_type(identifier) IDENTIFIER /* with no symbol table, fake it */

static void ouverture_comm_doxy(void);
static void fermeture_comm_doxy(void);
static void lecture_ecriture_doxy(void);
 
static void clean_caractere(char c);
static void commentaire_debut();
static void commentaire_fin();
static void commentline();
static void preproc();
 
static int check_type(void);
 
%}

%x DOXY
%x COMMENT

%%
"/**"                   { ouverture_comm_doxy(); BEGIN DOXY; }
"/*!"                   { ouverture_comm_doxy(); BEGIN DOXY; }
<DOXY>"*"               { lecture_ecriture_doxy(); }
<DOXY>"*/"              { fermeture_comm_doxy(); BEGIN INITIAL; }


"/*"                    { BEGIN COMMENT; commentaire_debut();}
<COMMENT>\n             { new_line(indentation+1); }
<COMMENT>.              { char c = yytext[0]; clean_caractere(c);}
<COMMENT>"*/"           { BEGIN INITIAL; commentaire_fin(); }


"//"                    { commentline(); }

"auto"			{ return(AUTO); }
"break"			{ return(BREAK); }
"case"			{ return(CASE); }
"char"			{ return(CHAR); }
"const"			{ return(CONST); }
"continue"		{ return(CONTINUE); }
"default"		{ return(DEFAULT); }
"do"			{ return(DO); }
"double"		{ return(DOUBLE); }
"else"			{ return(ELSE); }
"enum"			{ return(ENUM); }
"extern"		{ return(EXTERN); }
"float"			{ return(FLOAT); }
"for"			{ return(FOR); }
"goto"			{ return(GOTO); }
"if"			{ return(IF); }
"inline"		{ return(INLINE); }
"int"			{ return(INT); }
"long"			{ return(LONG); }
"register"		{ return(REGISTER); }
"restrict"		{ return(RESTRICT); }
"return"		{ return(RETURN); }
"short"			{ return(SHORT); }
"signed"		{ return(SIGNED); }
"sizeof"		{ return(SIZEOF); }
"static"		{ return(STATIC); }
"struct"		{  return(STRUCT); }
"switch"		{ return(SWITCH); }
"typedef"	        { return(TYPEDEF); }
"union"			{ return(UNION); }
 "unsigned"		{ return(UNSIGNED); }
"void"			{ return(VOID); }
"volatile"	        { return(VOLATILE); }
"while"		        { return(WHILE); }
"_Alignas"              { return ALIGNAS; }
"_Alignof"              { return ALIGNOF; }
"_Atomic"               { return ATOMIC; }
"_Bool"                 { return BOOL; }
"_Complex"              { return COMPLEX; }
"_Generic"              { return GENERIC; }
"_Imaginary"            { return IMAGINARY; }
"_Noreturn"             { return NORETURN; }
"_Static_assert"        { return STATIC_ASSERT; }
"_Thread_local"         { return THREAD_LOCAL; }
"__func__"              { return FUNC_NAME; }

{L}{A}*			{ asprintf(&yylval_char,yytext); return check_type(); }

{HP}{H}+{IS}?		{ asprintf(&yylval_string_numb,yytext); return I_CONSTANT; }
{NZ}{D}*{IS}?		{ asprintf(&yylval_string_numb,yytext); return I_CONSTANT; }
"0"{O}*{IS}?		{ asprintf(&yylval_string_numb,yytext); return I_CONSTANT; }
{CP}?"'"([^\'\\\n]|{ES})+"'"		{ asprintf(&yylval_string_numb,yytext); return I_CONSTANT; }

{D}+{E}{FS}?				{ return F_CONSTANT; }
{D}*"."{D}+{E}?{FS}?			{ return F_CONSTANT; }
{D}+"."{E}?{FS}?        		{ return F_CONSTANT; }
{HP}{H}+{P}{FS}?	       		{ return F_CONSTANT; }
{HP}{H}*"."{H}+{P}{FS}?			{ return F_CONSTANT; }
{HP}{H}+"."{P}{FS}?			{ return F_CONSTANT; }

({SP}?\"([^\"\\\n]|{ES})*\"{WS}*)+	{/*pour une raison que je n'ai pas réussis a comprendre, il refuse asprintf ici... y aurait il une taille maximale possible pour les char * à faire passer ?*/
  yylval_string_numb= malloc(sizeof(char)*(strlen(yytext)+1));
  strcpy(yylval_string_numb, yytext);
  return STRING_LITERAL; }

"..."				{ return ELLIPSIS; }
">>="				{ return RIGHT_ASSIGN; }
"<<="				{ return LEFT_ASSIGN; }
"+="				{ return ADD_ASSIGN; }
"-="				{ return SUB_ASSIGN; }
"*="				{ return MUL_ASSIGN; }
"/="				{ return DIV_ASSIGN; }
"%="				{ return MOD_ASSIGN; }
"&="				{ return AND_ASSIGN; }
"^="				{ return XOR_ASSIGN; }
"|="				{ return OR_ASSIGN; }
">>"				{ return RIGHT_OP; }
"<<"				{ return LEFT_OP; }
"++"				{ return INC_OP; }
"--"				{ return DEC_OP; }
"->"				{ return PTR_OP; }
"&&"				{ return AND_OP; }
"||"				{ return OR_OP; }
"<="				{ return LE_OP; }
">="				{ return GE_OP; }
"=="				{ return EQ_OP; }
"!="				{ return NE_OP; }
";"				{ return ';'; }

("{"|"<%")			{ return '{'; }
("}"|"%>")			{ return '}'; }

","				{ return ','; }
":"				{ return ':'; }
"="				{ return '='; }
"("				{ return '('; }
")"				{ return ')'; }
("["|"<:")			{ return '['; }
("]"|":>")			{ return ']'; }
"."				{ return '.'; }
"&"				{ return '&'; }
"!"				{ return '!'; }
"~"				{ return '~'; }
"-"				{ return '-'; }
"+"				{ return '+'; }
"*"				{ return '*'; }
"/"				{ return '/'; }
"%"				{ return '%'; }
"<"				{ return '<'; }
">"				{ return '>'; }
"^"				{ return '^'; }
"|"				{ return '|'; }
"?"				{ return '?'; }

"#"                     	{ preproc(); }

{WS}			        { /* whitespace separates tokens */ }
.				{ /* discard bad characters */ }

%%

int yywrap(void)        /* called at end of input */
{
  return 1;           /* terminate now */
}

static void clean_caractere(char c){
  if(c == '<'){
    fprintf(flot_html_c, "&lt;");
  }
  else if(c == '>'){
    fprintf(flot_html_c, "&gt;");
  }
  else{
    fprintf(flot_html_c, "%c",c);
  }
}

static void commentaire_debut(){
  fprintf(flot_html_c,"<span class=\"comment\">/*");
  char c = input();
  //pour la lisibilité, s'il n'y a pas d'espace en début de commentaire, on le rajoute
  if(c != ' '){
    fprintf(flot_html_c," ");
  }
  unput(c);
}

void commentaire_fin(){
  char c = yytext[-1];
  //s'il y a eu un saut de ligne en dernier, on doit décrémenter l'indentation*/
  if(c == '\n'){
    fseek(flot_html_c,-(strlen("&nbsp")*4),SEEK_CUR);
  }else if (c != ' '){
    //pour la lisibilité, on ajoute un espace avant de clore le commentaire s'il n'y en a pas
    fprintf(flot_html_c," ");
  }
  fprintf(flot_html_c,"*/</span>");
  new_line(indentation);
}

static void commentline(){
   fprintf(flot_html_c,"\n<span class=\"comment_line\">//");
   int c;
   while ((c = input()) != 0){
     if(c == '\n'){
       fprintf(flot_html_c, "</span>");
       new_line(indentation);
       return;
     }
     clean_caractere(c);
   }
}

static void preproc(){
  fprintf(flot_html_c,"\n<span class=\"preproc\">#");
  int c;
  int name = 1;
  while ((c = input()) != 0){
    //on change les caractères spéciaux du langage html
    switch(c){
    case '\n':
      if(name){
	name =0;
	fprintf(flot_html_c, "</span>");
      }
      new_line(indentation);
      return;
    case '<':
      fprintf(flot_html_c, "&lt;");
      break;
    case '>':
      fprintf(flot_html_c, "&gt;");
      break;
    case ' ':
      if(name){
	name =0;
	fprintf(flot_html_c, "</span>");
      }
    default:
      fprintf(flot_html_c, "%c",c);
      break;
    }
  }
}

bool verifier_existance_commande(){ //verifie que \cmd existe bien en doxygen
   return(
      strcmp(commandeActuelle, "brief")==0 ||
      strcmp(commandeActuelle, "param")==0 ||
      strcmp(commandeActuelle, "return")==0||
      strcmp(commandeActuelle, "fn")==0
      );
}
void ouverture_comm_doxy(void){
   int c;
   c=input();
   while(c!='\n'){
      c=input();
   }
   fprintf(flot_html_doc, "<div class=\"fonction\"> ");
}

void fermeture_comm_doxy(void){
  fprintf(flot_html_doc, "</div> ");
}

void lecture_ecriture_doxy(void)
{
  int c;
  int cptEspace = 0;
  char * contenu= calloc(400, sizeof(*contenu)); //taille de la longueur de la commande
   
  while ((c = input()) != 0){
    if(c == '\n'){ //si on est en fin de ligne, on sort de la fin et on
                   //écrit dans le flux de sortie html
      fprintf(flot_html_doc, "<div class=\"%s\"> %s </div>", commandeActuelle, contenu);
      free(contenu);
      return;
    }
    else if(c == '\\'){ // mise à jour de la nouvelle commande doxygen
      commandeActuelle[0]='\0';
      while((c=input()) != ' '){
	commandeActuelle = strcat( commandeActuelle, (char*)&c);
      }
      assert(verifier_existance_commande() && "unterminated command");
      //ajout de texte dans le doxyhtml
      if (strcmp(commandeActuelle, "param")==0){
	fprintf(flot_html_doc, "<div class=\"paramTitle\"> Parametre </div>");
      }
      else if (strcmp(commandeActuelle, "return")==0){
	fprintf(flot_html_doc, "<div class=\"returnTitle\"> Renvoie </div>");
      }
    }
    else if(c == ' '){ // suppression des espaces inutiles
      cptEspace++;
      if (cptEspace==1){
	contenu = strcat( contenu, (char*)&c);
      }
    }
    else if(c != '*'){ // 
      cptEspace=0;
      contenu = strcat( contenu, (char*)&c);
    }
  }
  free(contenu);
  yyerror("unterminated comment");
}

static int check_type(void)
{
    switch (sym_type(yytext))
    {
    case TYPEDEF_NAME:                /* previously defined */
        return TYPEDEF_NAME;
    case ENUMERATION_CONSTANT:        /* previously defined */
        return ENUMERATION_CONSTANT;
    default:                          /* includes undefined */
        return IDENTIFIER;
    }
}
/*déclaration dans traitement.h pour être utilisable dans documentation.y*/
void condition_sans_accolade(){
  if(bool_cond){
    bool_cond = 0;
  }
  char c = input();
  if(c != '{'){
    new_line(indentation+1);
  }
  unput(c);
}
