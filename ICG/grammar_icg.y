%{
#include<stdio.h>
#include<string.h>
#include"lex.yy.c"
#include "icg.h"
#include "quad.h"
int yylex();
void yyerror(char *s);

char value[30];
char var[120] ;
char err_mes[200];
char err1[50];
char type_spec_buffer[100];
char identifier_buffer[100];
int type;

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

%nonassoc IFX
%nonassoc ELSE


%token PRE_DIR
%token <sval> IDENT
%token <ival> INT_CONS
%token <fval> FLOAT_CONS
%token <sval> STRING_CONS CHAR_CONS BOOL_CONS HEADER TYPE_SPEC

%token PRO_BEG

%token IF ELSE BREAK CONTINUE RETURN COUT INCLUDE
%token WHILE SWITCH CASE DEFAULT

%token LT GT LE GE EQ NE
%token <sval> AND OR NOT
%token <sval> B_AND B_OR B_NOT B_LSHIFT B_RSHIFT B_XOR
%token ASSIGN_ADD ASSIGN_SUB ASSIGN_DIV ASSIGN_MUL ASSIGN_MOD
%token ASSIGN_B_LSHIFT ASSIGN_B_RSHIFT ASSIGN_B_AND ASSIGN_B_OR ASSIGN_B_XOR
%token <sval> INCREMENT DECREMENT

%token ERR


%type <sval> value expression rel_expression bin_expression logic_expression arith_expression inc_dec_expression ident
%%
start:              header {printf("Program accepted\n"); }
    ;
header:             PRE_DIR header
    |               main    {printf("End of Main Function\n"); }
    ;
main:               PRO_BEG left_brac_s right_brac_s left_brac_c compound_statement right_brac_c 
    ;
left_brac_s:        '('
    ;
right_brac_s:       ')'
    ;		    
left_brac_c:        '{'   { ++scope; }
    ;
right_brac_c:       '}'   { --scope; }
    ;

compound_statement: statement compound_statement 
    |               statement
    ;

statement:          expression semi
    |               declaration semi
    |               list_var semi
    |               if_statement
    |               loop_statement
    |               jump_statement semi
    |               switch_statement
    ;

datatype:           TYPE_SPEC                                           
    ;
declaration:         datatype list_var_declaration
    |                datatype array_declaration
    ;

array_declaration:   IDENT '[' ']' '=' '{' list_value '}'                   
    |                IDENT '[' expression ']'                                
    |                IDENT '['expression ']' '=' '{' list_value '}'         
    ;

list_value:             value ',' list_value
    |                   value
    ;          

list_var_declaration:   ident                                         { push_onto_icg_stack("0"); assign_icg();}
    |                   ident '=' expression                          { assign_icg();}
    |                   ident ',' list_var_declaration                { push_onto_icg_stack("0"); assign_icg();}
    |                   ident '=' expression                          { assign_icg();}           ',' list_var_declaration
    ;

ident:                  IDENT                                         { push_onto_icg_stack($1);}
    ;
list_var:               ident '=' expression                         { assign_icg();}
    |                   ident ',' list_var                           { assign_icg();}
    |                   ident '=' expression                         { assign_icg();}              ',' list_var
    ;

if_header:              IF left_brac_s expression right_brac_s      { rel_expr(); ++scope; }
    ;

if_statement:           if_header '{' compound_statement '}'  %prec IFX              { if_branch_end(); --scope; }
    |                   if_header '{' compound_statement '}' else_statement          
    |                   if_header statement %prec IFX                                { if_branch_end(); --scope; }
    |                   if_header statement else_statement                           
    ;

else_header:            ELSE                                            { if_branch_end_with_else(); --scope; ++scope; }
    ;

else_statement:         else_header statement                           {if_branch_end(); --scope; }
    |                   else_header '{' compound_statement '}'          {if_branch_end(); --scope; }
    ;

while_header:           WHILE {create_branch();}    left_brac_s expression right_brac_s       { rel_expr(); ++scope; ++loop ; }
    ;

loop_statement:         while_header '{' compound_statement '}'         {while_branch_end(); --scope; --loop;}
    |                   while_header statement                          {while_branch_end(); --scope; --loop;}
    ;

jump_statement:         BREAK               {break_icg();}                     
    |                   CONTINUE                               
    |                   RETURN expression
    ;

switch_header:           SWITCH left_brac_s ident right_brac_s                     { switch_test(); ++loop ;}
    ;

switch_statement:       switch_header left_brac_c cases right_brac_c              { switch_case_end(); --loop ;}
    |                   switch_header left_brac_c cases default right_brac_c      { switch_case_end(); --loop ;}
    ;

cases:                  CASE INT_CONS ':'     {sprintf(var,"%d", $2); push_onto_icg_stack(var); switch_case();}      compound_statement         
    |                   cases CASE INT_CONS ':'     {sprintf(var,"%d", $3); push_onto_icg_stack(var); switch_case();}     compound_statement    
    ;
                    
default:                DEFAULT ':'   {push_onto_icg_stack("None"); switch_case();}  compound_statement       
    ;

value:                  CHAR_CONS           {sprintf(var,"%s", $1); $$ = var; push_onto_icg_stack(var); }
    |                   INT_CONS            {sprintf(var,"%d", $1); $$ = var; push_onto_icg_stack(var); }
    |                   FLOAT_CONS          {sprintf(var,"%f", $1); $$ = var; push_onto_icg_stack(var); }
    |                   BOOL_CONS           {sprintf(var,"%s", $1); $$ = var; push_onto_icg_stack(var); } 
    |                   STRING_CONS         {sprintf(var,"%s", $1); $$ = var; push_onto_icg_stack(var); } 
    ;

expression:             rel_expression
    |                   bin_expression
    |                   logic_expression
    |                   arith_expression                    
    |                   inc_dec_expression          
    |                   value                               
    |                   ident                                                            
    ;

rel_expression:         expression LT   {push_onto_icg_stack("<");}    expression                { rel_icg(); }                 
    |                   expression GT   {push_onto_icg_stack(">");}    expression                { rel_icg(); } 
    |                   expression LE   {push_onto_icg_stack("<=");}   expression                { rel_icg(); } 
    |                   expression GE   {push_onto_icg_stack(">=");}   expression                { rel_icg(); } 
    |                   expression EQ   {push_onto_icg_stack("==");}   expression                { rel_icg(); } 
    |                   expression NE   {push_onto_icg_stack("!=");}   expression                { rel_icg(); } 
    ;

arith_expression:       expression '+'  {push_onto_icg_stack("+");}     expression               { arit_icg(); }     
    |                   expression '-'  {push_onto_icg_stack("-");}     expression               { arit_icg(); } 
    |                   expression '/'  {push_onto_icg_stack("/");}     expression               { arit_icg(); } 
    |                   expression '*'  {push_onto_icg_stack("*");}     expression               { arit_icg(); } 
    |                   expression '%'  {push_onto_icg_stack("%");}     expression               { arit_icg(); } 
    ;

bin_expression:         B_NOT               {push_onto_icg_stack("%");}     expression              { bin_icg(); }
    |                   expression B_XOR    {push_onto_icg_stack("^");}     expression              { bin_icg(); }
    |                   expression B_AND    {push_onto_icg_stack("&");}     expression              { bin_icg(); }
    |                   expression B_OR     {push_onto_icg_stack("|");}     expression              { bin_icg(); }
    |                   expression B_LSHIFT {push_onto_icg_stack("<<");}    expression              { bin_icg(); }
    |                   expression B_RSHIFT {push_onto_icg_stack(">>");}    expression              { bin_icg(); }
    ;

logic_expression:       NOT                 {push_onto_icg_stack("&&");}    expression               { logic_icg(); }
    |                   expression AND      {push_onto_icg_stack("&&");}    expression               { logic_icg(); }
    |                   expression OR       {push_onto_icg_stack("!!");}    expression               { logic_icg(); }
    ;

inc_dec_expression:     INCREMENT ident                               { inc_icg(); }
    |                   DECREMENT ident                               { dec_icg(); }
    |                   ident INCREMENT                               { inc_icg(); }
    |                   ident DECREMENT                               { dec_icg(); }
    ;

semi:                   ';'
    |                   error { yyerror("Missing semicolon");}
    ;
%%

void yyerror(char *string) {
	printf("Error occured \t Line:(%2d) Col:(%d) \t: %s\n", line_number, --col_number, string);
}


int main() {
    yyin = fopen("../input_file.cpp","r");
    f_tokens = fopen("tokens.txt","w");
    f_icg = fopen("../icg.txt","w");

    yyparse();

    f_quad = fopen("../quad.txt","w");
    write_quad(f_quad);
    fclose(f_quad);

    fclose(f_tokens);
    return 0;
}
///////////////////////////////////////
