#include "symbol_table.h"
#include<stdlib.h>
#include<stdio.h>
#include<string.h>

symbol_table scope_table[100];

ident_node* create_ident(char* name, int is_initialized, int is_declaration, int line_number, int declaration_line) {
    ident_node* new_node = malloc(sizeof(ident_node));
    new_node -> is_initialized = is_initialized;    
    new_node -> is_declaration = is_declaration;
    new_node -> line_number = line_number;
    new_node -> declaration_line = declaration_line;
    strcpy(new_node -> name, name);
    return new_node;
}

void add_identifier(int scope, char* name, int is_initialized, int is_declared, int line_number, int declaration_line) {
    if(scope < 0) return;
    ident_node* cur = scope_table[scope].entries;
    ident_node* new_ident = create_ident(name, is_initialized);
    if(!cur) {
        scope_table[scope].entries = new_ident;
    } else {
        while(cur -> next) cur = cur -> next;
        cur -> next = new_ident;
    }
}

void display_symbol_table(int scope) {
    if(scope < 0 || scope > 100 ) return;
    ident_node* cur  = scope_table[scope].entries;
    while(cur) {
        printf("%s\t\t\t%d\t\t\t%d", cur -> name, cur -> is_initialized, cur -> is_declaration);
    }

}

int find_declaration(int scope, char* name) {
    while(scope) {
        ident_node* cur = scope_table[scope].entries;
        while(cur) {
            if(strcmp(cur -> name, name) == 0) return scope;
            cur = cur -> next;
        }
        --scope;
    }
    return -1;
}