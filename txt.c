#include <stdio.h>
#include "test5h"

#define CONSTANTE 52
int i;

/*
 fonctions locales
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
  char * c = "chocolat <chocolat> !";
  //on exploite les deux fonctions avant de retourner
  if(i == 0){
    f(i);
  }
  else{
    g(i);
  }
  do {
    i++;
  }while (i < 10);
  switch(i){
  case 10:
    printf("toto");
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
  int j = 2;
  j++;
  i = i+2;
  return i;
}

void g(int j){
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
}

