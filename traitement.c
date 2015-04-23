#include "traitement.h"

/*c'est pas beau je sais...mais je vois pas comment faire mieux*/
char * type_to_string(int type){
   switch (type){
      case type_specifier:
        return "type_specifier";
      case identifier:
         return "identifier"; 
      default:
         return "";
   }   
}

/*Formate et ajoute un bloc associé a des selecteurs dans le css.*/
void ajout_regles_css( char * selecteurs, char * regles){
   char *a ="{\n",
     *b = "}\n\n";
   fprintf(flot_css,"%s%s%s%s", selecteurs, a, regles, b);
}

void ajout_enTete_html (char * language, char * title){
   //2 : langage. 1 : \0. 37, 59, 15 : code preforme
   char *a ="<head><meta charset=\"utf-8\" lang=\"",
     *b = "\" /><link  rel=\"stylesheet\" href=\"style.css\" /><title>",
     *c = "</title></head>";

   fprintf(flot_html,"%s%s%s%s%s", a, language, b, title, c);
}

void ajout_balise_class(int type, char * contenu){
   /* char * tmp = type_to_string(type); */
   
   /* char * res = malloc(sizeof(char * ) * (strlen(contenu)+strlen(tmp)+1+22)); */
   /* res = strcpy(res,"<span class=\""); */
   /* res = strcat(res,tmp); */
   /* res = strcat(res, "\">"); */
   /* res = strcat(res, contenu); */
   /* res = strcat(res, "</span>"); */
   /* fprintf(flot_html,"%s",res); */
   /* free(res); */

   char * a = "<span class=\"",
     *b = "\">",
     *c = "</span>";
   fprintf(flot_html, "%s%s%s%s%s", a, type_to_string(type), b, contenu, c);
}


int create_files(char* name_page, char* name_html){
  //créer les deux fichiers
  flot_html = fopen(name_html,"w+"); //
  flot_css = fopen("style.css","w+"); //

  //html


  buf = "<!DOCTYPE html><html>";
  fprintf(flot_html,"%s",buf);
  ajout_enTete_html ("fr", name_page); //
   
  buf = "<body>";
  fprintf(flot_html,"%s",buf);
   
  //traitement

  //css
   
  ajout_regles_css( "h1","color : #8291CF;\n");
  ajout_regles_css( "h2","color : #8591CF;\n");
  ajout_regles_css( "h3","color : #85981A;\n");
  ajout_regles_css( ".type_specifier","color : #AAAAAA;\n");
  ajout_regles_css( "td","border: 1px solid black;\n");
  ajout_regles_css( "table","border-collapse: collapse;\n");
  //ajouter regle pour nomfonction+nomvariable avec une pile.
  //ajout_regles_css( "class=\"type_specifier\" ","color : #AAAAAA;\n");
  return 0;
}

void finish(){
  char * buf = "</body></html>";
  fprintf(flot_html,"%s",buf);
  fclose(flot_html); 
  fclose(flot_css); 
}
