%{
  //pour asprintf
#define _GNU_SOURCE 
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "traitement.h"
#include "pile/stack.h"
#include "list/list.h"
  
int yylex();

//-- locals functions
void yyerror(const char *s);

//-- var globales
char * yylval_char;
 
stack variables;
list variables_name;

%}

%output "y.tab.c"
                        
%token	IDENTIFIER I_CONSTANT F_CONSTANT STRING_LITERAL FUNC_NAME SIZEOF
%token	PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token	AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token	SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token	XOR_ASSIGN OR_ASSIGN
%token	TYPEDEF_NAME ENUMERATION_CONSTANT

%token	TYPEDEF EXTERN STATIC AUTO REGISTER INLINE
%token	CONST RESTRICT VOLATILE
%token	BOOL CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE VOID
%token	COMPLEX IMAGINARY 
%token	STRUCT UNION ENUM ELLIPSIS

%token	CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN

%token	ALIGNAS ALIGNOF ATOMIC GENERIC NORETURN STATIC_ASSERT THREAD_LOCAL

%start translation_unit

%%

p_ouvrante
         : '(' {fprintf(flot_html, "(");}
p_fermante
         : ')' {fprintf(flot_html, ")");}
parentheses
         : '(' ')'  {fprintf(flot_html, "()");}
a_ouvrant
         : '{' {accolade_ouvrant();}
a_fermant
         : '}' {accolade_fermant();}
c_ouvrant
         : '[' {fprintf(flot_html, "[");}
c_fermant
         : ']' {fprintf(flot_html, "]");}
p_fermant_a_ouvrant
         : ')' '{' {fprintf(flot_html, ")"); accolade_ouvrant();}
etoile
         : '*' {fprintf(flot_html, "*");}
etoile_pointeur
         : '*' {ajout_balise_class("type_specifier","*");}
deux_point
         : ':' {fprintf(flot_html, ":");}
point_virgule
         : ';' {p_virgule();}
virgule
         : ','  {fprintf(flot_html, ",");}

primary_expression
        : IDENTIFIER  {fprintf(flot_html,yylval_char);}
	| constant
	| string
	| p_ouvrante expression p_fermante
	| generic_selection
	;

constant
	: I_CONSTANT		/* includes character_constant */
	| F_CONSTANT
	| ENUMERATION_CONSTANT	/* after it has been defined as such */
	;

enumeration_constant		/* before it has been defined as such */
	: IDENTIFIER
	;

string
        : STRING_LITERAL
	| FUNC_NAME
	;

generic_selection
: GENERIC p_ouvrante assignment_expression virgule generic_assoc_list p_fermante
	;

generic_assoc_list
	: generic_association
	| generic_assoc_list virgule generic_association
	;

generic_association
	: type_name deux_point assignment_expression
	| DEFAULT deux_point assignment_expression
	;

postfix_expression
: primary_expression                                        
        | postfix_expression c_ouvrant expression c_fermant
        | postfix_expression parentheses                         
	| postfix_expression p_ouvrante argument_expression_list p_fermante
	| postfix_expression '.' {fprintf(flot_html, ".");} IDENTIFIER                 
	| postfix_expression PTR_OP IDENTIFIER                   
        | postfix_expression INC_OP                          
        | postfix_expression DEC_OP                           
	| p_ouvrante type_name p_fermant_a_ouvrant initializer_list a_fermant      
        | p_ouvrante type_name p_fermant_a_ouvrant initializer_list ',' '}'  {fprintf(flot_html, ","); accolade_fermant();}         
	;

argument_expression_list
	: assignment_expression
	| argument_expression_list virgule assignment_expression
	;

unary_expression
	: postfix_expression
	| INC_OP unary_expression
	| DEC_OP unary_expression
	| unary_operator cast_expression
	| SIZEOF unary_expression
	| SIZEOF p_ouvrante type_name p_fermante
	| ALIGNOF p_ouvrante type_name p_fermante
	;

unary_operator
        : '&'  {fprintf(flot_html, "&");}
	| '*'  {fprintf(flot_html, "*");}
	| '+'  {fprintf(flot_html, "+");}
	| '-'  {fprintf(flot_html, "-");}
	| '~'  {fprintf(flot_html, "~");}
	| '!'  {fprintf(flot_html, "!");}
	;

cast_expression
	: unary_expression
	| p_ouvrante type_name p_fermante cast_expression
	;

multiplicative_expression
	: cast_expression
	| multiplicative_expression etoile cast_expression
	| multiplicative_expression '/' {fprintf(flot_html, "/");} cast_expression
	| multiplicative_expression '%' {fprintf(flot_html, "%%");} cast_expression
	;

additive_expression
	: multiplicative_expression
	| additive_expression '+' {fprintf(flot_html, "+");} multiplicative_expression 
	| additive_expression '-' {fprintf(flot_html, "-");} multiplicative_expression
	;

shift_expression
	: additive_expression
	| shift_expression LEFT_OP additive_expression
	| shift_expression RIGHT_OP additive_expression
	;

relational_expression
	: shift_expression
	| relational_expression '<' {fprintf(flot_html, "<");} shift_expression
	| relational_expression '>' {fprintf(flot_html, ">");} shift_expression
	| relational_expression LE_OP shift_expression
	| relational_expression GE_OP shift_expression
	;

equality_expression
	: relational_expression
	| equality_expression EQ_OP relational_expression
	| equality_expression NE_OP relational_expression
	;

and_expression
	: equality_expression
	| and_expression '&' {fprintf(flot_html, "&");} equality_expression
	;

exclusive_or_expression
	: and_expression
	| exclusive_or_expression '^' {fprintf(flot_html, "^");} and_expression
	;

inclusive_or_expression
	: exclusive_or_expression
	| inclusive_or_expression '|' {fprintf(flot_html, "|");} exclusive_or_expression
	;

logical_and_expression
	: inclusive_or_expression
	| logical_and_expression AND_OP inclusive_or_expression
	;

logical_or_expression
	: logical_and_expression
	| logical_or_expression OR_OP logical_and_expression
	;

conditional_expression
	: logical_or_expression
	| logical_or_expression '?' {fprintf(flot_html, "?");} expression deux_point conditional_expression
	;

assignment_expression
	: conditional_expression
	| unary_expression assignment_operator assignment_expression
	;

assignment_operator
	: '='  {fprintf(flot_html, "=");}
	| MUL_ASSIGN
	| DIV_ASSIGN
	| MOD_ASSIGN
	| ADD_ASSIGN
	| SUB_ASSIGN
	| LEFT_ASSIGN
	| RIGHT_ASSIGN
	| AND_ASSIGN
	| XOR_ASSIGN
	| OR_ASSIGN
	;

expression
	: assignment_expression
	| expression virgule assignment_expression
	;

constant_expression
	: conditional_expression	/* with constraints */
	;

declaration
        : declaration_specifiers ';'  {p_virgule();}
| declaration_specifiers init_declarator_list ';'  {p_virgule();}
	| static_assert_declaration 
	;

declaration_specifiers
        : storage_class_specifier declaration_specifiers 
	| storage_class_specifier 
        | type_specifier declaration_specifiers
	| type_specifier                               {

	  /*fprintf(flot_html,"--%s--",yylval_char);*/
	  /*
	                                               char * tmp;
						       tmp = nommerVariable(yylval_char);
	                                               char * tmp2;
						       asprintf(&tmp2,"var declaration %s",tmp);
						       ajout_balise_class(tmp2,yylval_char);
						       stack_push(variables,tmp);*/
						       /*free(tmp2);free(tmp);*/} 
	| type_qualifier declaration_specifiers 
	| type_qualifier 
	| function_specifier declaration_specifiers 
	| function_specifier 
	| alignment_specifier declaration_specifiers 
	| alignment_specifier
	;

init_declarator_list
	: init_declarator
	| init_declarator_list virgule init_declarator
	;

init_declarator
	: declarator '=' {fprintf(flot_html, "=");} initializer
	| declarator
	;

storage_class_specifier
	: TYPEDEF	/* identifiers must be flagged as TYPEDEF_NAME */
	| EXTERN
	| STATIC
	| THREAD_LOCAL
	| AUTO
	| REGISTER
	;

type_specifier
	: VOID
	| CHAR          
	| SHORT        
	| INT           
	| LONG
	| FLOAT
	| DOUBLE
	| SIGNED
	| UNSIGNED
	| BOOL
	| COMPLEX
	| IMAGINARY	  	/* non-mandated extension */
	| atomic_type_specifier
	| struct_or_union_specifier
	| enum_specifier
	| TYPEDEF_NAME            
	  /* after it has been defined as such */
	;

struct_or_union_specifier
	: struct_or_union a_ouvrant struct_declaration_list a_fermant
	| struct_or_union IDENTIFIER a_ouvrant struct_declaration_list a_fermant
	| struct_or_union IDENTIFIER
	;

struct_or_union
	: STRUCT
	| UNION
	;

struct_declaration_list
	: struct_declaration
	| struct_declaration_list struct_declaration
	;

struct_declaration
	: specifier_qualifier_list ';' { p_virgule();}	/* for anonymous struct/union */
	| specifier_qualifier_list struct_declarator_list ';' { p_virgule();}   
	| static_assert_declaration
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list
	| type_specifier
	| type_qualifier specifier_qualifier_list
	| type_qualifier
	;

struct_declarator_list
	: struct_declarator
	| struct_declarator_list ',' {fprintf(flot_html, ",");} struct_declarator
	;

struct_declarator
	: deux_point constant_expression
	| declarator deux_point constant_expression
	| declarator
	;

enum_specifier
	: ENUM a_ouvrant enumerator_list a_fermant
        | ENUM a_ouvrant enumerator_list ',' '}' {fprintf(flot_html, ","); accolade_fermant(); }
        | ENUM IDENTIFIER a_ouvrant enumerator_list a_fermant
        | ENUM IDENTIFIER a_ouvrant enumerator_list ',' '}' {fprintf(flot_html, ","); accolade_fermant();}
	| ENUM IDENTIFIER
	;

enumerator_list
	: enumerator
	| enumerator_list virgule  enumerator
	;

enumerator	/* identifiers must be flagged as ENUMERATION_CONSTANT */
	: enumeration_constant '=' {fprintf(flot_html, "=");} constant_expression
	| enumeration_constant
	;

atomic_type_specifier
	: ATOMIC p_ouvrante type_name p_fermante
	;

type_qualifier
	: CONST
	| RESTRICT
	| VOLATILE
	| ATOMIC
	;

function_specifier
	: INLINE
	| NORETURN
	;

alignment_specifier
	: ALIGNAS p_ouvrante type_name p_fermante
	| ALIGNAS p_ouvrante constant_expression p_fermante
	;

declarator
        : pointer direct_declarator 
	| direct_declarator
	;

direct_declarator
	: IDENTIFIER {ajout_balise_class("var",yylval_char);}
	| p_ouvrante declarator p_fermante
	| direct_declarator '[' ']' {fprintf(flot_html, "[]");}
	| direct_declarator c_ouvrant '*' ']' {fprintf(flot_html, "*]");}
	| direct_declarator c_ouvrant STATIC type_qualifier_list assignment_expression c_fermant
	| direct_declarator c_ouvrant STATIC assignment_expression c_fermant
	| direct_declarator c_ouvrant type_qualifier_list '*' ']' {fprintf(flot_html, "*]");}
	| direct_declarator c_ouvrant type_qualifier_list STATIC assignment_expression c_fermant
	| direct_declarator c_ouvrant type_qualifier_list assignment_expression c_fermant
	| direct_declarator c_ouvrant type_qualifier_list c_fermant
	| direct_declarator c_ouvrant assignment_expression c_fermant
	| direct_declarator p_ouvrante parameter_type_list p_fermante
	| direct_declarator parentheses 
	| direct_declarator p_ouvrante identifier_list p_fermante
	;

pointer
	: etoile_pointeur type_qualifier_list pointer 
	| etoile_pointeur type_qualifier_list 
	| etoile_pointeur pointer 
	| etoile_pointeur
	;

type_qualifier_list
	: type_qualifier
	| type_qualifier_list type_qualifier
	;


parameter_type_list
	: parameter_list virgule ELLIPSIS
	| parameter_list
	;

parameter_list
	: parameter_declaration
	| parameter_list virgule parameter_declaration
	;

parameter_declaration
	: declaration_specifiers declarator
	| declaration_specifiers abstract_declarator
	| declaration_specifiers
	;

identifier_list
	: IDENTIFIER  
	| identifier_list virgule IDENTIFIER
	;

type_name
	: specifier_qualifier_list abstract_declarator
	| specifier_qualifier_list
	;

abstract_declarator
	: pointer direct_abstract_declarator
	| pointer
	| direct_abstract_declarator
	;

direct_abstract_declarator
	: p_ouvrante abstract_declarator p_fermante
	| '[' ']' {fprintf(flot_html, "[]");}
	|  c_ouvrant '*' ']' {fprintf(flot_html, "*]");}
	| c_ouvrant STATIC type_qualifier_list assignment_expression c_fermant
	| c_ouvrant STATIC assignment_expression c_fermant
	| c_ouvrant type_qualifier_list STATIC assignment_expression c_fermant
	| c_ouvrant type_qualifier_list assignment_expression c_fermant
	| c_ouvrant type_qualifier_list c_fermant
	| c_ouvrant assignment_expression c_fermant
	| direct_abstract_declarator '[' ']' {fprintf(flot_html, "[]");}
	| direct_abstract_declarator c_ouvrant '*' ']' {fprintf(flot_html, "*]");}
	| direct_abstract_declarator c_ouvrant STATIC type_qualifier_list assignment_expression c_fermant
	| direct_abstract_declarator c_ouvrant STATIC assignment_expression c_fermant
	| direct_abstract_declarator c_ouvrant type_qualifier_list assignment_expression c_fermant
	| direct_abstract_declarator c_ouvrant type_qualifier_list STATIC assignment_expression c_fermant
	| direct_abstract_declarator c_ouvrant type_qualifier_list c_fermant
	| direct_abstract_declarator c_ouvrant assignment_expression c_fermant
	| parentheses
	| p_ouvrante parameter_type_list p_fermante
	| direct_abstract_declarator parentheses
	| direct_abstract_declarator p_ouvrante parameter_type_list p_fermante
	;

initializer
	: a_ouvrant initializer_list a_fermant
        | a_ouvrant initializer_list ',' '}' {fprintf(flot_html, ","); accolade_fermant();}
	| assignment_expression
	;

initializer_list
	: designation initializer
	| initializer
	| initializer_list virgule designation initializer
	| initializer_list virgule initializer
	;

designation
	: designator_list '=' {fprintf(flot_html, "=");}
	;

designator_list
	: designator
	| designator_list designator
	;

designator
	: c_ouvrant constant_expression ']'  {fprintf(flot_html, "]");}
	| '.' {fprintf(flot_html, ".");} IDENTIFIER
	;

static_assert_declaration
        : STATIC_ASSERT p_ouvrante constant_expression ',' {fprintf(flot_html, ",");} STRING_LITERAL ')' ';' {fprintf(flot_html, ")"); p_virgule();} 
	;

statement
	: labeled_statement
	| compound_statement
	| expression_statement
	| selection_statement
	| iteration_statement
	| jump_statement
	;

labeled_statement
	: IDENTIFIER deux_point statement
	| CASE constant_expression deux_point statement {/*sautdeligne*/}
	| DEFAULT deux_point statement
	;

compound_statement
        : '{' '}' {accolade_ouvrant(); accolade_fermant();}
        | a_ouvrant  block_item_list a_fermant
	;

block_item_list
	: block_item
	| block_item_list block_item
	;

block_item
	: declaration
	| statement
	;

expression_statement
	: point_virgule
	| expression point_virgule
	;

selection_statement
	: IF p_ouvrante expression p_fermante statement ELSE statement
	| IF p_ouvrante expression p_fermante statement
	| SWITCH p_ouvrante expression p_fermante statement
	;

iteration_statement
	: WHILE p_ouvrante expression p_fermante statement
	| DO statement WHILE p_ouvrante expression ')' ';'  {fprintf(flot_html, ")"); p_virgule();}
	| FOR p_ouvrante expression_statement expression_statement p_fermante statement
	| FOR p_ouvrante expression_statement expression_statement expression p_fermante statement
	| FOR p_ouvrante declaration expression_statement p_fermante statement
	| FOR p_ouvrante declaration expression_statement expression p_fermante statement
	;

jump_statement
        : GOTO  {ajout_balise_class("key_word","goto");}  IDENTIFIER point_virgule
	| CONTINUE {ajout_balise_class("key_word","continue");} point_virgule
	| BREAK {ajout_balise_class("key_word","break");} point_virgule
        | RETURN {ajout_balise_class("key_word","return");} point_virgule 
        | RETURN  {ajout_balise_class("key_word","return");} expression point_virgule
	;

translation_unit
	: external_declaration
	| translation_unit external_declaration
	;

external_declaration
	: function_definition
	| declaration
	;

function_definition
	: declaration_specifiers declarator declaration_list compound_statement
	| declaration_specifiers declarator compound_statement
	;

declaration_list
	: declaration
	| declaration_list declaration
	;

%%

void yyerror(const char *s){
  fflush(stdout);
  fprintf(stderr, "*** %s\n", s);
}

char * nommerVariable(char * variable){
  int pos = list_inside(variables_name,variable);
  if(pos == -1){
    return variable;
  }
  int i = 2;
  char * tmp;
  do{
    asprintf(&tmp,"%s%d",variable,i);
    pos = stack_inside(variables,tmp);
    i++;
    }while(pos != -1);
  return tmp;
}

int main (){
  yylval_char = malloc(sizeof(char)*50);
  create_files();
  
  variables = stack_create();
  variables_name = list_create();
  
  yyparse();
  printf("\n\nt\n\n\n");
  finish();
  stack_destroy(variables);
  list_destroy(variables_name);
  free(yylval_char);
  return EXIT_SUCCESS;
}
