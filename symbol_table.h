#include<stdio.h>

typedef struct ident_node {
	char name[33];	
	char type[33];
	int scope;
	int line_number;
	int storage;
	int is_initialized;
	int is_declaration;
	int declaration_line;
	int val_int;
	float val_float;
	char val_string[33];
	char val_char;
	struct ident_node* next;	
} ident_node;

typedef struct symbol_table {
	int scope;
	ident_node* entries;
} symbol_table;


symbol_table scope_table[100];

int create_declaration_entry(int scope, char* name, char* type,int storage, int is_initialized, char* value, int line_number);
int create_mention_entry(int scope, char* name, char* value, int line_number);
void remove_symbol_table_entry(FILE* symbol_table_fp, int scope);
void get_ident_value(int scope, char* name, char* value);