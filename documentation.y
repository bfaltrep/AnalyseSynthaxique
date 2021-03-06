%{

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "traitement.h"
#include "pile/stack.h"
#include "list/list.h"
  
  extern int yylex();
  extern int yylex_destroy () ;
 
  //-- locals functions  
  void yyerror(const char *s);
  
  //-- var globales
  char * yylval_char;
  char * yylval_string_numb;
  char * commandeActuelle;
  stack variables;
  list variables_name;
  int indent_switch;
  
  
%}

%output "y.tab.c"
%token IDENTIFIER I_CONSTANT F_CONSTANT STRING_LITERAL FUNC_NAME SIZEOF
%token PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token XOR_ASSIGN OR_ASSIGN
%token TYPEDEF_NAME ENUMERATION_CONSTANT
%token TYPEDEF EXTERN STATIC AUTO REGISTER INLINE
%token CONST RESTRICT VOLATILE
%token BOOL CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE VOID
%token COMPLEX IMAGINARY
%token STRUCT UNION ENUM ELLIPSIS
%token CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN
%token ALIGNAS ALIGNOF ATOMIC GENERIC NORETURN STATIC_ASSERT THREAD_LOCAL
%start translation_unit

%%

p_ouvrante
: '(' {fprintf(flot_html_c, "(");}
p_fermante
: ')' {fprintf(flot_html_c, ")");}
parentheses
: '(' ')' {fprintf(flot_html_c, "()");}
a_ouvrant
: '{' {accolade_ouvrante();}
a_fermant
: '}' {accolade_fermante();indent_switch =0;}
c_ouvrant
: '[' {fprintf(flot_html_c, "[");}
c_fermant
: ']' {fprintf(flot_html_c, "]");}
c_ouvrant_declaration
: '[' {ajout_balise_class("type_specifier","[");}
c_fermant_declaration
: ']' {ajout_balise_class("type_specifier","]");}
p_fermant_a_ouvrant
: ')' '{' {fprintf(flot_html_c, ")"); accolade_ouvrante();}
etoile
: '*' {fprintf(flot_html_c, "*");}
etoile_pointeur
: '*' {ajout_balise_class("type_specifier","*");}
deux_point
: ':' {fprintf(flot_html_c, ":");    if(!bool_cond && indent_switch){ new_line(indentation); }}
point_virgule
: ';' {p_virgule();}
virgule
: ',' {fprintf(flot_html_c, ",");}
string_literal
: STRING_LITERAL { string_literal(); }
for_
: FOR { bool_cond = 1; ajout_balise_class("key_word","for"); }
if_
: IF { ajout_balise_class("key_word","if");} p_ouvrante expression p_fermante {condition_sans_accolade();} statement
alignas
: ALIGNAS {ajout_balise_class("key_word","_Alignas");}
sizeof_
: SIZEOF { ajout_balise_class("key_word","sizeof");}
enum_
: ENUM { ajout_balise_class("key_word","enum");}
static_
: STATIC {ajout_balise_class("key_word","static");}




primary_expression
: IDENTIFIER {/*utilisation de variables*/
  char * surnom = retrouver_variable(yylval_char);
  ajout_balise_variable(surnom,yylval_char);
  free(yylval_char);
}
| constant
| string
| p_ouvrante expression p_fermante
| generic_selection
;

constant
: I_CONSTANT { ajout_balise_class("number",yylval_string_numb); free(yylval_string_numb); }
| F_CONSTANT
| ENUMERATION_CONSTANT /* after it has been defined as such */
;

enumeration_constant /* before it has been defined as such */
: IDENTIFIER
;

string
: string_literal
| FUNC_NAME
;

generic_selection
: GENERIC { ajout_balise_class("key_word","_Generic"); } p_ouvrante assignment_expression virgule generic_assoc_list p_fermante
;

generic_assoc_list
: generic_association
| generic_assoc_list virgule generic_association
;

generic_association
: type_name deux_point assignment_expression
| DEFAULT { ajout_balise_class("key_word","default"); } deux_point assignment_expression
;

postfix_expression
: primary_expression
| postfix_expression c_ouvrant expression c_fermant
| postfix_expression parentheses
| postfix_expression p_ouvrante argument_expression_list p_fermante
| postfix_expression '.' { fprintf(flot_html_c, "."); } IDENTIFIER
| postfix_expression PTR_OP { fprintf(flot_html_c, "-&gt;"); } IDENTIFIER
| postfix_expression INC_OP { fprintf(flot_html_c, "++"); }
| postfix_expression DEC_OP { fprintf(flot_html_c, "--"); }
| p_ouvrante type_name p_fermant_a_ouvrant initializer_list a_fermant
| p_ouvrante type_name p_fermant_a_ouvrant initializer_list virgule a_fermant
;

argument_expression_list
: assignment_expression
| argument_expression_list virgule assignment_expression
;

unary_expression
: postfix_expression
| INC_OP { fprintf(flot_html_c, "++"); } unary_expression
| DEC_OP { fprintf(flot_html_c, "--"); } unary_expression
| unary_operator cast_expression
| sizeof_ unary_expression
| sizeof_ p_ouvrante type_name p_fermante
| ALIGNOF { ajout_balise_class("key_word","_Alignof"); } p_ouvrante type_name p_fermante
;

unary_operator
: '&' {fprintf(flot_html_c, "&amp;");}
| '*' {fprintf(flot_html_c, "*");}
| '+' {fprintf(flot_html_c, "+");}
| '-' {fprintf(flot_html_c, "-");}
| '~' {fprintf(flot_html_c, "~");}
| '!' {fprintf(flot_html_c, "!");}
;

cast_expression
: unary_expression
| p_ouvrante type_name p_fermante cast_expression
;

multiplicative_expression
: cast_expression
| multiplicative_expression etoile cast_expression
| multiplicative_expression '/' {fprintf(flot_html_c, "/");} cast_expression
| multiplicative_expression '%' {fprintf(flot_html_c, "%%");} cast_expression
;

additive_expression
: multiplicative_expression
| additive_expression '+' {fprintf(flot_html_c, "+");} multiplicative_expression
| additive_expression '-' {fprintf(flot_html_c, "-");} multiplicative_expression
;

shift_expression
: additive_expression
| shift_expression LEFT_OP {fprintf(flot_html_c, "&lt;&lt;");} additive_expression
| shift_expression RIGHT_OP {fprintf(flot_html_c, "&gt;&gt;");} additive_expression
;

relational_expression
: shift_expression
| relational_expression '<' {fprintf(flot_html_c, "&lt;");} shift_expression
| relational_expression '>' {fprintf(flot_html_c, "&gt;");} shift_expression
| relational_expression LE_OP {fprintf(flot_html_c, "&lt;=");} shift_expression
| relational_expression GE_OP {fprintf(flot_html_c, "&gt;=");} shift_expression
;

equality_expression
: relational_expression
| equality_expression EQ_OP {fprintf(flot_html_c, "==");} relational_expression
| equality_expression NE_OP {fprintf(flot_html_c, "!=");} relational_expression
;

and_expression
: equality_expression
| and_expression '&' {fprintf(flot_html_c, "&amp;");} equality_expression
;

exclusive_or_expression
: and_expression
| exclusive_or_expression '^' {fprintf(flot_html_c, "^");} and_expression
;

inclusive_or_expression
: exclusive_or_expression
| inclusive_or_expression '|' {fprintf(flot_html_c, "|");} exclusive_or_expression
;

logical_and_expression
: inclusive_or_expression
| logical_and_expression AND_OP {fprintf(flot_html_c, "&amp;&amp;");} inclusive_or_expression
;

logical_or_expression
: logical_and_expression
| logical_or_expression OR_OP {fprintf(flot_html_c, "||");} logical_and_expression
;

conditional_expression
: logical_or_expression
| logical_or_expression '?' {fprintf(flot_html_c, "?");} expression deux_point conditional_expression
;

assignment_expression
: conditional_expression
| unary_expression assignment_operator assignment_expression
;

assignment_operator
: '=' {fprintf(flot_html_c, "=");}
| MUL_ASSIGN {fprintf(flot_html_c, "*=");}
| DIV_ASSIGN {fprintf(flot_html_c, "/=");}
| MOD_ASSIGN {fprintf(flot_html_c, "%%=");}
| ADD_ASSIGN {fprintf(flot_html_c, "+=");}
| SUB_ASSIGN {fprintf(flot_html_c, "-=");}
| LEFT_ASSIGN {fprintf(flot_html_c, "&lt;&lt;=");}
| RIGHT_ASSIGN {fprintf(flot_html_c, "&gt;&gt;=");}
| AND_ASSIGN {fprintf(flot_html_c, "&amp;=");}
| XOR_ASSIGN {fprintf(flot_html_c, "^=");}
| OR_ASSIGN {fprintf(flot_html_c, "|=");}
;

expression
: assignment_expression
| expression virgule assignment_expression
;

constant_expression
: conditional_expression /* with constraints */
;

declaration
: declaration_specifiers point_virgule 
| declaration_specifiers init_declarator_list {ajout_balise_id(stack_top(variables));}  point_virgule
| static_assert_declaration
;

declaration_specifiers
: storage_class_specifier declaration_specifiers
| storage_class_specifier
| type_specifier declaration_specifiers
| type_specifier 
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
: declarator '=' {fprintf(flot_html_c, "=");} initializer 
| declarator {/*fin declarator*/} 
;

storage_class_specifier
: TYPEDEF {ajout_balise_class("key_word","typedef");}
| EXTERN {ajout_balise_class("key_word","extern");}
| static_
| THREAD_LOCAL {ajout_balise_class("key_word","_Thread_local");}
| AUTO {ajout_balise_class("key_word","auto");}
| REGISTER {ajout_balise_class("key_word","register");}
;

type_specifier
: VOID {ajout_balise_class("type_specifier","void");}
| CHAR {ajout_balise_class("type_specifier","char");}
| SHORT {ajout_balise_class("type_specifier","short");}
| INT {ajout_balise_class("type_specifier","int");}
| LONG {ajout_balise_class("type_specifier","long");}
| FLOAT {ajout_balise_class("type_specifier","float");}
| DOUBLE {ajout_balise_class("type_specifier","double");}
| SIGNED {ajout_balise_class("type_specifier","signed");}
| UNSIGNED {ajout_balise_class("type_specifier","unsigned");}
| BOOL {ajout_balise_class("type_specifier","_Bool");}
| COMPLEX {ajout_balise_class("type_specifier","complex");}
| IMAGINARY {ajout_balise_class("type_specifier","imaginary");}
| atomic_type_specifier
| struct_or_union_specifier
| enum_specifier
| TYPEDEF_NAME
;

struct_or_union_specifier
: struct_or_union a_ouvrant struct_declaration_list a_fermant
| struct_or_union IDENTIFIER a_ouvrant struct_declaration_list a_fermant
| struct_or_union IDENTIFIER
;

struct_or_union
: STRUCT {ajout_balise_class("key_word","struct");}
| UNION {ajout_balise_class("key_word","union");}
;
struct_declaration_list
: struct_declaration
| struct_declaration_list struct_declaration
;

struct_declaration
: specifier_qualifier_list point_virgule /* for anonymous struct/union */
| specifier_qualifier_list struct_declarator_list point_virgule
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
| struct_declarator_list virgule struct_declarator
;

struct_declarator
: deux_point constant_expression
| declarator deux_point constant_expression
| declarator
;

enum_specifier
: enum_ a_ouvrant enumerator_list a_fermant
| enum_ a_ouvrant enumerator_list virgule a_fermant
| enum_ IDENTIFIER a_ouvrant enumerator_list a_fermant
| enum_ IDENTIFIER a_ouvrant enumerator_list virgule a_fermant
| enum_ IDENTIFIER
;

enumerator_list
: enumerator
| enumerator_list virgule enumerator
;

enumerator /* identifiers must be flagged as ENUMERATION_CONSTANT */
: enumeration_constant '=' {fprintf(flot_html_c, "=");} constant_expression
| enumeration_constant
;

atomic_type_specifier
: ATOMIC p_ouvrante type_name p_fermante
;

type_qualifier
: CONST {ajout_balise_class("key_word","const");}
| RESTRICT {ajout_balise_class("key_word","restrict");}
| VOLATILE {ajout_balise_class("key_word","volatile");}
| ATOMIC {ajout_balise_class("key_word","_Atomic");}
;

function_specifier
: INLINE {ajout_balise_class("key_word","inline");}
| NORETURN {ajout_balise_class("key_word","_Noreturn");}
;

alignment_specifier
: alignas p_ouvrante type_name p_fermante
| alignas p_ouvrante constant_expression p_fermante
;

declarator
: pointer direct_declarator
| direct_declarator
;

direct_declarator
: IDENTIFIER {/*declaration de variables*/
  nommer_variable(yylval_char);
  char * tmp = ((char *)stack_top(variables));
  asprintf(&tmp,"var declaration %s",tmp);
  ajout_balise_class(tmp,yylval_char);
  free(tmp);
  free(yylval_char);
  }
| p_ouvrante declarator p_fermante
| direct_declarator c_ouvrant_declaration c_fermant_declaration
| direct_declarator c_ouvrant_declaration etoile c_fermant_declaration
| direct_declarator c_ouvrant_declaration static_ type_qualifier_list assignment_expression c_fermant_declaration
| direct_declarator c_ouvrant_declaration static_ assignment_expression c_fermant_declaration
| direct_declarator c_ouvrant_declaration type_qualifier_list etoile c_fermant_declaration
| direct_declarator c_ouvrant_declaration type_qualifier_list static_ assignment_expression c_fermant_declaration
| direct_declarator c_ouvrant_declaration type_qualifier_list assignment_expression c_fermant_declaration
| direct_declarator c_ouvrant_declaration type_qualifier_list c_fermant_declaration
| direct_declarator c_ouvrant_declaration assignment_expression c_fermant_declaration
| direct_declarator p_ouvrante {/*push parenthese*/
  char * tmp;
  asprintf(&tmp,"(" );
  stack_push(variables,tmp);
  lock = 1;
 } parameter_type_list p_fermante 
| direct_declarator parentheses {/*push parenthese*/
  char * tmp;
  asprintf(&tmp,"(" );
  stack_push(variables,tmp);
  lock = 1;
 }
| direct_declarator p_ouvrante {/*push parenthese*/
  char * tmp;
  asprintf(&tmp,"(" );
  stack_push(variables,tmp);
  lock = 1;
 } identifier_list p_fermante 
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
: parameter_list virgule ELLIPSIS {fprintf(flot_html_c,"...");}
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
| c_ouvrant_declaration c_fermant_declaration
| c_ouvrant_declaration etoile c_fermant_declaration
| c_ouvrant_declaration static_ type_qualifier_list assignment_expression c_fermant_declaration
| c_ouvrant_declaration static_ assignment_expression c_fermant
| c_ouvrant_declaration type_qualifier_list static_ assignment_expression c_fermant_declaration
| c_ouvrant_declaration type_qualifier_list assignment_expression c_fermant_declaration
| c_ouvrant_declaration type_qualifier_list c_fermant_declaration
| c_ouvrant_declaration assignment_expression c_fermant_declaration
| direct_abstract_declarator c_ouvrant_declaration c_fermant_declaration
| direct_abstract_declarator c_ouvrant_declaration etoile c_fermant_declaration
| direct_abstract_declarator c_ouvrant_declaration static_ type_qualifier_list assignment_expression c_fermant_declaration
| direct_abstract_declarator c_ouvrant_declaration static_ assignment_expression c_fermant_declaration
| direct_abstract_declarator c_ouvrant_declaration type_qualifier_list assignment_expression c_fermant_declaration
| direct_abstract_declarator c_ouvrant_declaration type_qualifier_list static_ assignment_expression c_fermant_declaration
| direct_abstract_declarator c_ouvrant_declaration type_qualifier_list c_fermant_declaration
| direct_abstract_declarator c_ouvrant_declaration assignment_expression c_fermant_declaration
| parentheses
| p_ouvrante parameter_type_list p_fermante
| direct_abstract_declarator parentheses
| direct_abstract_declarator p_ouvrante parameter_type_list p_fermante
;

initializer
: a_ouvrant initializer_list a_fermant
| a_ouvrant initializer_list virgule a_fermant
| assignment_expression
;

initializer_list
: designation initializer
| initializer
| initializer_list virgule initializer
;

designation
: designator_list '=' {fprintf(flot_html_c, "=");}
;

designator_list
: designator
| designator_list designator
;

designator
: c_ouvrant constant_expression c_fermant
| '.' {fprintf(flot_html_c, ".");} IDENTIFIER
;
static_assert_declaration
: STATIC_ASSERT p_ouvrante constant_expression virgule string_literal p_fermante point_virgule
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
| CASE { fseek(flot_html_c,-(strlen("&nbsp")*4),SEEK_CUR); ajout_balise_class("key_word","case"); } constant_expression deux_point statement
| DEFAULT { fseek(flot_html_c,-(strlen("&nbsp")*4),SEEK_CUR);  ajout_balise_class("key_word","default"); } deux_point statement
;

compound_statement
: a_ouvrant a_fermant
| a_ouvrant block_item_list a_fermant
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
: if_ ELSE { ajout_balise_class("key_word","else"); } statement
| if_ 
| SWITCH {ajout_balise_class("key_word","switch"); indent_switch = 1; indentation++; } p_ouvrante expression p_fermante statement
;

iteration_statement
: WHILE { ajout_balise_class("key_word","while");} p_ouvrante expression p_fermante {condition_sans_accolade();} statement
| DO {ajout_balise_class("key_word","do");} statement WHILE {ajout_balise_class("key_word","while");} p_ouvrante expression p_fermante point_virgule
| for_ p_ouvrante expression_statement expression_statement p_fermante {condition_sans_accolade();} statement
| for_ p_ouvrante expression_statement expression_statement expression p_fermante {condition_sans_accolade();} statement
| for_ p_ouvrante declaration expression_statement p_fermante {condition_sans_accolade();} statement
| for_ p_ouvrante declaration expression_statement expression p_fermante {condition_sans_accolade();} statement
;

jump_statement
: GOTO {ajout_balise_class("key_word","goto");} IDENTIFIER point_virgule
| CONTINUE {ajout_balise_class("key_word","continue");} point_virgule
| BREAK {ajout_balise_class("key_word","break");} point_virgule
| RETURN {ajout_balise_class("key_word","return");} point_virgule
| RETURN {ajout_balise_class("key_word","return");} expression point_virgule
;

translation_unit
: external_declaration
| translation_unit external_declaration
;
external_declaration
: function_definition { /*retire de la pile les parametres de la fonction*/ fin_def_dec_fonction(); }
| declaration {/*place une balise de declaration pour le lien*/
  fseek(flot_html_c,-(strlen("<br><br>")),SEEK_CUR);
  char * nom_var = stack_inside_after(variables,".");
  ajout_balise_id(nom_var);
  new_line(indentation);
  //retire les parametres de la pile. Seul le nom de la fonction peut être utilisé ensuite ensuite. 'if' pour pas avoir de problemes avec les variables globales.
  if(stack_inside_variable(variables,"(") != NULL){
    fin_def_dec_fonction();
  }
  lock = 0;
 }
;

function_definition
: declaration_specifiers declarator declaration_list compound_statement
| declaration_specifiers declarator {/*definition*/ lock = 0;} compound_statement
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

int main (){
  //initialiser
  commandeActuelle = calloc(7, sizeof(*commandeActuelle)); //taille maximale de la longueur des commandes
  create_files(1,"Documentation","code_c.html");
  variables = stack_create();
  variables_name = list_create();
  
  //parcourir
  yyparse();
  
  printf("\n\nAnalyse de vos fichiers terminée. Veuillez ouvrir index.html avec votre navigateur. \n\n");
  
  //nettoyer avant de fermer.
  finish_files(1);
  stack_destroy(variables);
  list_destroy(variables_name);
  free(commandeActuelle);
  yylex_destroy();
  return EXIT_SUCCESS;
}
