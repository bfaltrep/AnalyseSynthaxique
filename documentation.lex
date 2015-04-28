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
#include "y.tab.h"
#include "traitement.h"
#include "pile/stack.h"
#include "list/list.h"
  
  //-- var globales
extern char * yylval_char;
 
extern stack variables;
 extern list variables_name;
 
extern int indentation;
int inFor = 0;

 //fonctions importées
extern void yyerror(const char *);  /* prints grammar violation message */
extern int sym_type(const char *);  /* returns type from symbol table */
extern char * nommerVariable(char * variable);

 //fonction locale
#define sym_type(identifier) IDENTIFIER /* with no symbol table, fake it */
static void comment(void);
void lecture_ecriture_doxy(void);
static void comment_line(void);
static int check_type(void);

void reecrire_yylval_char (){
  yylval_char = strcpy(yylval_char, yytext);
}

//["char""double""float""int""long""short""void"]{L}{A}*	{}
%}
%option nounput
%x COMMDOXY

%%
"/**" | "/*!"           { lecture_ecriture_doxy(); }

"/*"                    { comment(); }
"//"                    { comment_line(); }

"auto"					{ ajout_balise_class("key_word",yytext); return(AUTO); }
"break"					{ ajout_balise_class("key_word",yytext); return(BREAK); }
"case"					{ ajout_balise_class("key_word",yytext); return(CASE); }
"char"					{ ajout_balise_class("type_specifier",yytext); return(CHAR); }
"const"					{ ajout_balise_class("key_word",yytext); return(CONST); }
"continue"				{ ajout_balise_class("key_word",yytext); return(CONTINUE); }
"default"				{ ajout_balise_class("key_word",yytext); return(DEFAULT); }
"do"					{ ajout_balise_class("key_word",yytext); return(DO); }
"double"				{ ajout_balise_class("type_specifier",yytext); return(DOUBLE); }
"else"					{ ajout_balise_class("key_word",yytext); return(ELSE); }
"enum"					{ ajout_balise_class("key_word",yytext); return(ENUM); }
"extern"				{ ajout_balise_class("key_word",yytext); return(EXTERN); }
"float"					{ ajout_balise_class("type_specifier",yytext); return(FLOAT); }

"for"					{ inFor = 1; ajout_balise_class("key_word",yytext); return(FOR); }
"goto"					{ ajout_balise_class("key_word",yytext); return(GOTO); }
"if"					{ ajout_balise_class("key_word",yytext); return(IF); }
"inline"				{ ajout_balise_class("key_word",yytext); return(INLINE); }
"int"					{ ajout_balise_class("type_specifier",yytext); return(INT); }

"long"					{ ajout_balise_class("type_specifier",yytext); return(LONG); }
"register"				{ ajout_balise_class("key_word",yytext); return(REGISTER); }
"restrict"				{ ajout_balise_class("key_word",yytext); return(RESTRICT); }
"return"				{ ajout_balise_class("key_word",yytext); return(RETURN); }
"short"					{ ajout_balise_class("type_specifier",yytext); return(SHORT); }
"signed"				{ ajout_balise_class("key_word",yytext); return(SIGNED); }
"sizeof"				{ ajout_balise_class("key_word",yytext); return(SIZEOF); }
"static"				{ ajout_balise_class("key_word",yytext); return(STATIC); }
"struct"				{ ajout_balise_class("key_word",yytext); return(STRUCT); }
"switch"				{ ajout_balise_class("key_word",yytext); return(SWITCH); }
"typedef"				{ ajout_balise_class("key_word",yytext); return(TYPEDEF); }
"union"					{ ajout_balise_class("key_word",yytext); return(UNION); }
"unsigned"				{ ajout_balise_class("key_word",yytext); return(UNSIGNED); }
"void"					{ ajout_balise_class("type_specifier",yytext); return(VOID); }
"volatile"				{ ajout_balise_class("key_word",yytext); return(VOLATILE); }
"while"					{ ajout_balise_class("key_word",yytext); return(WHILE); }
"_Alignas"                              { ajout_balise_class("key_word",yytext); return ALIGNAS; }
"_Alignof"                              { ajout_balise_class("key_word",yytext); return ALIGNOF; }
"_Atomic"                               { ajout_balise_class("key_word",yytext); return ATOMIC; }
"_Bool"                                 { ajout_balise_class("type_specifier",yytext); return BOOL; }
"_Complex"                              { ajout_balise_class("key_word",yytext); return COMPLEX; }
"_Generic"                              { ajout_balise_class("key_word",yytext); return GENERIC; }
"_Imaginary"                            { ajout_balise_class("key_word",yytext); return IMAGINARY; }
"_Noreturn"                             { ajout_balise_class("key_word",yytext); return NORETURN; }
"_Static_assert"                        { ajout_balise_class("key_word",yytext); return STATIC_ASSERT; }
"_Thread_local"                         { ajout_balise_class("key_word",yytext); return THREAD_LOCAL; }
"__func__"                              { ajout_balise_class("key_word",yytext); return FUNC_NAME; }

{L}{A}*					{/*ajout_balise_class("variable",yytext);*/
  reecrire_yylval_char (); return check_type(); }

{HP}{H}+{IS}?				{ ajout_balise_class("number",yytext); return I_CONSTANT; }
{NZ}{D}*{IS}?				{ ajout_balise_class("number",yytext);  return I_CONSTANT; }
"0"{O}*{IS}?				{ ajout_balise_class("number",yytext); return I_CONSTANT; }
{CP}?"'"([^\'\\\n]|{ES})+"'"		{ fprintf(flot_html, yytext); return I_CONSTANT; }

{D}+{E}{FS}?				{ return F_CONSTANT; }
{D}*"."{D}+{E}?{FS}?			{ return F_CONSTANT; }
{D}+"."{E}?{FS}?			{ return F_CONSTANT; }
{HP}{H}+{P}{FS}?			{ return F_CONSTANT; }
{HP}{H}*"."{H}+{P}{FS}?			{ return F_CONSTANT; }
{HP}{H}+"."{P}{FS}?			{ return F_CONSTANT; }

({SP}?\"([^\"\\\n]|{ES})*\"{WS}*)+	{ ajout_balise_class("string_literal",yytext); return STRING_LITERAL; }

"..."					{ fprintf(flot_html, "..."); return ELLIPSIS; }
">>="					{ fprintf(flot_html, ">>="); return RIGHT_ASSIGN; }
"<<="					{ fprintf(flot_html, "<<="); return LEFT_ASSIGN; }
"+="					{ fprintf(flot_html, "+="); return ADD_ASSIGN; }
"-="					{ fprintf(flot_html, "-="); return SUB_ASSIGN; }
"*="					{ fprintf(flot_html, "*="); return MUL_ASSIGN; }
"/="					{ fprintf(flot_html, "/="); return DIV_ASSIGN; }
"%="					{ fprintf(flot_html, "%%="); return MOD_ASSIGN; }
"&="					{ fprintf(flot_html, "&="); return AND_ASSIGN; }
"^="					{ fprintf(flot_html, "^="); return XOR_ASSIGN; }
"|="					{ fprintf(flot_html, "|="); return OR_ASSIGN; }
">>"					{ fprintf(flot_html, ">>"); return RIGHT_OP; }
"<<"					{ fprintf(flot_html, "<<"); return LEFT_OP; }
"++"					{ fprintf(flot_html, "++"); return INC_OP; }
"--"					{ fprintf(flot_html, "--"); return DEC_OP; }
"->"					{ fprintf(flot_html, "->"); return PTR_OP; }
"&&"					{ fprintf(flot_html, "&&"); return AND_OP; }
"||"					{ fprintf(flot_html, "||"); return OR_OP; }
"<="					{ fprintf(flot_html, "<="); return LE_OP; }
">="					{ fprintf(flot_html, ">="); return GE_OP; }
"=="					{ fprintf(flot_html, "=="); return EQ_OP; }
"!="					{ fprintf(flot_html, "!="); return NE_OP; }
";"					{ fprintf(flot_html, ";");
  if(inFor){
    tab();
  }else{
    newline();
    if(indentation == 0){newline();}
    int i = 0;  for(;i < indentation; i++){ tab();tab();tab();tab(); }}
  return ';'; }
("{"|"<%")				{ if(inFor){inFor = 0;}fprintf(flot_html, "{<span class=crochet>");
  newline();  indentation++;
  int i = 0;  for(;i < indentation; i++){ tab();tab();tab();tab(); }
  return '{'; }
("}"|"%>")				{ fprintf(flot_html, "</span>}"); newline(); indentation--;
  if(indentation < 0){ yyerror("probleme d'indentation.\n");}
  int i = 0;  for(;i < indentation; i++){ tab();tab();tab();tab(); }
  if(indentation == 0){newline();}
  return '}'; }
","					{ fprintf(flot_html, ","); return ','; }
":"					{ fprintf(flot_html, ":"); return ':'; }
"="					{ fprintf(flot_html, "="); return '='; }
"("					{ fprintf(flot_html, "("); return '('; }
")"					{ fprintf(flot_html, ")"); return ')'; }
("["|"<:")				{ fprintf(flot_html, "["); return '['; }
("]"|":>")				{ fprintf(flot_html, "]"); return ']'; }
"."					{ fprintf(flot_html, "."); return '.'; }
"&"					{ fprintf(flot_html, "&"); return '&'; }
"!"					{ fprintf(flot_html, "!"); return '!'; }
"~"					{ fprintf(flot_html, "~"); return '~'; }
"-"					{ fprintf(flot_html, "-"); return '-'; }
"+"					{ fprintf(flot_html, "+"); return '+'; }
"*"					{ fprintf(flot_html, "*"); return '*'; }
"/"					{ fprintf(flot_html, "/"); return '/'; }
"%"					{ fprintf(flot_html, "%%"); return '%'; }
"<"					{ fprintf(flot_html, "<"); return '<'; }
">"					{ fprintf(flot_html, ">"); return '>'; }
"^"					{ fprintf(flot_html, "^"); return '^'; }
"|"					{ fprintf(flot_html, "|"); return '|'; }
"?"					{ fprintf(flot_html, "?"); return '?'; }

{WS}					{ /* whitespace separates tokens */ }
.					{ /* discard bad characters */ }

%%

int yywrap(void)        /* called at end of input */
{
    return 1;           /* terminate now */
}

static void comment_line(void){
  fprintf(flot_html,"\n<span class=\"comment_line\">//");
  int c;
  while ((c = input()) != 0){
    if(c == '\n'){
      fprintf(flot_html,"<br></span>\n");
      int i = 0;
      for(;i < indentation; i++)
	{ tab();tab();tab();tab(); }
      return;
    }
    fprintf(flot_html, "%c",c);
  }
  yyerror("unterminated comment");
}

static void comment(void)
{
    int c;

    while ((c = input()) != 0){
       if (c == '*')
       {
          while ((c = input()) == '*')
             ;
          if (c == '/')
             return;

          if (c == 0)
             break;
       }
    }
    yyerror("unterminated comment");
}

void lecture_ecriture_doxy(void)
{
    int c;
    flot_html2 = fopen("documentation.html","w+");
    lect="";
    
    while ((c = input()) != 0){
       if(c == '*'){
          c=input();
          if(c == '/')
             return;
          else if(c == '\\'){
             while((c=input()) != ' '){
                fprintf(flot_html2, "%c", c);
                sprintf(lect,"%s%c",lect,c);
                lect=strcat(lect, c);
             }
             if(strcmp(lect, "brief")==0){
                printf("on est dans brief\n");
             }
             else if(strcmp(lect, "label")==0){
                printf("on est dans label\n");
             }
             else if(strcmp(lect, "param")==0){
                printf("on est dans param\n");
             }
             else if(strcmp(lect, "ref")==0){
                printf("on est dans ref\n");
             }
             else if(strcmp(lect, "return")==0){
                printf("on est dans return\n");
             }
          }
       }
       else
          fprintf(flot_html2, "%c", c);
    }
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
