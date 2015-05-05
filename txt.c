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
  * \brief fonction principale, lancée par l'exécutable
  * \param a c
  * \param d
  * \return aie
 */
int main(void){
  //contient des < > qui ne sont pas traités par html
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

