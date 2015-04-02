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
   //+5 pour '{}' et retour a la ligne. +1 : '\0'
   char * res = malloc(sizeof(char * ) * (strlen(selecteurs)+strlen(regles)+5+1));
   res = strcpy(res,selecteurs);
   res = strcat(res, "{\n");
   res = strcat(res,regles);
   res = strcat(res, "}\n\n");
   fprintf(flot_css,"%s",res);
   free(res);
}

void ajout_enTete_html (char * language, char * title){
   //2 : langage. 1 : \0. 37, 59, 15 : code preforme
   char * res = malloc(sizeof(char * ) * (strlen(title)+2+1+111));
   res = strcpy(res,"<head><meta charset=\"utf-8\" lang=\"");
   res = strcat(res, language);
   res = strcat(res, "\" /><link  rel=\"stylesheet\" href=\"style.css\" /><title>");
   res = strcat(res, title);
   res = strcat(res, "</title></head>");
   fprintf(flot_html,"%s",res);
   free(res);
}

void ajout_balise_class(int type, char * contenu){
   char * tmp = type_to_string(type);
   
   char * res = malloc(sizeof(char * ) * (strlen(contenu)+strlen(tmp)+1+22));
   res = strcpy(res,"<span class=\"");
   res = strcat(res,tmp);
   res = strcat(res, "\">");
   res = strcat(res, contenu);
   res = strcat(res, "</span>");
   fprintf(flot_html,"%s",res);
   free(res);
}


int create_files(){
   //créer les deux fichiers
   flot_html = fopen("index.html","w+");
   flot_css = fopen("style.css","w+");

   //html


   buf = "<!DOCTYPE html><html>";
   fprintf(flot_html,"%s",buf);
   ajout_enTete_html ("fr", "documentation");
   
   buf = "<body>";
   fprintf(flot_html,"%s",buf);
   
   //traitement

   //css
   
   ajout_regles_css( "h1","color : #8291CF;\n");
   ajout_regles_css( "h2","color : #8591CF;\n");
   ajout_regles_css( ".type_specifier","color : #AAAAAA;\n");
   //ajouter regle pour nomfonction+nomvariable avec une pile.
   //ajout_regles_css( "class=\"type_specifier\" ","color : #AAAAAA;\n");

   
   buf = "</body></html>";
   fprintf(flot_html,"%s",buf);
   ajout_regles_css( "h1","color : #8291CF;\n");
   return 0;
}

void finish(){
   fclose(flot_html); 
   fclose(flot_css); 
}
