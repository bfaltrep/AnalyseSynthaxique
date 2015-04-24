#ifndef QUEUE_H
#define QUEUE_H
/* Header file for the queue abstract data type (queue.h) */

struct queue_t;

typedef struct queue_t *queue;

/* create an empty queue */
queue queue_create(void);

/* create an empty queue */
void queue_destroy(queue s);

/* return true if and only if the queue is empty */
int queue_empty(queue s);

/* push an object on the back of the queue */
void queue_push(queue s, void *object);


/* return the front element of the queue.
   The queue must not be empty (as reported by queue_empty()) */
void * queue_front(queue s);

/* pop the front element off of the queue.
   The queue must not be empty (as reported by queue_empty()) */
void queue_pop(queue s);

#endif
