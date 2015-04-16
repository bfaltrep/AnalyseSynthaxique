#include "traitement.h"

/*Formate et ajoute un bloc associé a des selecteurs dans le css.*/
void ajout_regles_css( char * selecteurs, char * regles){
   char *a ="{\n",
     *b = "}\n\n";
   fprintf(flot_css,"%s%s%s%s", selecteurs, a, regles, b);
}

void ajout_enTete_html (char * language, char * title){
   char *a ="<head><meta charset=\"utf-8\" lang=\"",
     *b = "\" /><link  rel=\"stylesheet\" href=\"style.css\" /><title>",
     *c = "</title></head>\n";

   fprintf(flot_html,"%s%s%s%s%s", a, language, b, title, c);
}

void newline(){
  fprintf(flot_html, "<br>");
}

void tab(){
  fprintf(flot_html, "&nbsp");
}

void ajout_balise_class(char * type, char * contenu){


   char * a = "\n<span class=\"",
     *b = "\">",
     *c = "</span>\n";
   fprintf(flot_html, "%s%s%s%s%s", a, type, b, contenu, c);
}


int create_files(){
   //créer les fichiers du site
   flot_html = fopen("index.html","w+");
   flot_css = fopen("style.css","w+");
   flot_js = fopen("script.js","w+");

   //html
   buf = "<!DOCTYPE html><html>";
   fprintf(flot_html,"%s",buf);
   ajout_enTete_html ("fr", "documentation");
   
   buf = "<body>";
   fprintf(flot_html,"%s",buf);
   
   //traitement

   //css
   ajout_regles_css(".number","color : #990000;\n");
   ajout_regles_css(".key_word" ,"color : #FF6600;\n");
   ajout_regles_css(".type_specifier" ,"color : #330099;\n");
   ajout_regles_css(".identifier","color : #CCCC33;\n");
   ajout_regles_css(".string_literal","color : #DAA520;\n");
   ajout_regles_css(".var","color : #66AA33;\n");
   ajout_regles_css(".comment_line","color : #FF00CC;\n");
   
   return 0;
}

void finish(){
  char * buf = "\n<script src=\"//code.jquery.com/jquery-1.11.2.min.js\"></script>\n<script type=\"text/javascript\" src=\"script.js\" ></script>\n</body></html>";
  fprintf(flot_html,"%s",buf);
  fclose(flot_js);
  fclose(flot_html); 
  fclose(flot_css);
}

