#include "scope.h"
#include <stdlib.h>
#include <string.h>

scope_t *scope_create() {
    scope_t *scope = (scope_t *)malloc(sizeof(scope_t));
    scope->symbols = (symbol_t *)malloc(10 * sizeof(symbol_t));
    scope->symbol_count = 0;
    scope->max_symbols = 10;
    return scope;
}

void scope_add_symbol(scope_t *scope, const char *name, int attribute) {
    if (scope->symbol_count >= scope->max_symbols) {
        scope->max_symbols *= 2;
        scope->symbols = realloc(scope->symbols, scope->max_symbols * sizeof(symbol_t));
    }
    scope->symbols[scope->symbol_count].name = strdup(name);
    scope->symbols[scope->symbol_count].attribute = attribute;
    scope->symbol_count++;
}

int scope_lookup(const scope_t *scope, const char *name) {
    for (int i = 0; i < scope->symbol_count; i++) {
        if (strcmp(scope->symbols[i].name, name) == 0) {
            return scope->symbols[i].attribute;
        }
    }
    return -1;  // Indicate symbol not found
}

void scope_destroy(scope_t *scope) {
    for (int i = 0; i < scope->symbol_count; i++) {
        free(scope->symbols[i].name);
    }
    free(scope->symbols);
    free(scope);
}
