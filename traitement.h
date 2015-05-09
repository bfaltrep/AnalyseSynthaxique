#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//-- locals var
FILE *flot_html_latex;
FILE *flot_css;
FILE *flot_js;
char * buf;

enum type{type_specifier,identifier};

char * type_to_string(int type);

void ajout_regles_css( char * selecteurs, char * regles);

void ajout_enTete_html (char * language, char * title);

void ajout_balise_class(int type, char * contenu);

void ajout_balise_id(int type, char * contenu);

int create_files();

int create_menu();

void finish();
