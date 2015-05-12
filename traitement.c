#include "traitement.h"

static int create_menu(FILE * f);

/*Formate et ajoute un bloc associé a des selecteurs dans le css.*/
void ajout_regles_css( char * selecteurs, char * regles){
  fprintf(flot_css,"%s{\n%s}\n\n", selecteurs,regles);
}

void ajout_balise_class(char * type, char * contenu){
  fprintf(flot_html_c, "\n<span class=\"%s\">%s</span>\n",type,contenu);
}

void ajout_balise_variable(char * surnom, char * nom){
  fprintf(flot_html_c, "\n<a class=\"var %s\" href=\"#%s\">%s</a>", surnom,surnom, nom);
}

void ajout_div( char * class){
  fprintf(flot_html_c,"<div class=\"%s\">",class);
}

void div_fermante(){
  fprintf(flot_html_c, "</div>");
}

void new_line(int size){
  fprintf(flot_html_c, "<br>");
  if(size == 0){
    fprintf(flot_html_c, "<br>");
  }
  int i = 0;
  for(;i < size; i++){
    tab();tab();tab();tab();
  }
}

void tab(){
  fprintf(flot_html_c, "&nbsp");
}

void p_virgule(){
  fprintf(flot_html_c, ";");
  //on ne met pas a la ligne quand on est dans une boucle for
  if(!bool_cond){
    new_line(indentation);
  }
}

void accolade_ouvrante(){
  fprintf(flot_html_c, "<span class=\"accolade\">{</span> <span>");
  indentation++;
  new_line(indentation);
  //pour pouvoir traiter le crochet comme les nom de variables lorsque l'on supprime de la pile, on doit allouer de la mémoire.
  char * tmp;
  asprintf(&tmp,"{" );
  stack_push(variables,tmp);
}

void accolade_fermante(){
  if(indent_switch){
    indentation--;
    indent_switch = 0;
    int size = strlen("&nbsp")*sizeof(char)*4;
    fseek(flot_html_c,-size,SEEK_CUR);
  }
  //retirer une tabulation avant d'écrire l'accolade
  int size = strlen("&nbsp")*sizeof(char)*4;
  fseek(flot_html_c,-size,SEEK_CUR);
  
  fprintf(flot_html_c, "</span>}");
  indentation--;
  if(indentation < 0)
    {
      yyerror("syntax error. too many '}' \n");
    }
  new_line(indentation);
  while(strcmp("{",stack_top(variables)) != 0){
    stack_pop(variables);
  }
  stack_pop(variables);
}

/*
  a la fin d'une declaration ou definition de fonction, on doit retirer les arguments, contenus dans l'entête, de la pile
*/
void fin_def_dec_fonction(){
  while(strcmp("(",stack_top(variables)) != 0){
    stack_pop(variables);
  }
  stack_pop(variables);
}

void ajout_balise_id(char * nom_var){
  fprintf(flot_html_c,"<span id=\"%s\"></span>",nom_var);
}

char * retrouver_variable(char * nom){
  char * surnom = stack_inside_variable(variables,nom);
  if(surnom == NULL){
    //message retiré car pose des problèmes pour les fonctions importées par des includes.
    /*
      char * tmp;
      asprintf(&tmp,"%s%s","syntax error. variable undeclared : ",nom);
      yyerror(tmp);
      free(tmp);
    */
    return "noname";
  }
  return surnom;
}

/*
  ajoute le nouveau nom de variable dans la liste, dans la pile et dans le fichier javascript
*/
void ajouter_variable(char * nom){
  char * tmp;
  char * tmp2;
  asprintf(&tmp,nom);
  asprintf(&tmp2,nom);
  list_insert(variables_name,tmp);

  //si on est au niveau d'indentation 0, on a une déclaration/definition global. On veut donc mettre un point devant pour pouvoir retrouver la decl/def de la variable/fonction
  if(indentation == 0 && !lock){
    char * point;
    asprintf(&point,"." );
    stack_push(variables,point);
    lock = 0;
  }
  stack_push(variables,tmp2);

  //fonctionnalité : survole variable => mise en valeur
  fprintf(flot_js,"\n$(\".%s\").hover(function() {\n    $(\".%s\").css(\"color\",\"#99FF33\");\n    $(\".%s\").css(\"background-color\",\"#2B2B2B\");\n    $(\".%s\").css(\"font-weight\",\"bold\");\n    $(\".declaration.%s\").css(\"color\",\"black\");\n    $(\".declaration.%s\").css(\"background-color\",\"#99FF33\");},function() {\n    $(\".%s\").css(\"color\",\"#66AA33\");\n    $(\".%s\").css(\"background-color\",\"initial\");\n    $(\".%s\").css(\"font-weight\",\"normal\");\n    });\n\n",tmp,tmp,tmp,tmp,tmp,tmp,tmp,tmp,tmp);
  free(tmp);
}

/*
  créer un nom unique à la variable déclarée
*/
void nommer_variable(char * nom){
  //si il s'agit de globales
  if(indentation == 0 && !lock){
    ajouter_variable(nom);
  }
  else{
    int pos = list_inside(variables_name,nom);
    if(pos == -1){
      ajouter_variable(nom);
    }
    else{
      //si ce nom existe déjà, on renomme la classe spécifique à la variable
      int i = 2;
      char * tmp;
      do{
	//nettoyage des noms testé mais déjà utilisés.
	if(i > 2){
	  free(tmp);
	}
	asprintf(&tmp,"%d%s",i,nom);
	pos = list_inside(variables_name,tmp);
	i++;
      }while(pos != -1);
      ajouter_variable(tmp);
      free(tmp);
    }
  }
}

static int create_menu(FILE * f)
{
  char *c = "<li><a href=\"",//latex.html
    *d = "\">",
    *e = "</a></li>";

  fprintf(f,"<ul id=\"menu\">");
  fprintf(f,"%s%s%s%s%s",c,"index.html",d,"Index",e);
  fprintf(f,"%s%s%s%s%s",c,"code_c.html",d,"Partie C",e);
  fprintf(f,"%s%s%s%s%s",c,"com_doxy.html",d,"Partie Documentation",e);
  fprintf(f,"%s%s%s%s%s",c,"latex.html",d,"Partie LateX",e);
  fprintf(f,"</ul>");
  
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
    
/*
 Fonction récupérée sur le site developpez.com/articles/libc/string
 permet de remplacer une chaine de caractère par une autre chaine, dans une chaine.
 utilisée pour remplacer les caractères spéciaux du html dans les chaines de caractères
*/
char *str_remplace (const char *s, unsigned int start, unsigned int lenght, const char *ct)
{
   char *new_s = NULL;

   if (s != NULL && ct != NULL && start >= 0 && lenght > 0)
   {
      int size = strlen (s);

      new_s = malloc (sizeof (*new_s) * (size - lenght + strlen (ct) + 1));
      if (new_s != NULL)
      {
         memcpy (new_s, s, start);
         memcpy (&new_s[start], ct, strlen (ct));
         memcpy (&new_s[start + strlen (ct)], &s[start + lenght], size - lenght - start + 1);
      }
   }
   else
   {
      fprintf (stderr, "Memoire insuffisante\n");
      exit (EXIT_FAILURE);
   }
   return new_s;
}

void string_literal(){
  char * carac;
  char * tmp = NULL;
  int i;
  while((carac = strpbrk(yylval_string_numb,"<>")) != NULL){
    switch(carac[0]){
    case '<':
      tmp = yylval_string_numb;
      i = carac - yylval_string_numb;
      yylval_string_numb = str_remplace (yylval_string_numb, i, 1, "&lt;");
      free(tmp);
      break;
    case '>':
      tmp = yylval_string_numb;
      i = carac - yylval_string_numb;
      yylval_string_numb = str_remplace (yylval_string_numb, i, 1, "&gt;");
      free(tmp);
      break;
    default :
      printf("erreur string literal\n");
      break;
    }
  }
  free(carac);
  ajout_balise_class("string_literal",yylval_string_numb);
  free(yylval_string_numb);
}

int create_files(int exec, char * nom, char * fichier){
  char * buf;
  //créer les fichiers du site
  flot_css = fopen("style.css","w+");
  flot_js = fopen("script.js","w+");
  
  //html
  buf = "<!DOCTYPE html><html>";
  char * debut = "<head><meta charset=\"utf-8\" lang=\"";

  //gestion du c
  if(exec){
    flot_html_c = fopen(fichier,"w+");
    flot_html_doc = fopen("com_doxy.html", "w+");

    fprintf(flot_html_c,"%s",buf);
    fprintf(flot_html_doc,"%s",buf);
    
    //en Tete
    fprintf(flot_html_c,"%s%s \" /><link  rel=\"stylesheet\" href=\"style.css\" /><title> %s_c </title></head>\n",debut, "fr", nom);
    fprintf(flot_html_doc,"%s%s \" /><link  rel=\"stylesheet\" href=\"style.css\" /><title> %s_Doxy </title></head>\n",debut, "fr",nom);

    buf = "<body>";
    fprintf(flot_html_c,"%s",buf);
    fprintf(flot_html_doc,"%s",buf);

    create_menu(flot_html_c);
    create_menu(flot_html_doc);
  }
  else{
    //gestion du latex
    flot_html_latex = fopen(fichier,"w+");
    
    fprintf(flot_html_latex,"%s",buf);
    fprintf(flot_html_latex,"%s%s\" /><link  rel=\"stylesheet\" href=\"style.css\" /><title>%s_LaTeX</title></script><script type=\"text/javascript\"><!--\n function init(){\n tdm('tdm');\n }\n --> </script> </head>",debut, "fr", nom);
    buf = "<body onload=\"init(); init_cite_code();\">";
    fprintf(flot_html_latex,"%s",buf);
    create_menu(flot_html_latex);
  }
  
  //css
  
  ajout_regles_css("body","background-color : #333333; \ncolor : white; \nfont-family : Arial; \nfont-size : 1.5vw; \n");
  
  ajout_regles_css( "a, h1, h2, h3","color : #8291CF;\n");
  ajout_regles_css( "ul#menu li","display:inline;margin:10px;padding:10px;\n");
  ajout_regles_css( "ul#menu","text-align:center; margin:0;padding:0; list-style:none;\n");

  //-- c
  ajout_regles_css(".preproc","color : #FF9933;\n");
  ajout_regles_css(".number","color : #CF3838;\n");
  ajout_regles_css(".key_word" ,"color : #FF6600;\n");
  ajout_regles_css(".type_specifier" ,"color : #0099FF;\n");
  ajout_regles_css(".string_literal","color : #DAA520;\n");
  ajout_regles_css(".var","color : #66AA33;\ntext-decoration:none;\n");
  ajout_regles_css(".comment_line, .comment","color : #999999;\n");
  ajout_regles_css(".accolade","cursor:pointer;\n");
  ajout_regles_css(".noname","color : white;\n");

  ajout_regles_css(".fonction","background-color: rgba(83,164,255,0.2);\npadding: 1% 2% 2% 2%;\nborder : 3px #53A4FF solid;\nborder-radius: 7px;\n margin-bottom: 40px\n");
  ajout_regles_css(".fn" ,"	font-size: 150%;\n	color: #53A4FF;\n");
  ajout_regles_css(".brief" ,"padding-left: 3%;\n font-style: italic;\n	margin-bottom: 15px;\n");
  ajout_regles_css(".paramTitle","color: #A39CF7;\n	font-weight: bold;\n");
  ajout_regles_css(".param","padding-left: 3%;\n");
  ajout_regles_css(".returnTitle","margin-top: 15px;\n color: #A39CF7;\n font-weight: bold;\n");
  ajout_regles_css(".return","padding-left: 3%;\n");

  //-- latex
  
  ajout_regles_css( "td","border: 1px solid black;\n");
  ajout_regles_css( "table","border-collapse: collapse;\n");
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


  //js
  if(exec){
    //js fonctionnalité : clique accolades ouvrantes.
    fprintf(flot_js,"$('body').on('click','.accolade',function(){\n 	$(this).next('span').toggle(); \n});\n");
    //fonctionnalité : lien sur variable mène vers déclaration.
    fprintf(flot_js,"\n$('a[href^=\"#\"]').click(function(){\n    var id = $(this).attr(\"href\");\n    var offset = $(id).offset().top\n    $('html, body').animate({scrollTop: offset}, 'slow');\n    return false; \n});\n\n");
  }
  else{
    ajout_fonctions_js_tdm();
    ajout_fonction_js_cite_code();
  }

  return 0;
}

 void finish_files(int exec){
   
   char * buf = "\n<script src=\"site/jquery-1.11.2.min.js\"></script>\n<script type=\"text/javascript\" src=\"script.js\" ></script>\n";
   char * buf2 = "</body></html>";
   if(exec){
     fprintf(flot_html_c,"%s%s",buf,buf2);
     fprintf(flot_html_doc,"\n%s",buf2);
     
     fclose(flot_html_c);
     fclose(flot_html_doc);
     
   }
   else{
     fprintf(flot_html_latex,"%s<t class=\"tiny\"><center>Cette page HTML a été générée à partir d'un fichier LateX</center></t>%s",buf,buf2);
     
     fclose(flot_html_latex);
   }
  fclose(flot_js);
  fclose(flot_css);
}

