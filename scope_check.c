#include "scope_check.h"
#include <stdlib.h>
#include <string.h>

#define HASH_MULTIPLIER 31

static unsigned int hash(const char *name, int size) {
    unsigned int hash_val = 0;
    while (*name) {
        hash_val = hash_val * HASH_MULTIPLIER + *name++;
    }
    return hash_val % size;
}

Scope *create_scope(int size) {
    Scope *scope = (Scope *)malloc(sizeof(Scope));
    scope->symbols = (Symbol **)calloc(size, sizeof(Symbol *));
    scope->size = size;
    return scope;
}

void destroy_scope(Scope *scope) {
    for (int i = 0; i < scope->size; i++) {
        Symbol *symbol = scope->symbols[i];
        while (symbol) {
            Symbol *next = symbol->next;
            free(symbol->name);
            free(symbol);
            symbol = next;
        }
    }
    free(scope->symbols);
    free(scope);
}

bool add_symbol_to_scope(Scope *scope, const char *name, IdentifierType type, int value) {
    unsigned int index = hash(name, scope->size);
    Symbol *symbol = scope->symbols[index];

    while (symbol) {
        if (strcmp(symbol->name, name) == 0) {
            return false;
        }
        symbol = symbol->next;
    }

    symbol = (Symbol *)malloc(sizeof(Symbol));
    symbol->name = strdup(name);
    symbol->type = type;
    symbol->value = value;
    symbol->next = scope->symbols[index];
    scope->symbols[index] = symbol;
    return true;
}

Symbol *lookup_symbol_in_scope(Scope *scope, const char *name) {
    unsigned int index = hash(name, scope->size);
    Symbol *symbol = scope->symbols[index];
    while (symbol) {
        if (strcmp(symbol->name, name) == 0) {
            return symbol;
        }
        symbol = symbol->next;
    }
    return NULL;
}
