# define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//-- locals var
FILE *flot_html;
FILE *flot_css;
FILE *flot_js;
FILE * flot_html2;

char * buf;
char *lect;


int create_files();
void finish();

void ajout_regles_css( char * selecteurs, char * regles);
void ajout_enTete_html (char * language, char * title);

void ajout_balise_class(char * type, char * contenu);
void ajout_balise_id(char * type, char * contenu);
void newline();
void tab();

char * nommerVariable(char * variable);

/*
$(".i").hover(function() {
	$(".i").css("background-color","black");},function() {
	$(".i").css("background-color","initial");
});


*/
