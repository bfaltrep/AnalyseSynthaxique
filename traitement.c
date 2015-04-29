#include "traitement.h"

/*Formate et ajoute un bloc associé a des selecteurs dans le css.*/
void ajout_regles_css( char * selecteurs, char * regles){
  char *a ="{\n",
    *b = "}\n\n";
  fprintf(flot_css,"%s%s%s%s", selecteurs, a, regles, b);
}

void ajout_balise_class(char * type, char * contenu){
  char * a = "\n<span class=\"",
    *b = "\">",
    *c = "</span>\n";
  fprintf(flot_html, "%s%s%s%s%s", a, type, b, contenu, c);
}

void ajout_div( char * class){
  fprintf(flot_html,"%s%s%s","<div class=\"",class,"\" >");
}

void div_fermante(){
  fprintf(flot_html, "</div>");
}

void newline(int size){
  fprintf(flot_html, "<br>");
  if(size == 0){
    fprintf(flot_html, "<br>");
  }
  int i = 0;
  for(;i < size; i++){
    tab();tab();tab();tab();
  }
}

void tab(){
  fprintf(flot_html, "&nbsp");
}

void p_virgule(){
  fprintf(flot_html, ";");
  //on ne met pas a la ligne quand on est dans une boucle for
  if(!bool_cond){
    newline(indentation);
  }
}

void accolade_ouvrant(){
  if(bool_cond)
    {
      bool_cond = 0;
    }
  fprintf(flot_html, "<span class=\"accolade\">{</span> <span >");
  indentation++;
  newline(indentation);
  //pour pouvoir traiter le crochet comme les nom de variables lorsque l'on supprime de la pile, on doit allouer de la mémoire.
  char * tmp;
  asprintf(&tmp,"{" );
  stack_push(variables,tmp);
}

void accolade_fermant(){
  //retirer une tabulation avant d'écrire l'accolade
  int size = strlen("&nbsp")*sizeof(char)*4;

  fseek(flot_html,-size,SEEK_CUR);

  
  fprintf(flot_html, "</span>}");
  indentation--;
  if(indentation < 0)
    {
      yyerror("syntax error. too many '}' \n");
    }
  newline(indentation);
  while(strcmp("{",stack_top(variables)) != 0){
    stack_pop(variables);
  }
  stack_pop(variables);
}

char * retrouverVariable(char * nom){
  char * surnom = stack_inside_variable(variables,nom);
  if(surnom == NULL){
    //message retiré car pose des problèmes pour les fonctions importées par des includes.
    /*
      char * tmp;
      asprintf(&tmp,"%s%s","syntax error. variable undeclared : ",nom);
      yyerror(tmp);
      free(tmp);*/
    return "noname";
  }
  return surnom;
}


/*
  ajoute le nouveau nom de variable dans la liste, dans la pile et dans le fichier javascript
*/
void ajouterVariable(char * nom){
  char * tmp;
  char * tmp2;
  asprintf(&tmp,nom);
  asprintf(&tmp2,nom);
  list_insert(variables_name,tmp);
  stack_push(variables,tmp2);
  //fonctionnalité : cliquer sur accolade ouvrante, cache/affiche le contenu
  fprintf(flot_js,"$(\".%s\").hover(function() {\n    $(\".%s\").css(\"background-color\",\"black\");\n    $(\".declaration.%s\").css(\"background-color\",\"blue\");},function() {\n    $(\".%s\").css(\"background-color\",\"initial\");\n    $(\".declaration.%s\").css(\"background-color\",\"initial\");});\n\n",tmp,tmp,tmp,tmp,tmp);
  free(tmp);
}

/*
  créer un nom unique à la variable déclarée
*/
void nommerVariable(char * nom){
  int pos = list_inside(variables_name,nom);
  if(pos == -1){
    ajouterVariable(nom);
  }
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
  ajouterVariable(tmp);
  free(tmp);
}

/*
 Fonction récupérée sur le site developpez.com/articles/libc/string

*/
char *str_remplace (const char *s, unsigned int start, unsigned int lenght, const char *ct)
{
   char *new_s = NULL;

   if (s != NULL && ct != NULL && start >= 0 && lenght > 0)
   {
      size_t size = strlen (s);

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
  char * tmp = "";
  int i;
  while((carac = strpbrk(yylval_string_numb,"<>")) != NULL){
    switch(carac[0]){
    case '<':
      tmp = yylval_string_numb;
      i = carac - yylval_string_numb;
      yylval_string_numb = str_remplace (yylval_string_numb, i, 1, "&lsaquo;");
      break;
    case '>':
      tmp = yylval_string_numb;
      i = carac - yylval_string_numb;
      yylval_string_numb = str_remplace (yylval_string_numb, i, 1, "&rsaquo;");
      break;
    default :
      printf("erreur \n");
      break;
    }
  }
  free(tmp);
  free(carac);
  ajout_balise_class("string_literal",yylval_string_numb);
}

void ajout_enTete_html (char * language, char * title){
  char *a ="<head><meta charset=\"utf-8\" lang=\"",
    *b = "\" /><link  rel=\"stylesheet\" href=\"style.css\" /><title>",
    *c = "</title></head>\n";

  fprintf(flot_html,"%s%s%s%s%s", a, language, b, title, c);
}

int create_files(char * nom){
  //créer les fichiers du site
  flot_html = fopen("index.html","w+");
  flot_css = fopen("style.css","w+");
  flot_js = fopen("script.js","w+");
  flot_html2 = fopen("documentation.html", "w+");
  
  //html
  buf = "<!DOCTYPE html><html>";
  fprintf(flot_html,"%s",buf);
  ajout_enTete_html ("fr", nom);
   
  buf = "<body>";
  fprintf(flot_html,"%s",buf);
   
  //traitement

  //css
  ajout_regles_css("body","background-color : #333333; color : white;\n");
  
  ajout_regles_css(".preproc","color : #FF9933;\n");
  
  ajout_regles_css(".number","color : #CC0000;\n");
  ajout_regles_css(".key_word" ,"color : #FF6600;\n");
  ajout_regles_css(".type_specifier" ,"color : #0099FF;\n");
  ajout_regles_css(".string_literal","color : #DAA520;\n");
  ajout_regles_css(".var","color : #66AA33;\n");
  ajout_regles_css(".comment_line","color : #999999;\n");
  ajout_regles_css(".accolade","cursor:pointer;\n");

  //js

  fprintf(flot_js,"$('body').on('click','.accolade',function(){\n 	$(this).next('span').toggle(); \n});\n");
  
  return 0;
}

void finish(){
   
  char * buf = "\n<script src=\"site/jquery-1.11.2.min.js\"></script>\n<script type=\"text/javascript\" src=\"script.js\" ></script>\n</body></html>";
  fprintf(flot_html,"%s",buf);

  fclose(flot_js);
  fclose(flot_html);
  fclose(flot_html2);
  fclose(flot_css);
}

