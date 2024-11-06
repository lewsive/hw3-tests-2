#ifndef SCOPE_H
#define SCOPE_H

#include "ast.h"  // For access to types like identifiers

typedef struct {
    char *name;
    int attribute;  // Replace with actual attribute type as needed
} symbol_t;

typedef struct scope {
    symbol_t *symbols;
    int symbol_count;
    int max_symbols;
} scope_t;

scope_t *scope_create();
void scope_add_symbol(scope_t *scope, const char *name, int attribute);
int scope_lookup(const scope_t *scope, const char *name);
void scope_destroy(scope_t *scope);

#endif
