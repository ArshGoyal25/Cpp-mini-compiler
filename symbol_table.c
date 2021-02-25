#include "symbol_table.h"
#include<stdlib.h>
#include<stdio.h>
#include<string.h>

symbol_table scope_table[100];

ident_node* create_ident(int scope, char* name, char* type, int is_initialized, int is_declaration, int line_number, int declaration_line) {
    ident_node* new_node = malloc(sizeof(ident_node));
    new_node -> is_initialized = is_initialized;    
    new_node -> is_declaration = is_declaration;
    new_node -> line_number = line_number;
    new_node -> declaration_line = declaration_line;
    new_node -> scope = scope;
    new_node -> next = NULL;
    strcpy(new_node -> type, type);
    strcpy(new_node -> name, name);
    return new_node;        
}

void add_identifier(int scope, char* name, char* type, int is_initialized, int is_declaration, int line_number, int declaration_line) {    
    if(scope < 0) return;
    ident_node* cur = scope_table[scope].entries;
    ident_node* new_ident = create_ident(scope, name, type, is_initialized, is_declaration, line_number, declaration_line);
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
    printf("\nName\t\t\tType\tLine\tDeclaration Line\tScope\n");
    printf("----------------------------------------------------------------------\n");
    while(cur) {
        printf("%s\t\t\t%s\t%d\t%d\t\t\t%d\n", 
            cur -> name,
            cur -> type,
            cur -> line_number, 
            cur -> declaration_line,
            cur -> scope
        );
        cur = cur -> next;
    }
}

void delete_symbol_table(int scope) {
    if(scope < 0) return;
    ident_node* cur = scope_table[scope].entries;
    ident_node* next;
    while(cur) {
        next = cur -> next;
        free(cur);
        cur = next;
    }
    scope_table[scope].entries = NULL;
}

ident_node* find_declaration(int scope, char* name) {
    while(scope) {
        ident_node* cur = scope_table[scope].entries;
        while(cur) {
            if(strcmp(cur -> name, name) == 0 && cur -> is_declaration) return cur;
            cur = cur -> next;
        }
        --scope;
    }
    return NULL;
}

int create_declaration_entry(int scope, char* name, char* type, int is_initialized, int line_number) {
    ident_node* prev_dec = find_declaration(scope, name);    
    if(prev_dec && prev_dec -> scope == scope) {    // If there was a previous declaration in the same scope    
        return prev_dec -> line_number;
    }    
    add_identifier(scope, name, type, is_initialized, 1, line_number, line_number);    
    return 0;
}

int create_mention_entry(int scope, char* name, int line_number) {
    ident_node* prev_dec = find_declaration(scope, name);
    if(!prev_dec) return 1; // If identifier has not been declared
    add_identifier(scope, name, prev_dec -> type, prev_dec -> is_initialized, 0, line_number, prev_dec -> line_number);
    return 0;
}

void remove_symbol_table_entry(int scope) {
    display_symbol_table(scope);
    delete_symbol_table(scope);
}