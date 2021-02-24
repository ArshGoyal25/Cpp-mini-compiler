typedef struct ident_node {
	char name[33];	
	char type;
	int scope;
	int line_number;
	int storage;
	int is_initialized;
	int is_declaration;
	int declaration_line;
	struct ident_node* next;	
} ident_node;

typedef struct symbol_table {
	int scope;
	ident_node* entries;
} symbol_table;


symbol_table scope_table[100];

void add_identifier(int scope, char* name, int is_initialized, int is_declared, int line_number, int declaration_line);
ident_node* find_declaration(int scope, char* name);
void delete_symbol_table(int scope);

int create_declaration_entry(int scope, char* name, int is_initialized, int line_number);
int create_mention_entry(int scope, char* name, int line_number);