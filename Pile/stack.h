/* Header file for the stack abstract data type (stack.h) */
#ifndef STACK_H
#define STACK_H 

struct stack_t;

typedef struct stack_t *stack;

/* create an empty stack */
extern stack stack_create(void);

/* destroy a stack */
extern void stack_destroy(stack s);

/* push an object on a stack */
extern void stack_push(stack s, void *object);

/* return true if and only if the stack is empty */
extern int stack_empty(stack s);

/* return the top element of the stack.
   The stack must not be empty (as reported by stack_empty()) */
extern void * stack_top(stack s);

/* pop an element off of the stack.
   The stack must not be empty (as reported by stack_empty()) */
extern void stack_pop(stack s);

/* return size of stack*/
extern int stack_size(stack s);

/*
  return -1 if object is not inside the stack. Else, return the position of the object.
*/
extern int stack_inside(stack s, void * object);




#endif
