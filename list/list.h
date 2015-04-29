#ifndef LIST_H
#define LIST_H 

struct list_t;

typedef struct list_t *list;

extern list list_create(void);

extern void list_destroy(list l);

extern void list_insert(list l, char *object);

extern void list_delete(list l, int pos);

extern int list_size(list l);

extern int list_empty(list l);

extern int list_inside(list l, char * object);

extern void list_print(list l);
#endif
