#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include "list.h"

typedef struct list_cell cell;

struct list_cell{
  void * val;
  cell * next;
};

struct list_t{
  cell * first;
  int size;
};

cell * create_cell();

cell* create_cell(){
  cell * c = malloc (sizeof (cell));
  c->val = NULL;
  c->next = NULL;
  return c;
}

list list_create(void){
  list l =  malloc (sizeof (struct list_t));
  l->first = NULL;
  l->size = 0;
  return l;
}

void list_destroy(list l){
  while(l->first != NULL){
    list_delete(l,0);
  }
  free(l);
}

void list_insert(list l, void *object){
  cell* c = create_cell();
  c->val = object;
  c->next = l->first;
  l->first = c;
  l->size++;
}

void list_delete(list l, int pos){
  assert(pos >= 0 && (pos < l->size || l->size == 0));
  cell * c = l->first;
  cell * c2;

  l->size--;
  
  if(pos == 0){
    c = c->next;
    free(l->first);
    l->first = c;
    return;
  }
  int i =0 ;
  for(; i < pos-1 ; i++){
    c = c->next;
  }
  c2 = c->next;
  c->next = c2->next;
  free(c2);
}

int list_size(list l){
  return l->size;
}

int list_empty(list l){
  return l->first == NULL;
}

int list_inside(list l, void * object){
  int i = 0;
  cell * c = l->first;
  for(; i < l->size ; i++){
    if(strcmp(c->val,object) == 0){
      return i;
    }
    c = c->next;
  }
  return -1;
}
