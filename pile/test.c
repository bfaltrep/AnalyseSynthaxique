#include <stdio.h>
#include <stdlib.h>
#include "stack.h"

int main (){
  stack s = stack_create();
  stack_push(s,"2hello");
  stack_push(s,"world");
  stack_push(s,"1and");
  stack_push(s,"co");
  /*
  printf("%d\n",stack_inside(s,"and"));
  printf("%d\n",stack_inside(s,"tchou"));
  */
  
  printf("\n\n--- var : %s ---\n\n",stack_inside_variable(s,"and"));
  printf("\n--- var : %s ---\n\n",stack_inside_variable(s,"co"));
  printf("\n--- var : %s ---\n\n",stack_inside_variable(s,"copine"));
  
  stack_destroy(s);
  return EXIT_SUCCESS;
}
