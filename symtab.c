//make a list of lists, representing scope, then the parsed thing.
//arr[scope #][item in scope]
//i = scope #
//i++ when block start parsed
//i-- when block end parsed
//add to arr[i][x] when the xth thing is parsed

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Types of identifiers
typedef enum { CONST_TYPE, VAR_TYPE, PROC_TYPE } IdentifierType;

// Structure to hold information about each identifier
typedef struct Symbol {
    char *name;
    IdentifierType type;
    int value;             // Used for constants
    struct Symbol *next;   // For chaining in hash table
} Symbol;

// Structure for each scope
typedef struct Scope {
    struct Scope *parent;    // Points to the parent scope (for nested scopes)
    Symbol **symbols;        // Hash table of symbols in this scope
    int size;                // Size of the hash table
} Scope;

// Global pointer to the current scope
Scope *current_scope = NULL;

Scope* create_scope(Scope *parent, int size) {
    Scope *scope = (Scope *)malloc(sizeof(Scope));
    scope->parent = parent;
    scope->symbols = (Symbol **)calloc(size, sizeof(Symbol *));
    scope->size = size;
    return scope;
}

void enter_scope(int size) {
    current_scope = create_scope(current_scope, size);
}

void exit_scope() {
    if (current_scope != NULL) {
        Scope *old_scope = current_scope;
        current_scope = current_scope->parent;
        free(old_scope->symbols);
        free(old_scope);
    }
}

Symbol* add_symbol(Scope *scope, const char *name, IdentifierType type, int value) {
    unsigned int index = hash(name, scope->size);
    Symbol *new_symbol = (Symbol *)malloc(sizeof(Symbol));
    new_symbol->name = strdup(name);
    new_symbol->type = type;
    new_symbol->value = value;
    new_symbol->next = scope->symbols[index];
    scope->symbols[index] = new_symbol;
    return new_symbol;
}

Symbol* lookup_symbol(Scope *scope, const char *name) {
    while (scope != NULL) {
        unsigned int index = hash(name, scope->size);
        Symbol *symbol = scope->symbols[index];
        while (symbol != NULL) {
            if (strcmp(symbol->name, name) == 0)
                return symbol;
            symbol = symbol->next;
        }
        scope = scope->parent;
    }
    return NULL;
}


// Hash function for symbol table
unsigned int hash(const char *name, int size) {
    unsigned int hash_val = 0;
    while (*name) hash_val = (hash_val << 5) + *name++;
    return hash_val % size;
}
