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
#include "y.tab.h"
  
  //-- var globales
extern char * yylval_char; 

extern void yyerror(const char *);  /* prints grammar violation message */

extern int sym_type(const char *);  /* returns type from symbol table */

#define sym_type(identifier) IDENTIFIER /* with no symbol table, fake it */

static void comment(void);
static int check_type(void);

void reecrire_yylval_char (){
  yylval_char = strcpy(yylval_char, yytext);
}

 
%}
%option nounput

%%
"/*"                                    { comment(); }
"//".*                                    { /* consume //-comment */ }

"auto"					{ reecrire_yylval_char (); return(AUTO); }
"break"					{ reecrire_yylval_char (); return(BREAK); }
"case"					{ reecrire_yylval_char (); return(CASE); }
"char"					{ reecrire_yylval_char (); return(CHAR); }
"const"					{ reecrire_yylval_char (); return(CONST); }
"continue"				{ reecrire_yylval_char (); return(CONTINUE); }
"default"				{ reecrire_yylval_char (); return(DEFAULT); }
"do"					{ reecrire_yylval_char (); return(DO); }
"double"				{ reecrire_yylval_char (); return(DOUBLE); }
"else"					{ reecrire_yylval_char (); return(ELSE); }
"enum"					{ reecrire_yylval_char (); return(ENUM); }
"extern"				{ reecrire_yylval_char (); return(EXTERN); }
"float"					{ reecrire_yylval_char (); return(FLOAT); }
"for"					{ reecrire_yylval_char (); return(FOR); }
"goto"					{ reecrire_yylval_char (); return(GOTO); }
"if"					{ reecrire_yylval_char (); return(IF); }
"inline"				{ reecrire_yylval_char (); return(INLINE); }
"int"					{ reecrire_yylval_char (); return(INT); }

"long"					{ reecrire_yylval_char (); return(LONG); }
"register"				{ reecrire_yylval_char (); return(REGISTER); }
"restrict"				{ reecrire_yylval_char (); return(RESTRICT); }
"return"				{ reecrire_yylval_char (); return(RETURN); }
"short"					{ reecrire_yylval_char (); return(SHORT); }
"signed"				{ reecrire_yylval_char (); return(SIGNED); }
"sizeof"				{ reecrire_yylval_char (); return(SIZEOF); }
"static"				{ reecrire_yylval_char (); return(STATIC); }
"struct"				{ reecrire_yylval_char (); return(STRUCT); }
"switch"				{ reecrire_yylval_char (); return(SWITCH); }
"typedef"				{ reecrire_yylval_char (); return(TYPEDEF); }
"union"					{ reecrire_yylval_char (); return(UNION); }
"unsigned"				{ reecrire_yylval_char (); return(UNSIGNED); }
"void"					{ reecrire_yylval_char (); return(VOID); }
"volatile"				{ reecrire_yylval_char (); return(VOLATILE); }
"while"					{ reecrire_yylval_char (); return(WHILE); }
"_Alignas"                              { return ALIGNAS; }
"_Alignof"                              { return ALIGNOF; }
"_Atomic"                               { return ATOMIC; }
"_Bool"                                 { reecrire_yylval_char (); return BOOL; }
"_Complex"                              { return COMPLEX; }
"_Generic"                              { return GENERIC; }
"_Imaginary"                            { return IMAGINARY; }
"_Noreturn"                             { return NORETURN; }
"_Static_assert"                        { return STATIC_ASSERT; }
"_Thread_local"                         { return THREAD_LOCAL; }
"__func__"                              { return FUNC_NAME; }

{L}{A}*					{ return check_type(); }

{HP}{H}+{IS}?				{ return I_CONSTANT; }
{NZ}{D}*{IS}?				{ return I_CONSTANT; }
"0"{O}*{IS}?				{ return I_CONSTANT; }
{CP}?"'"([^\'\\\n]|{ES})+"'"		{ return I_CONSTANT; }

{D}+{E}{FS}?				{ return F_CONSTANT; }
{D}*"."{D}+{E}?{FS}?			{ return F_CONSTANT; }
{D}+"."{E}?{FS}?			{ return F_CONSTANT; }
{HP}{H}+{P}{FS}?			{ return F_CONSTANT; }
{HP}{H}*"."{H}+{P}{FS}?			{ return F_CONSTANT; }
{HP}{H}+"."{P}{FS}?			{ return F_CONSTANT; }

({SP}?\"([^\"\\\n]|{ES})*\"{WS}*)+	{ return STRING_LITERAL; }

"..."					{ return ELLIPSIS; }
">>="					{ return RIGHT_ASSIGN; }
"<<="					{ return LEFT_ASSIGN; }
"+="					{ return ADD_ASSIGN; }
"-="					{ return SUB_ASSIGN; }
"*="					{ return MUL_ASSIGN; }
"/="					{ return DIV_ASSIGN; }
"%="					{ return MOD_ASSIGN; }
"&="					{ return AND_ASSIGN; }
"^="					{ return XOR_ASSIGN; }
"|="					{ return OR_ASSIGN; }
">>"					{ return RIGHT_OP; }
"<<"					{ return LEFT_OP; }
"++"					{ return INC_OP; }
"--"					{ return DEC_OP; }
"->"					{ return PTR_OP; }
"&&"					{ return AND_OP; }
"||"					{ return OR_OP; }
"<="					{ return LE_OP; }
">="					{ return GE_OP; }
"=="					{ return EQ_OP; }
"!="					{ return NE_OP; }
";"					{ return ';'; }
("{"|"<%")				{ return '{'; }
("}"|"%>")				{ return '}'; }
","					{ return ','; }
":"					{ return ':'; }
"="					{ return '='; }
"("					{ return '('; }
")"					{ return ')'; }
("["|"<:")				{ return '['; }
("]"|":>")				{ return ']'; }
"."					{ return '.'; }
"&"					{ return '&'; }
"!"					{ return '!'; }
"~"					{ return '~'; }
"-"					{ return '-'; }
"+"					{ return '+'; }
"*"					{ return '*'; }
"/"					{ return '/'; }
"%"					{ return '%'; }
"<"					{ return '<'; }
">"					{ return '>'; }
"^"					{ return '^'; }
"|"					{ return '|'; }
"?"					{ return '?'; }

{WS}					{ /* whitespace separates tokens */ }
.					{ /* discard bad characters */ }

%%

int yywrap(void)        /* called at end of input */
{
    return 1;           /* terminate now */
}

static void comment(void)
{
    int c;

    while ((c = input()) != 0)
        if (c == '*')
        {
            while ((c = input()) == '*')
                ;
            if (c == '/')
                return;

            if (c == 0)
                break;
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
