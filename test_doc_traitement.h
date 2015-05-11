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
/* FILE * flot_html_c; */
/* FILE * flot_css; */
/* FILE * flot_js; */
/* FILE * flot_html_doc; */

char * buf;

//globales sont initialisées à 0 donc ok !
int bool_cond;
int indentation;
int lock;

extern void yyerror(const char *);
extern char * yylval_char;
extern char * yylval_string_numb;
/* extern stack variables; */
/* extern list variables_name; */
int lock;

/**
 * \fn int create_files(char *nom)
 * \brief creer les fichiers html, css et javascript permettant la
 * visualisation du code C, et de la documentation
 * \param nom titre de la page html contenant le code C
 * \return 0 si tout s'est bien passe
 */
int create_files(char *nom);

/**
 * \fn void finish_files()
 * \brief ecrit le fin des balises fermantes dans les fichiers html, et ferme
 * tous les flots d'ecriture
 */
void finish_files();

//fonctions spécifiques à l'ajout dans les fichiers

/**
 * \fn void ajout_regles_css( char * selecteurs, char * regles)
 * \brief ecrit dans le fichier css dans le selecteurs, les regles donnees en parametre 
 * \param selecteurs contient les balises qui seront affectees par la ou les
 * regles css
 * \param regles sont les contraintes de design pour le ou les selecteurs
 */
void ajout_regles_css( char * selecteurs, char * regles);

/**
 * \fn void ajout_enTete_html (char * language, char * title)
 * \brief ajoute le debut conventionnel d'un fichier html ainsi que les
 * dependances avec les fichiers css et Js
 * \param language donne en quel langage est ecrit la page html
 * \param title titre de la page html
 */
void ajout_enTete_html (char * language, char * title);

/**
 * \fn void ajout_balise_class(char * type, char * contenu)
 * \brief cree une balise span avec un identificateur de type class
 * \param type nom de la class de la balise span
 * \param contenu contenu de ce qu'il y a dans la balise
 */
void ajout_balise_class(char * type, char * contenu);

/**
 * \fn void ajout_balise_variable(char * surnom, char * nom)
 * \brief creer une balise contenant un lien
 * \param surnom contient le nom de la class et l'adresse du lien
 * \param nom est le texte du lien
 */
void ajout_balise_variable(char * surnom, char * nom);

//fonctions de traitement de cas

/**
 * \fn void new_line(int size)
 * \brief saute une ligne et insere le bon nombre de tabulations en fonction
 * de size
 * \param size est le nombre d'espaces a inserer X4 
 */
void new_line();

/**
 * \fn void tab()
 * \brief cree une tabulation dans le fichier html
 */
void tab();

/**
 * \fn void p_virgule()
 * \brief ajoute un point virgule
 */
void p_virgule();

/**
 * \fn void accolade_ouvrante()
 * \brief cree une nouvelle balise en fonction d'une nouvelle accolade ouvrante
 */
void accolade_ouvrante();

/**
 * \fn void accolade_fermante()
 * \brief ferme la balise correspondant à l'accolade
 */
void accolade_fermante();

/**
 * \fn void ajout_div(char *class)
 * \brief cree une balise div avec l'identifiant class
 * \param class nom de la div
 */
void ajout_div(char *class);

/**
 * \fn void div_fermante()
 * \brief ferme une balise div
 */
void div_fermante();

/* /\** */
/*  * \fn void string_literal() */
/*  * \brief */
/*  *\/ */
/* void string_literal(); */

/* //variables */

/**
 * \fn void nommer_variable(char * variable)
 * \brief donne un nom unique pour chaque variable qui est differente
 * \param variable passee en parametre
 */
void nommer_variable(char * variable);

/**
 * \fn char * retrouver_variable(char * nom)
 * \brief cherche si la variable nom existe deja
 * \param nom de la variable recherchee
 * \return la variable recherchee, noname sinon
 */
char * retrouver_variable(char * nom);

/**
 * \fn void fin_def_dec_fonction()
 * \brief vide toutes les variables qui sont dans la pile
 */
void fin_def_dec_fonction();

#endif 
