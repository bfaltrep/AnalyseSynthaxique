#include <stdio.h>
#include "test5.h"

#ifndef TRAITEMENT_H
#define TRAITEMENT_H
#endif
#define CONSTANTE 52
/*
 les instructions pour le preprocesseurs sont acceptées
 une globales reconnue au survole.
*/

int i;

int f(int i);
void g();


/**
  * \fn int main(int argc, char *argv[])
  * \brief fonction principale, lancee par l'executable
  * \param argc contient le nombre d'arguments
  * \param argv contient la liste des arguments stockee dans un tableau
  * \return 0 si tout s'est bien passe
 */
int main(int argc, char *argv[]){
  //les < > et & ne sont pas interprétés par le html
  char * c = "chocolat <au lait> &tralala !";
  //si les accolades  ne sont pas présentes, on applique le saut de ligne
  if(i == 0)
    f(i);
  else{
    g(i);
  }

  if(strcmp(c,"tutu") == 0){
    c = malloc(sizeof(char)*5);
    free(c);
  }
  do {
    i++;
  }while (i < 10);
  switch(i){
  case 10:
    //on voit que les ':' sont gérés distinctement
    printf("%s\n",i?"hello":"world");
    break;
  case 11 :
    printf("%s",((char *) c));
    break;
  default :
    printf("error");
    break;
  }
  return 0;
}

/**
  * \fn int f(int i)
  * \brief test 1
  * \param i parametre tres utile pour ce test
  * \return un j inconnu au bataillon
 */
int f (int i){
  int j = 2;
  for(; j < i ; j++)
    printf("coucou, je suis bien indenté !!");
  i = i+2;
  return j;
}

/**
  * \fn int g(int j)
  * \brief fonction de test secondaire. utilisation d'un tableau.
  * \param variable globale j
 */
void g(int j){
  /*l'étoile des pointeurs et les crochets des tableaux sont coloriés      */
  int tableau[][];
  char * texte;
  tableau[i][j] = 5;
  //globale
  j++;

  for(int k = 0; k < 10 ; k++){
    //locale1
    unsigned int j =1;
    j++;
  }

  {
    //locale2
    int j =7;
    j++;
  }
  //parametre de la fonction
  j--;
  f(2);
}

void g2(int j){
  printf("saut de ligne");
 printf("saut de ligne");
 printf("saut de ligne");
 printf("saut de ligne");
 printf("saut de ligne");
 printf("saut de ligne");
 printf("saut de ligne");
 printf("saut de ligne");
 printf("saut de ligne");
 printf("saut de ligne");
 printf("saut de ligne");
 printf("saut de ligne");
 printf("saut de ligne");
 printf("saut de ligne");
 printf("saut de ligne");
  printf("saut de ligne");
 printf("saut de ligne");
 printf("saut de ligne");
 printf("saut de ligne");
   printf("saut de ligne");
   printf("saut de ligne");
   printf("saut de ligne");
   printf("saut de ligne");
}
