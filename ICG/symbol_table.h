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
