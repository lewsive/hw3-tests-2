#include "symtab.h"
#include <stdlib.h>
#include <stdio.h>

#define MAX_SCOPES 100

static scope_t *scopes[MAX_SCOPES];
static int scope_index = -1;

struct Symbol {
    char *name;
    int attribute;
};

void symtab_initialize() {
    scope_index = -1;
}

void symtab_push_scope() {
    scope_index++;
    if (scope_index >= MAX_SCOPES) {
        fprintf(stderr, "Error: Scope stack overflow\n");
        exit(1);
    }
    scopes[scope_index] = scope_create();
}

void symtab_pop_scope() {
    if (scope_index < 0) {
        fprintf(stderr, "Error: Scope stack underflow\n");
        exit(1);
    }
    scope_destroy(scopes[scope_index]);
    scope_index--;
}

void symtab_add_symbol(const char *name, int attribute) {
    struct Symbol symbol;
    symbol.name = strdup(name); // Ensure 'name' is a valid string
    if (symbol.name == NULL) {
        // Handle memory allocation failure
    }
    symbol.attribute = attribute;
    // Add the symbol to the symbol table
}

int symtab_lookup(const char *name) {
    for (int i = scope_index; i >= 0; i--) {
        int attribute = scope_lookup(scopes[i], name);
        if (attribute != -1) {
            return attribute;
        }
    }
    return -1;  // Indicate symbol not found in any scope
}
