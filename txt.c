#include <stdio.h>
#include "test5.h"

#ifndef TRAITEMENT_H
#define TRAITEMENT_H
#endif
#define CONSTANTE 52
int i;

/*
 fonctions locales
 f puis g
 pleins de choses
*/
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
  //comme on peut le voir, les < > et & ne sont pas interprétés par le html
  char * c = "chocolat <au lait> &tralala !";
  if(i == 0)
    f(i);
  else{
    g(i);
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
    printf("tata");
    break;
  default :
    printf("error");
    break;
  }
  return 0;
}

int f (int i){
  /* variable et commentaire indispensable... */
  int j = 2;
  j++;
  i = i+2;
  return j;
}

void g(int j){
  int tableau[][];
  //l'étoile est aussi considérée comme type de texte
  char * texte;
  
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
  //globale
  j--;
  f(2);
}

