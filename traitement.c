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
     *c = "</title><script type=\"text/javascript\" src=\"tdm.js\" charset=\"iso-8859-1\"></script><script type=\"text/javascript\"><!--\n function init(){\n tdm('tdm');\n }\n --> </script> </head>";

   fprintf(flot_html_latex,"%s%s%s%s%s", a, language, b, title, c);
}

void ajout_balise_class(int type, char * contenu){
   /* char * tmp = type_to_string(type); */
   
   /* char * res = malloc(sizeof(char * ) * (strlen(contenu)+strlen(tmp)+1+22)); */
   /* res = strcpy(res,"<span class=\""); */
   /* res = strcat(res,tmp); */
   /* res = strcat(res, "\">"); */
   /* res = strcat(res, contenu); */
   /* res = strcat(res, "</span>"); */
   /* fprintf(flot_html_latex,"%s",res); */
   /* free(res); */

   char * a = "<span class=\"",
     *b = "\">",
     *c = "</span>";
   fprintf(flot_html_latex, "%s%s%s%s%s", a, type_to_string(type), b, contenu, c);
}

int create_menu()
{
  char *c = "<li><a href=\"",//latex.html
    *d = "\">",
    *e = "</a></li>";

  fprintf(flot_html_latex,"<ul id=\"menu\">");
  fprintf(flot_html_latex,"%s%s%s%s%s",c,"index.html",d,"Index",e);
  fprintf(flot_html_latex,"%s%s%s%s%s",c,"code_c.html",d,"Partie C",e);
  fprintf(flot_html_latex,"%s%s%s%s%s",c,"documentation.html",d,"Partie Documentation",e);
  fprintf(flot_html_latex,"%s%s%s%s%s",c,"latex.html",d,"Partie LateX",e);
  fprintf(flot_html_latex,"</ul>");
  
  ajout_regles_css( "ul#menu li","display:inline;margin:10px;padding:10px;\n");
  ajout_regles_css( "ul#menu","text-align:center; margin:0;padding:0; list-style:none;\n");
  return 0;
}


int create_files(char* name_page, char* name_html){
  //créer les deux fichiers
  flot_html_latex = fopen(name_html,"w+"); //
  flot_css = fopen("style.css","w+"); //
  flot_js = fopen("script.js","w+");

  //html
  buf = "<!DOCTYPE html><html>";
  fprintf(flot_html_latex,"%s",buf);
  ajout_enTete_html ("fr", name_page); //
   
  buf = "<body onload=\"init()\">";
  fprintf(flot_html_latex,"%s",buf);
   
  //traitement

  //css
  ajout_regles_css( "body","counter-reset: h1 h2 h3;\n");
  ajout_regles_css( "h1","color : #8291CF;\n  counter-reset: h2;");
  ajout_regles_css( "h1.unnumbered, h2.unnumbered", "counter-reset: none;\n" );
  ajout_regles_css( "h1.unnumbered:before, h2.unnumbered:before, h3.unnumbered:before", "content: none; counter-increment: none;\n");
  ajout_regles_css( "h2","color : #8591CF;\n  counter-reset: h3;");
  ajout_regles_css( "h3","color : #85981A;\n;");
  ajout_regles_css( ".type_specifier","color : #AAAAAA;\n");
  ajout_regles_css( "td","border: 1px solid black;\n");
  ajout_regles_css( ".title","font-size: 40px;\n");
  ajout_regles_css( ".label_equation","margin-left: 5em;\n");
  ajout_regles_css( ".tiny","font-size: 10px;\n");
  ajout_regles_css( "h1:before","content: counter(h1) \" \"; counter-increment: h1;\n");
  ajout_regles_css( "h2:before",
		    "content: counter(h1) \".\" counter(h2) \"  \"; counter-increment: h2;\n");
  ajout_regles_css( "h3:before",
		    "content: counter(h1) \".\" counter(h2) \".\" counter(h3) \"  \"; counter-increment: h3;\n");
  ajout_regles_css(".tdm-niveau-1","font-weight:bold;  \n");
  ajout_regles_css(".tdm-niveau-2","margin-left:1em; \n");
  ajout_regles_css(".tdm-niveau-3","margin-left:2em; \n");
  ajout_regles_css(".tdm-niveau-4","margin-left:3em;\n");
  ajout_regles_css(".tdm-niveau-5","margin-left:4em; \n");
  ajout_regles_css(".tdm-niveau-6","margin-left:5em;\n");
  //ajouter regle pour nomfonction+nomvariable avec une pile.
  //ajout_regles_css( "class=\"type_specifier\" ","color : #AAAAAA;\n");
  return 0;
}

void finish(){
  char * buf = "<script src=\"//code.jquery.com/jquery-1.11.2.min.js\"></script>\n<script type=\"text/javascript\" src=\"script.js\"></script>\n";
  char *buf2 = "</body></html>";
  fprintf(flot_html_latex,"%s<t class=\"tiny\"><center>Cette page HTML a été générée à partir d'un fichier LateX</center></t>%s",buf,buf2);
  fclose(flot_js);
  fclose(flot_html_latex); 
  fclose(flot_css); 
}
