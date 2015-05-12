#include "stack.h"
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

void stack_resize(stack s);
int stack_full(stack s);

#define SIZE_INIT 10


struct stack_t{
  void** tab;
  int size;
  int head;
};



/* create an empty stack */
stack stack_create(void){
  stack s = malloc(sizeof(struct stack_t));
  s->tab = malloc (sizeof(void *)*SIZE_INIT);
  s->size = SIZE_INIT;
  s->head = -1;
  return s;
}

/* destroy a stack */
void stack_destroy(stack s){
  free(s->tab);
  free(s);
}

/* push an object on a stack */
void stack_push(stack s, void *object){
  if(stack_full(s)){
    stack_resize(s);
  }
  s->head ++;
  s->tab[s->head] = object;
}

/* return true if and only if the stack is empty */
int stack_empty(stack s){
  return s->head == -1;
}

/* return the top element of the stack.
   The stack must not be empty (as reported by stack_empty()) */
void * stack_top(stack s){
  assert(!stack_empty(s));
  return s->tab[s->head];
}

/* pop an element off of the stack.
   The stack must not be empty (as reported by stack_empty()) */
void stack_pop(stack s){
  if(!stack_empty(s))
    s->head--;
  else
    printf("Empty stack, can't pop.\n");
}

int stack_full(stack s){
  return s->head == (s->size -1);
}

void stack_resize(stack s){
  void** tab2 = malloc (sizeof(void*)*(s->size*2));
  int i;
  for (i =0; i< s->size; i++){
    tab2[i] = s->tab[i];
  }
  s->size = s->size*2;
  //changement de tableau
  void ** tab3 = s->tab;
  s->tab = tab2;
  free(tab3);
}

int stack_size(stack s){
return s->head+1;
}

int stack_inside(stack s, void * object){
  int i = s->head;
  for(; i >= 0 ; i--){
    if(s->tab[i] == object){
      return i;
    }
  }
  return -1;
}

void stack_print(stack s){
printf("\n");
int i = 0;
for(; i <= s->head ; i++){
printf(" %d %s -",i,(char*)s->tab[i]);
}
printf("\n");
}
