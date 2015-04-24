#include<stdio.h>
#include<stdlib.h>
#include <assert.h>
#include "queue.h"

typedef struct queue_cell cell;

struct queue_cell
{
  void* val;
  cell* next;
};

struct queue_t{
  cell* back;  //entree
  cell* front; //sortie
};

cell* create_cell();

queue queue_create(void){
  queue q = malloc(sizeof(struct queue_t));
  cell* sent = create_cell();
  q->front = sent;
  q->back = sent;
  return q;
}

cell* create_cell()
{
  cell* c = malloc(sizeof(cell));
  c->val = NULL;
  c->next = NULL;
  return c;
}

void queue_destroy(queue q){
  while(q->front != q->back){
    queue_pop(q);
  }
  queue_pop(q);
  free(q);
}

int queue_empty(queue q){
  if(q->back == q->front)
    return 1;
  return 0;
}

void queue_push(queue q, void *object){
  cell* c = create_cell();
  c->val = object;
  q->back->next = c;
  q->back = c;
}

void * queue_front(queue q){
  assert(!queue_empty(q));
  return q->front->next->val;
}

void queue_pop(queue q){
  if(!queue_empty(q))
  {
      cell* c = q->front->next;
      free(q->front);
      q->front = c;  
  }else{
    free(q->front);
    q->front = NULL;
  } 
}
