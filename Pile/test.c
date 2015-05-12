#include <stdio.h>
#include <stdlib.h>
#include "stack.h"

int main (){
  stack s = stack_create();
  stack_push(s,"hello");
  stack_push(s,"world");
  stack_push(s,"and");
  stack_push(s,"co");
  printf("%d\n",stack_inside(s,"and"));
  printf("%d\n",stack_inside(s,"tchou"));
  stack_destroy(s);
  return EXIT_SUCCESS;
}
