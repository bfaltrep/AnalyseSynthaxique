#ifndef LIST_H
#define LIST_H 

struct list_t;

typedef struct list_t *list;

list list_create(void);

void list_destroy(list l);

void list_insert(list l, char *object);

void list_delete(list l, int pos);

int list_size(list l);

int list_empty(list l);

int list_inside(list l, char * object);

void list_print(list l);

#endif
