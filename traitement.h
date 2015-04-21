#ifndef TRAITEMENT_H
#define TRAITEMENT_H


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//-- global var
FILE *flot_html;
FILE *flot_css;
FILE *flot_js;
char * buf;

//globales sont initialisées à 0 donc ok !
int inFor;
int indentation;

extern void yyerror(const char *);

int create_files();
void finish();

//fonctions spécifiques à l'ajout dans les fichiers
void ajout_regles_css( char * selecteurs, char * regles);
void ajout_enTete_html (char * language, char * title);

void ajout_balise_class(char * type, char * contenu);
//void ajout_balise_id(char * type, char * contenu);

//fonctions de traitement de cas 
void newline();
void tab();
void p_virgule();
void accolade_ouvrant();
void accolade_fermant();
void ajout_div();
void div_fermante();
/*

//TEMPORAIRE
//fonction pour mettre en valeur une variable au survol

$(".i").hover(function() {
	$(".i").css("background-color","black");},function() {
	$(".i").css("background-color","initial");
});


// cache/affiche aux ouvertures et fermeture des accolades
$('body').on('click','img',function(){ 
if($(this).attr('src') === "moins.png") {
 $(this).attr('src',"plus.png"); 
} 
else { 
 $(this).attr('src',"moins.png"); 
} 
$(this).next('div').toggle(); 
});

*/

#endif 
