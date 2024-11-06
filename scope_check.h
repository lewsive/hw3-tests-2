#ifndef SCOPE_H
#define SCOPE_H

#include <stdbool.h>

typedef enum { CONST_TYPE, VAR_TYPE, PROC_TYPE } IdentifierType;

typedef struct Symbol {
    char *name;
    IdentifierType type;
    int value;
    struct Symbol *next;
} Symbol;

typedef struct Scope {
    Symbol **symbols;
    int size;
} Scope;

Scope *create_scope(int size);
void destroy_scope(Scope *scope);
bool add_symbol_to_scope(Scope *scope, const char *name, IdentifierType type, int value);  // Renamed function
Symbol *lookup_symbol_in_scope(Scope *scope, const char *name);

#endif // SCOPE_H
