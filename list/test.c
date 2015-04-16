#include <stdio.h>
#include <stdlib.h>
#include "list.h"

int main(){
  list l = list_create();

  list_insert(l, "hello");
  list_insert(l, "world");
  list_insert(l, "and");
  list_insert(l, "co");
  
  printf("inside hello ? %d\n",list_inside(l,"hello"));
  
  printf("size : %d. Attendu 4.\n",list_size(l));
  list_delete(l,0);
  printf("size : %d. Attendu 3.\n",list_size(l));
  list_insert(l, "and");
  list_insert(l, "co");
  list_inside(l,"hello");
  printf("size : %d. Attendu 5.\n",list_size(l));
  list_delete(l,4);
  printf("size : %d. Attendu 4.\n",list_size(l));
  printf("vide ? %s\n",list_empty(l)?"oui":"non");
  printf("inside world ? %d\n",list_inside(l,"world"));
  printf("inside tutu ? %d\n",list_inside(l,"tutu"));
  
  list_delete(l,0);list_delete(l,0);list_delete(l,0);list_delete(l,0);
  printf("size : %d. Attendu 0.\n",list_size(l));
  printf("vide ? %s\n",list_empty(l)?"oui":"non");
  list_destroy(l);
}
