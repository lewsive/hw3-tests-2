#ifndef SYMTAB_H
#define SYMTAB_H

#include "scope.h"

void symtab_initialize();
void symtab_push_scope();
void symtab_pop_scope();
void symtab_add_symbol(const char *name, int attribute);
int symtab_lookup(const char *name);

#endif
