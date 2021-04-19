#include "symbol_table.h"
#include<stdlib.h>
#include<stdio.h>
#include<string.h>

symbol_table scope_table[100];

ident_node* create_ident(int block, int scope, char* name, char* type,int storage, int is_initialized, int is_declaration, char* value, int line_number, int declaration_line) {
    ident_node* new_node = malloc(sizeof(ident_node));
    new_node -> is_initialized = is_initialized;    
    new_node -> is_declaration = is_declaration;
    new_node -> line_number = line_number;
    new_node -> declaration_line = declaration_line;
    new_node -> scope = scope;
    new_node -> block = block;
    new_node -> storage = storage;
    new_node -> next = NULL;
    strcpy(new_node -> val_string, value);
    strcpy(new_node -> type, type);
    strcpy(new_node -> name, name);
    return new_node;        
}

void add_identifier(int block, int scope, char* name, char* type, int storage, int is_initialized, int is_declaration, char* value, int line_number, int declaration_line) {    
    if(scope < 0) return;
    ident_node* cur = scope_table[scope].entries;
    ident_node* new_ident = create_ident(block, scope, name, type, storage, is_initialized, is_declaration, value, line_number, declaration_line);
    if(!cur) {
        scope_table[scope].entries = new_ident;        
    } else {
        while(cur -> next) cur = cur -> next;
        cur -> next = new_ident;
    }
}

void display_symbol_table(FILE* symbol_table_fp, int scope) {
    if(scope < 0 || scope > 100 ) return;
    ident_node* cur  = scope_table[scope].entries;
    fprintf(symbol_table_fp, "\n%s\t\t\t\t%30s\t\t%10s\t\t%10s\t\t%10s\t\t%15s\t%10s\t\t%10s\n","Name","Type","Storage","Value","Line","Declaration Line","Scope","Block");
    fprintf(symbol_table_fp, "-----------------------------------------------------------------------------------------------------------------------------------------------------\n");
    while(cur) {
        fprintf(symbol_table_fp, "%s\t\t\t\t\t%30s\t\t\t\t%d\t\t%10s\t\t\t\t%d\t\t\t\t\t%d\t\t\t\t%d\t\t\t\t%d\n", 
            cur -> name,
            cur -> type,
            cur -> storage,
            cur -> val_string,
            cur -> line_number, 
            cur -> declaration_line,
            cur -> scope,
            cur -> block
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

int create_declaration_entry(int block, int scope, char* name, char* type,int storage, int is_initialized, char* value, int line_number) {
    ident_node* prev_dec = find_declaration(scope, name);    
    if(prev_dec && prev_dec -> scope == scope) {    // If there was a previous declaration in the same scope    
        return prev_dec -> line_number;
    }    
    add_identifier(block, scope, name, type, storage, is_initialized, 1, value, line_number, line_number);    
    return 0;
}

char* find_var_type(int scope, char* name, int line_number) {
    ident_node* prev_dec = find_declaration(scope, name);
    if(!prev_dec) return "None"; // If identifier has not been declared
    return prev_dec->type;
}

int create_mention_entry(int block, int scope, char* name,char* value, int line_number) {
    ident_node* prev_dec = find_declaration(scope, name);
    if(!prev_dec) return 1; // If identifier has not been declared
    add_identifier(block, scope, name, prev_dec -> type, prev_dec -> storage ,prev_dec -> is_initialized, 0, value , line_number, prev_dec -> line_number);
    return 0;
}


void find_prev_entry(int scope, char* name, char* value) {
    while(scope) {
        ident_node* cur = scope_table[scope].entries;
        //char res[200] = "None";
        while(cur) {
            if(strcmp(cur -> name, name) == 0 ) {
                strcpy(value, cur->val_string);
                //printf("%s\n",value);
            }                
            cur = cur -> next;
        }
        //printf("%s\n", res);
        if(strcmp(value,"None") != 0){
            return ;
        } 
        --scope;
    }
}

void get_ident_value(int scope, char* name, char* value) {
    //char value[20];
    find_prev_entry(scope, name,value);
}

void remove_symbol_table_entry(FILE* symbol_table_fp, int scope) {
    display_symbol_table(symbol_table_fp, scope);
    delete_symbol_table(scope);
}