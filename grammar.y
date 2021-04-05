%{
#include<stdio.h>
#include<string.h>
#include"lex.yy.c"
#include "symbol_table.h"
int yylex();
void yyerror(char *s);

char err_mes[200];
char type_spec_buffer[100];
char identifier_buffer[100];

#define VALIDATE_IDENT_LEN(identifier)                                          \
        strcpy(identifier_buffer, identifier);                                  \
        if(strlen(identifier_buffer) > 31) {                                    \
            sprintf(err_mes, "Identifier length too long: %s", identifier);     \
            identifier_buffer[31] = 0;                                          \
            yyerror(err_mes);                                                   \
        }

#define SYM_TAB_DECL(scope, name, type_spec, is_initialized, line_number)                                           \
        VALIDATE_IDENT_LEN(name);                                                                                   \
        int err = create_declaration_entry(scope, identifier_buffer, type_spec, is_initialized, line_number);       \
        if(err) {                                                                                                   \
            sprintf(err_mes, "%s already declared in line %d", identifier_buffer, err);                             \
            yyerror(err_mes);                                                                                       \
        }

#define SYM_TAB_ADD(scope, name, line_number)                                   \
        int err = create_mention_entry(scope, name, line_number);               \
        if(err) {                                                               \
            sprintf(err_mes, "no declaration found for %s", name);              \
            yyerror(err_mes);                                                   \
        }

#define TYPE_SPEC_SAVE(type_spec) strcpy(type_spec_buffer, type_spec);

#define SYM_TAB_DEL(scope) remove_symbol_table_entry(symbol_table_fp, scope);

%}
%union {
    int ival;
    float fval;
    char *sval;
}

%left ','
%right ASSIGN_B_AND ASSIGN_B_OR ASSIGN_B_XOR
%right ASSIGN_B_LSHIFT ASSIGN_B_RSHIFT
%right ASSIGN_MUL ASSIGN_DIV ASSIGN_MOD
%right ASSIGN_ADD ASSIGN_SUB
%right '='
%left OR
%left AND
%left B_OR
%left B_XOR
%left B_AND
%left EQ NE
%left LT GT LE GE
%left B_LSHIFT B_RSHIFT
%left '+' '-'
%left '*' '/' '%'
%right NOT B_NOT


%token PRE_DIR
%token <sval> IDENT
%token <ival> INT_CONS
%token <fval> FLOAT_CONS
%token <sval> STRING_CONS CHAR_CONS BOOL_CONS HEADER TYPE_SPEC

%token PRO_BEG

%token IF BREAK CONTINUE RETURN COUT INCLUDE
%token WHILE SWITCH CASE DEFAULT

%token LT GT LE GE EQ NE
%token AND OR NOT
%token B_AND B_OR B_NOT B_LSHIFT B_RSHIFT B_XOR
%token ASSIGN_ADD ASSIGN_SUB ASSIGN_DIV ASSIGN_MUL ASSIGN_MOD
%token ASSIGN_B_LSHIFT ASSIGN_B_RSHIFT ASSIGN_B_AND ASSIGN_B_OR ASSIGN_B_XOR

%token ERR
%%
start           : header { printf("Program accepted\n"); YYACCEPT; }
                ;
header          : PRE_DIR header
                | main
                ;
main	        : PRO_BEG left_brac_s right_brac_s left_brac_c compound_statement right_brac_c 
                ;
left_brac_s     : '('
                | error { yyerror("Missing (\n");}
    		    ;
right_brac_s    : ')'
                | error { yyerror("Missing )\n");}
    		    ;
left_brac_c     : '{'   { ++scope; }
                | error { yyerror("Missing {\n");}
    		    ;
right_brac_c    : '}'   { SYM_TAB_DEL(scope); --scope; }
                | error { yyerror("Missing }\n");}
    		    ;

compound_statement  : statement compound_statement 
                    | statement
                    ;

statement           : expression semi
                    | declaration semi
                    | list_var semi
                    | if_statement
                    | loop_statement
                    | jump_statement semi
                    | switch_statement
                    ;


datatype                : TYPE_SPEC                                     { TYPE_SPEC_SAVE($1); }
declaration             : datatype list_var_declaration
                        ;

list_var_declaration    : IDENT                                         { SYM_TAB_DECL(scope, $1, type_spec_buffer, 0, line_number); yyerror("Invalid\n");}
                        | IDENT '=' expression                          { SYM_TAB_DECL(scope, $1, type_spec_buffer, 1, line_number); }
                        | IDENT ',' list_var_declaration                { SYM_TAB_DECL(scope, $1, type_spec_buffer, 0, line_number); }
                        | IDENT '=' expression ',' list_var_declaration { SYM_TAB_DECL(scope, $1, type_spec_buffer, 1, line_number); }
                        ;

list_var                : IDENT                                 { SYM_TAB_ADD(scope, $1, line_number); }
                        | IDENT '=' expression                  { SYM_TAB_ADD(scope, $1, line_number); }
                        | IDENT ',' list_var                    { SYM_TAB_ADD(scope, $1, line_number); }
                        | IDENT '=' expression ',' list_var     { SYM_TAB_ADD(scope, $1, line_number); }
                        ;

if_header               : IF left_brac_s expression right_brac_s { ++scope; }

if_statement            : if_header '{' compound_statement '}' { SYM_TAB_DEL(scope); --scope; }
                        | if_header statement { SYM_TAB_DEL(scope); --scope; }
                        ;

while_header            : WHILE left_brac_s expression right_brac_s { ++scope; }

loop_statement          : while_header '{' compound_statement '}' { SYM_TAB_DEL(scope); --scope; }
                        | while_header statement { SYM_TAB_DEL(scope); --scope;}
                        ;

jump_statement          :   BREAK
                        |   CONTINUE 
                        |   RETURN expression
                        ;

switch_statement        : SWITCH left_brac_s IDENT right_brac_s left_brac_c cases right_brac_c
                        | SWITCH left_brac_s IDENT right_brac_s left_brac_c cases default right_brac_c
                        ;

cases                   : CASE INT_CONS ':' compound_statement
                        | cases CASE INT_CONS ':' compound_statement
                        ;
                    
default                 : DEFAULT ':' expression semi BREAK semi;
                        ;

value               :   INT_CONS 
                    |   FLOAT_CONS 
                    |   STRING_CONS
                    |   CHAR_CONS
                    ;

expression              :   rel_expression
                        |   bin_expression
                        |   logic_expression
                        |   arith_expression
                        |   value
                        |   IDENT   { SYM_TAB_ADD(scope, $1, line_number); }
                        ;

rel_expression          :   expression LT expression
                        |   expression GT expression
                        |   expression LE expression
                        |   expression GE expression
                        |   expression EQ expression
                        |   expression NE expression
                        ;

arith_expression        :   expression '+' expression
                        |   expression '-' expression
                        |   expression '*' expression
                        |   expression '/' expression       
                        |   expression '%' expression
                        ;

bin_expression          :   B_NOT expression
                        |   expression B_XOR expression
                        |   expression B_AND expression
                        |   expression B_OR expression
                        |   expression B_LSHIFT expression
                        |   expression B_RSHIFT expression
                        ;

logic_expression        :   NOT expression
                        |   expression AND expression
                        |   expression OR expression


semi                :   ';'
                    |   error { yyerror("Missing semicolon");}
                    ;
%%

void yyerror(char *string) {
	printf("Error occured (%d): %s\n", line_number, string);
}

int main() {
    yyin = fopen("input_file.cpp","r");
    f_tokens = fopen("tokens.txt","w");
    symbol_table_fp = fopen("symbol_table.txt", "w");

    yyparse();

    fclose(f_tokens);
    return 0;
}

