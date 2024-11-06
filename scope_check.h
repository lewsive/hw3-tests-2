#ifndef SCOPE_H
#define SCOPE_H

#include <stdbool.h>

typedef enum { CONST_TYPE, VAR_TYPE, PROC_TYPE } IdentifierType;

// Structure to hold information about each identifier
typedef struct Symbol {
    char *name;
    IdentifierType type;
    int value;              // Used for constants (optional)
    struct Symbol *next;    // For chaining in hash table (in case of collisions)
} Symbol;

// Structure for each scope
typedef struct Scope {
    Symbol **symbols;       // Hash table of symbols in this scope
    int size;               // Size of the hash table
} Scope;

// Scope management functions
Scope *create_scope(int size);
void destroy_scope(Scope *scope);
bool add_symbol(Scope *scope, const char *name, IdentifierType type, int value);
Symbol *lookup_symbol_in_scope(Scope *scope, const char *name);

#endif // SCOPE_H
