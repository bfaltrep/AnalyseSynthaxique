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
     *c = "</title></script><script type=\"text/javascript\"><!--\n function init(){\n tdm('tdm');\n }\n --> </script> </head>";

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

void ajout_fonction_js_cite_code(){
  fprintf(flot_js,"function cite_code(code1, code2) {\n var str1=document.getElementById(code1); \n var str2=document.getElementById(code2); }\n");
}

void ajout_fonctions_js_tdm()
{
  fprintf(flot_js,"function tdm(replace){\n var createBackLink = false;\n var sectionNoTemplate = document.createElement('span');\n	sectionNoTemplate.className = 'section-no';\n	var tdmItemNoTemplate = document.createElement('span');\n	tdmItemNoTemplate.className = 'tdm-item-no';\n	replace = document.getElementById(replace);\n	var backToContentsLabel = \"retour\";\n	var tdm = document.createElement(\"div\");\n	tdm.setAttribute('id','tdm');\n	var tdmBody = document.createElement(\"div\");\n	tdmBody.setAttribute('id','tdm-corps');\n	tdm.appendChild(tdmBody);\n 	var sectionNumbers = [0,0,0,0,0,0];\n	addSections(document.body, tdmBody, sectionNumbers);\n 	replace.parentNode.replaceChild(tdm, replace);\n\n");
  
  fprintf(flot_js,"function addSections(n, tdm, sectionNumbers) {\n	for(var m = n.firstChild; m != null; m = m.nextSibling) {\n	if ((m.nodeType == 1) && (m.tagName.length == 2) && (m.className == \"tdm_part\")) {\n	var level = parseInt(m.tagName.charAt(1));\n	if (!isNaN(level)) {\n	var fragmentId = '';\n	sectionNumbers[level-1]++;\n  for(var i = level ; i < 6; i++) sectionNumbers[i] = 0;\n	var sectionNumber = \"\";\n	for(var i = 0; i < level ; i++) {\n	sectionNumber += sectionNumbers[i];\n	if (i < level) sectionNumber += \".\";}\n if (m.getAttribute(\"id\")) {\n  fragmentId = m.getAttribute(\"id\");\n  } else {fragmentId = \"SECT\"+sectionNumber;\n	m.setAttribute(\"id\", fragmentId);}\n	if (createBackLink) {\n 	var anchor = document.createElement(\"span\");\n  anchor.className = 'tdm-retour';\n	var backlink = document.createElement(\"a\");\n backlink.setAttribute(\"href\", \"#tdm\");\n	backlink.appendChild(document.createTextNode(backToContentsLabel));\n		anchor.appendChild(backlink);\n 	n.insertBefore(anchor, m);}\n	var link = document.createElement(\"a\");\n	link.setAttribute(\"href\", \"#\" + fragmentId);\n	var sectionTitle = getTextContent(m);\n 	link.appendChild(document.createTextNode(sectionTitle));\n	var tdmItem = document.createElement(\"div\");\n	tdmItem.className = 'tdm-item tdm-niveau-' + i;\n	var tdmItemEntry = document.createElement(\"span\");\n	tdmItemEntry.className = 'tdm-item-texte';\n	tdmItemNoNode = tdmItemNoTemplate.cloneNode(false);\n	tdmItemNoNode.appendChild(document.createTextNode(sectionNumber+\" \"));\n	tdmItem.appendChild(tdmItemNoNode);\n	tdmItemEntry.appendChild(link);\n	tdmItem.appendChild(tdmItemEntry);\n	tdm.appendChild(tdmItem);\n	sectionNumberNode = sectionNoTemplate.cloneNode(false);\n  sectionNumberNode.appendChild(document.createTextNode(sectionNumber+\" \"));\n  m.insertBefore(sectionNumberNode, m.firstChild);}}\n  else {addSections(m, tdm, sectionNumbers);}}}\n\n");
  
  fprintf(flot_js,"function getTextContent(n) {\n  var s = '';\n  var children = n.childNodes;\n  for(var i = 0; i < children.length; i++) {\n  var child = children[i];\n  if (child.nodeType == 3) s += child.data;\n  else s += getTextContent(child);}\n  return s;}}\n\n");
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
   
  buf = "<body onload=\"init(); init_cite_code();\">";
  fprintf(flot_html_latex,"%s",buf);
   
  //traitement

  //css
  ajout_regles_css( "h1","color : #8291CF;\n");
  ajout_regles_css( "h2","color : #8591CF;\n");
  ajout_regles_css( "h3","color : #8591CF;\n;");
  ajout_regles_css( ".type_specifier","color : #AAAAAA;\n");
  ajout_regles_css( "td","border: 1px solid black;\n");
  ajout_regles_css( ".title","font-size: 40px;\n");
  ajout_regles_css( ".label_equation","margin-left: 5em;\n");
  ajout_regles_css( ".tiny","font-size: 10px;\n");
  ajout_regles_css(".tdm-niveau-1, .tdm-niveau-2, .tdm-niveau-3, .tdm-niveau-4, .tdm-niveau-5, .tdm-niveau-6","font-size: 25px;\n");
  ajout_regles_css(".tdm-niveau-1","margin-left:1em;\nfont-weight:bold;\n");
  ajout_regles_css(".tdm-niveau-2","margin-left:2em;\n");
  ajout_regles_css(".tdm-niveau-3","margin-left:3em;\n");
  ajout_regles_css(".tdm-niveau-4","margin-left:4em;\n");
  ajout_regles_css(".tdm-niveau-5","margin-left:5em;\n");
  ajout_regles_css(".tdm-niveau-6","margin-left:6em;\n");
  //ajouter regle pour nomfonction+nomvariable avec une pile.
  //ajout_regles_css( "class=\"type_specifier\" ","color : #AAAAAA;\n");

  ajout_fonctions_js_tdm();
  ajout_fonction_js_cite_code();
  
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
