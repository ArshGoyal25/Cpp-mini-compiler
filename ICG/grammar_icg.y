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


#define VALIDATE_IDENT_LEN(identifier)                                          \
        strcpy(identifier_buffer, identifier);                                  \
        if(strlen(identifier_buffer) > 31) {                                    \
            sprintf(err_mes, "Identifier length too long: %s", identifier);     \
            yyerror(err_mes);                                                   \
            identifier_buffer[31] = 0;                                          \
            sprintf(err_mes, "Identifier changed to : %s", identifier_buffer); \
            yyerror(err_mes);                                                  \
        }

#define PRINT_TYPE_ERROR(value,expected,actual)                                                 \
    sprintf(err1, "Implicit Type-Casting done.");                                               \
    sprintf(err_mes, "Invalid Type for %s. Expected %s, got %s." , identifier_buffer,expected,actual);  \
    yyerror(err_mes);                                                                           \
    sprintf(err_mes, "%s New Value for %s : %s",err1,identifier_buffer,value);                  \
    yyerror(err_mes);                                                                           


#define CHECK_TYPE(type_spec, value, flag)                                                              \
        if(strcmp(type_spec,"int") == 0){                                                               \
            switch(type){                                                                               \
                case 1 :  sprintf(value,"%d", value[1]);                                                \
                        PRINT_TYPE_ERROR(value,"INT","CHAR") break ;                                    \
                case 2 :  break;                                                                        \
                case 3 :  sprintf(value,"%d",atoi(value));                                              \
                        PRINT_TYPE_ERROR(value,"INT","FLOAT") break ;                                   \
                case 4 :  if (strcmp(value,"true") == 0 || strcmp(value,"TRUE") == 0)                   \
                                sprintf(value,"%d",1);                                                  \
                          else                                                                          \
                                sprintf(value,"%d",0);                                                  \
                        PRINT_TYPE_ERROR(value,"INT","CHAR") break ;                                    \
                case 5 :  sprintf(err1, "expected int,  got Type string"); flag =1 ; break;             \
            }                                                                                           \
        }                                                                                               \
        else if(strcmp(type_spec,"float") == 0 || strcmp(type_spec,"double") == 0){                     \
            switch(type){                                                                               \
                case 1 :  sprintf(value,"%d", value[1]);                                                \
                        PRINT_TYPE_ERROR(value,"FLOAT","CHAR") break ;                                  \
                case 2 :  break;                                                                        \
                case 3 :  break;                                                                        \
                case 4 :  if (strcmp(value,"true") == 0 || strcmp(value,"TRUE") == 0)                   \
                                sprintf(value,"%d",1);                                                  \
                          else                                                                          \
                                sprintf(value,"%d",0);                                                  \
                        PRINT_TYPE_ERROR(value,"FLOAT","BOOL") break ;                                  \
                case 5 :  sprintf(err1, "expected float,  got Type string"); flag =1 ; break;           \
            }                                                                                           \
        }                                                                                               \
        else if(strcmp(type_spec,"char") == 0){                                                         \
            switch(type){                                                                               \
                case 1 :  sprintf(value,"%c",value[1]) ;break;                                          \
                case 2 :  sprintf(value,"%c",atoi(value));                                              \
                        PRINT_TYPE_ERROR(value,"CHAR","INT") break ;                                    \
                case 3 :  sprintf(value,"%c",atoi(value));                                              \
                        PRINT_TYPE_ERROR(value,"CHAR","FLOAT") break ;                                  \
                case 4 :  if (strcmp(value,"true") == 0 || strcmp(value,"TRUE") == 0)                   \
                                sprintf(value,"%d",1);                                                  \
                          else                                                                          \
                                sprintf(value,"%d",0);                                                  \
                        PRINT_TYPE_ERROR(value,"CHAR","BOOL") break ;                                   \
                case 5 :  sprintf(err1, "expected char,  got Type string"); flag =1 ; break;            \
            }                                                                                           \
        }                                                                                               \
        else if(strcmp(type_spec,"bool") == 0){                                                         \
            if(type == 5){                                                                              \
                sprintf(err1, "expected char,  got Type string"); flag =1 ;                             \
            }                                                                                           \
            else if (type == 1 || type ==2 || type == 3){                                               \
                if (atoi(value) == 0){                                                                  \
                    strcpy(value,"Fal");                                                                \
                }                                                                                       \
                else{                                                                                   \
                    strcpy(value,"True");                                                               \
                }                                                                                       \
            }                                                                                           \
            PRINT_TYPE_ERROR(value,"BOOL","VALUE") break ;                                              \
        }                                                                                               \
        type = 0;                                                                     


#define SYM_TAB_DECL(scope, name, type_spec, is_initialized, value, line_number)                                                    \
        VALIDATE_IDENT_LEN(name);                                                                                                   \
        int flag = 0;                                                                                                               \
        int err = 0;                                                                                                                \
        CHECK_TYPE(type_spec,value,flag);                                                                                           \
        if(flag){                                                                                                                   \
            sprintf(err_mes, "Invalid Type for %s,  %s" , identifier_buffer,err1);                                                  \
            yyerror(err_mes);                                                                                                       \
        }                                                                                                                           \
        else {                                                                                                                      \
            err = create_declaration_entry(scope, identifier_buffer, type_spec, storage, is_initialized, value, line_number);       \
        }                                                                                                                           \
        if(err) {                                                                                                                   \
            sprintf(err_mes, "%s already declared in line %d", identifier_buffer, err);                                             \
            yyerror(err_mes);                                                                                                       \
        }

#define SYM_TAB_ADD(scope, name, value, line_number)                                                                                \
        int flag = 0;                                                                                                               \
        int err = 0;                                                                                                                \
        char *type_spec = (char*)malloc(20);                                                                                        \
        strcpy(type_spec,find_var_type(scope, name, line_number));                                                                  \
        if(strcmp(type_spec,"None") == 0) {                                                                                         \
            sprintf(err_mes, "No declaration found for %s", name);                                                                  \
            yyerror(err_mes);                                                                                                       \
        }                                                                                                                           \
        else {                                                                                                                      \
            CHECK_TYPE(type_spec,value,flag);                                                                                       \
            if(flag){                                                                                                               \
                sprintf(err_mes, "Invalid Type for %s,  %s" , identifier_buffer,err1);                                              \
                yyerror(err_mes);                                                                                                   \
            }                                                                                                                       \
            else                                                                                                                    \
                err = create_mention_entry(scope, name, value, line_number);                                                        \
            if(err) {                                                                                                               \
                sprintf(err_mes, "No declaration found for %s", name);                                                              \
                yyerror(err_mes);                                                                                                   \
            }                                                                                                                       \
        }

#define TYPE_SPEC_SAVE(type_spec) strcpy(type_spec_buffer, type_spec);
#define SYM_TAB_DEL(scope) remove_symbol_table_entry(symbol_table_fp, scope);
#define CHECK_LOOP(loop,name)                                               \
    if(loop == 0){                                                          \
            sprintf(err_mes, "%s Statment Outside Loop",name);              \
            yyerror(err_mes);                                               \
    }

char* GET_VALUE(int scope,char* name);
float find_val(char* name);
int find_val_int(char* name);
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

list_var_declaration:   ident                                         { push_onto_icg_stack("None"); assign_icg();}
    |                   ident '=' expression                          { assign_icg();}
    |                   ident ',' list_var_declaration                { push_onto_icg_stack("None"); assign_icg();}
    |                   ident '=' expression                          { assign_icg();}           ',' list_var_declaration
    ;

ident:                  IDENT                                         { push_onto_icg_stack($1);}
    ;
list_var:               ident '=' expression                         { assign_icg();}
    |                   ident ',' list_var                           { assign_icg();}
    |                   ident '=' expression                         { assign_icg();}              ',' list_var
    ;

if_header:              IF left_brac_s expression right_brac_s      { ++scope; }
    ;

if_statement:           if_header '{' compound_statement '}'  %prec IFX              { --scope; }
    |                   if_header '{' compound_statement '}' else_statement          
    |                   if_header statement %prec IFX                                { --scope; }
    |                   if_header statement else_statement                           
    ;

else_header:            ELSE                                            { --scope; ++scope; }
    ;

else_statement:         else_header statement                           {--scope; }
    |                   else_header '{' compound_statement '}'          {--scope; }
    ;

while_header:           WHILE left_brac_s expression right_brac_s       { ++scope; ++loop ; }
    ;

loop_statement:         while_header '{' compound_statement '}'         {--scope; --loop;}
    |                   while_header statement                          {--scope; --loop;}
    ;

jump_statement:         BREAK                                  
    |                   CONTINUE                               
    |                   RETURN expression
    ;

switch_header:           SWITCH left_brac_s IDENT right_brac_s                     { ++loop ;}
    ;

switch_statement:       switch_header left_brac_c cases right_brac_c              { --loop ;}
    |                   switch_header left_brac_c cases default right_brac_c      { --loop ;}
    ;

cases:                  CASE INT_CONS ':' compound_statement
    |                   cases CASE INT_CONS ':' compound_statement
    ;
                    
default:                DEFAULT ':' expression semi BREAK semi;
    ;


value:                  CHAR_CONS           {sprintf(var,"%s", $1); $$ = var; type=1; push_onto_icg_stack(var); }
    |                   INT_CONS            {sprintf(var,"%d", $1); $$ = var; type=2; push_onto_icg_stack(var); }
    |                   FLOAT_CONS          {sprintf(var,"%f", $1); $$ = var; type=3; push_onto_icg_stack(var); }
    |                   BOOL_CONS           {sprintf(var,"%s", $1); $$ = var; type=4; push_onto_icg_stack(var); } 
    |                   STRING_CONS         {sprintf(var,"%s", $1); $$ = var; type=5; push_onto_icg_stack(var); } 
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

logic_expression:       NOT expression
    |                   expression AND expression
    |                   expression OR expression
    ;

inc_dec_expression:     INCREMENT IDENT                               { float temp = find_val($2) ; temp +=1 ; char res[20];  sprintf(res,"%f", temp); }
    |                   DECREMENT IDENT                               { float temp = find_val($2) ; temp -=1 ; char res[20];  sprintf(res,"%f", temp); }
    |                   IDENT INCREMENT                               { float temp = find_val($1) ; temp +=1 ; char res[20];  sprintf(res,"%f", temp); }
    |                   IDENT DECREMENT                               { float temp = find_val($1) ; temp -=1 ; char res[20];  sprintf(res,"%f", temp); }
    ;

semi:                   ';'
    |                   error { yyerror("Missing semicolon");}
    ;
%%

void yyerror(char *string) {
	printf("Error occured \t Line:(%2d) Col:(%d) \t: %s\n", line_number, --col_number, string);
}


int main() {
    yyin = fopen("input_file.cpp","r");
    f_tokens = fopen("tokens.txt","w");
    f_icg = fopen("icg.txt","w");

    yyparse();

    f_quad = fopen("quad.txt","w");
    write_quad(f_quad);
    fclose(f_quad);

    fclose(f_tokens);
    return 0;
}


char* GET_VALUE(int scope,char* name){
        char * ans = (char*)(malloc(sizeof(char)*20)); 
        strcpy(ans,"None");
        //get_ident_value(scope,name,ans);
        //printf("%s\n",ans);                                          
        return ans;
}

float find_val(char* name){
    float ans;
    if (strcmp(GET_VALUE(scope,name),"None") == 0) 
        ans = atof(name) ;
    else 
        ans =  atof(GET_VALUE(scope,name));
    return ans;
}

int find_val_int(char* name){
    int ans;
    if (strcmp(GET_VALUE(scope,name),"None") == 0) 
        ans = atoi(name) ;
    else 
        ans =  atoi(GET_VALUE(scope,name));
    return ans;
}
///////////////////////////////////////
