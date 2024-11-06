#include "symtab.h"
#include <stdlib.h>

SymbolTable *create_symbol_table(int initial_capacity) {
    SymbolTable *symtab = (SymbolTable *)malloc(sizeof(SymbolTable));
    symtab->stack = (Scope **)malloc(initial_capacity * sizeof(Scope *));
    symtab->top = -1;
    symtab->capacity = initial_capacity;
    return symtab;
}

void destroy_symbol_table(SymbolTable *symtab) {
    while (symtab->top >= 0) {
        exit_scope(symtab);
    }
    free(symtab->stack);
    free(symtab);
}

void enter_scope(SymbolTable *symtab, int scope_size) {
    if (symtab->top + 1 >= symtab->capacity) {
        symtab->capacity *= 2;
        symtab->stack = (Scope **)realloc(symtab->stack, symtab->capacity * sizeof(Scope *));
    }
    symtab->stack[++symtab->top] = create_scope(scope_size);
}

void exit_scope(SymbolTable *symtab) {
    if (symtab->top >= 0) {
        destroy_scope(symtab->stack[symtab->top--]);
    }
}

bool add_symbol(SymbolTable *symtab, const char *name, IdentifierType type, int value) {
    if (symtab->top < 0) return false;
    return add_symbol(symtab->stack[symtab->top], name, type, value);
}

Symbol *lookup_symbol(SymbolTable *symtab, const char *name) {
    for (int i = symtab->top; i >= 0; i--) {
        Symbol *symbol = lookup_symbol_in_scope(symtab->stack[i], name);
        if (symbol != NULL) {
            return symbol;
        }
    }
    return NULL; // Not found in any scope
}
