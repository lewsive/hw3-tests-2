#ifndef SYMTAB_H
#define SYMTAB_H

#include "scope.h"
#include "symtab.c"

extern void symtab_initialize();
extern void symtab_push_scope();
extern void symtab_pop_scope();
extern void symtab_add_symbol(const char *name, int attribute);
extern int symtab_lookup(const char *name);

#endif
