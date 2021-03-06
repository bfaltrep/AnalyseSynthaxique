#ifndef TRAITEMENT_H
#define TRAITEMENT_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "list/list.h"
#include "pile/stack.h"

//-- global var
FILE * flot_css;
FILE * flot_js;
FILE * flot_html_c;
FILE * flot_html_doc;
FILE * flot_html_latex;

//globales sont initialisées à 0 donc ok !
int bool_cond;
int indentation;
//parametre != fonction/variable pr indentation à 0.
int lock;

void yyerror(const char *);
char * yylval_char;
char * yylval_string_numb;
stack variables;
list variables_name;
int indent_switch;

int create_files(int, char *, char *);

void finish_files(int);

//fonctions spécifiques à l'ajout dans les fichiers

void ajout_regles_css( char * selecteurs, char * regles);

void ajout_balise_class(char * type, char * contenu);

void ajout_balise_variable(char * surnom, char * nom);

//fonctions de traitement de cas

void new_line();

void tab();

void p_virgule();

void accolade_ouvrante();

void accolade_fermante();

void ajout_div();

void div_fermante();

void condition_saut_ligne();
//on veut que les strings litéraux puissent contenir des balises html qui ne seront pas traitées

void string_literal();

//variables

void nommer_variable(char * variable);

char * retrouver_variable(char * nom);

void fin_def_dec_fonction();

void ajout_balise_id(char * nom_var);

//fonction présente dans le flex, utilisée dans bison
void condition_sans_accolade();

#endif
