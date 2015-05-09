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
FILE * flot_html_c;
FILE * flot_css;
FILE * flot_js;
FILE * flot_html_doc;

char * buf;

//globales sont initialisées à 0 donc ok !
int bool_cond;
int indentation;
int lock;

extern void yyerror(const char *);
extern char * yylval_char;
extern char * yylval_string_numb;
extern stack variables;
extern list variables_name;
int lock;

/**
 * \fn int create_files()
 * \brief
 * \param
 * \param
 * \return
 */
int create_files();
/**
 * \fn void finish_files()
 * \brief
 * \param
 * \param
 * \return
 */
void finish_files();

//fonctions spécifiques à l'ajout dans les fichiers

/**
 * \fn void ajout_regles_css( char * selecteurs, char * regles)
 * \brief
 * \param
 * \param
 * \return
 */
void ajout_regles_css( char * selecteurs, char * regles);
/**
 * \fn void ajout_enTete_html (char * language, char * title)
 * \brief
 * \param
 * \param
 * \return
 */
void ajout_enTete_html (char * language, char * title);

/**
 * \fn void ajout_balise_class(char * type, char * contenu)
 * \brief
 * \param
 * \param
 * \return
 */
void ajout_balise_class(char * type, char * contenu);
/**
 * \fn void ajout_balise_variable(char * surnom, char * nom)
 * \brief
 * \param
 * \param
 * \return
 */
void ajout_balise_variable(char * surnom, char * nom);

//fonctions de traitement de cas

/**
 * \fn void new_line()
 * \brief
 * \param
 * \param
 * \return
 */
void new_line();
/**
 * \fn void tab()
 * \brief
 * \param
 * \param
 * \return
 */
void tab();
/**
 * \fn void p_virgule()
 * \brief
 * \param
 * \param
 * \return
 */
void p_virgule();
/**
 * \fn void accolade_ouvrante()
 * \brief
 * \param
 * \param
 * \return
 */
void accolade_ouvrante();
/**
 * \fn void accolade_fermante()
 * \brief
 * \param
 * \param
 * \return
 */
void accolade_fermante();
/**
 * \fn void ajout_div()
 * \brief
 * \param
 * \param
 * \return
 */
void ajout_div();
/**
 * \fn void div_fermante()
 * \brief
 * \param
 * \param
 * \return
 */
void div_fermante();
/**
 * \fn void condition_saut_ligne()
 * \brief
 * \param
 * \param
 * \return
 */
void condition_saut_ligne();
//on veut que les strings litéraux puissent contenir des balises html qui ne
//seront pas traitées

/**
 * \fn void string_literal()
 * \brief
 * \param
 * \param
 * \return
 */
void string_literal();

//variables

/**
 * \fn void nommer_variable(char * variable)
 * \brief
 * \param
 * \param
 * \return
 */
void nommer_variable(char * variable);
/**
 * \fn char * retrouver_variable(char * nom)
 * \brief
 * \param
 * \param
 * \return
 */
char * retrouver_variable(char * nom);
/**
 * \fn void fin_def_dec_fonction()
 * \brief
 * \param
 * \param
 * \return
 */
void fin_def_dec_fonction();

#endif 
