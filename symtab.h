#ifndef SYMTAB_H
#define SYMTAB_H

#include "scope_check.h"
#include "symtab.c"

typedef struct {
    Scope **stack;
    int top;
    int capacity;
} SymbolTable;

SymbolTable *create_symbol_table(int initial_capacity);
void destroy_symbol_table(SymbolTable *symtab);
void enter_scope(SymbolTable *symtab, int scope_size);
void exit_scope(SymbolTable *symtab);
bool add_symbol(SymbolTable *symtab, const char *name, IdentifierType type, int value);  // Refers to SymbolTable version
Symbol *lookup_symbol(SymbolTable *symtab, const char *name);

#endif // SYMTAB_H
