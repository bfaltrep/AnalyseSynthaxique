#ifndef TRAITEMENT_H
#define TRAITEMENT_H

#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "pile/stack.h"
#include "list/list.h"

//-- global var
FILE *flot_html;
FILE *flot_css;
FILE *flot_js;
FILE * flot_html2;

char * buf;
char *lect;


//globales sont initialisées à 0 donc ok !
int bool_cond;
int indentation;

extern void yyerror(const char *);
extern char * yylval_char;
extern char * yylval_string_numb;
extern stack variables;
extern list variables_name;
extern int lock;

int create_files();
void finish();

//fonctions spécifiques à l'ajout dans les fichiers
void ajout_regles_css( char * selecteurs, char * regles);
void ajout_enTete_html (char * language, char * title);

void ajout_balise_class(char * type, char * contenu);
void ajout_balise_variable(char * surnom, char * nom);
//void ajout_balise_id(char * type, char * contenu);

//fonctions de traitement de cas 
void new_line();
void tab();
void p_virgule();
void accolade_ouvrant();
void accolade_fermant();
void ajout_div();
void div_fermante();
void condition_saut_ligne();
void string_literal();

//variables
void nommer_variable(char * variable);
char * retrouver_variable(char * nom);
void fin_def_dec_fonction();

#endif 
