%{
#include<stdio.h>
#include<string.h>
#include"lex.yy.c"
#include "symbol_table.h"
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
            sprintf(err_mes, "Identifier changed to : %s", identifier_buffer);  \
            yyerror(err_mes);                                                   \
        }

#define PRINT_TYPE_ERROR(value,expected,actual)                                                         \
    sprintf(err1, "Implicit Type-Casting done.");                                                       \
    sprintf(err_mes, "Invalid Type for %s. Expected %s, got %s." , identifier_buffer,expected,actual);  \
    yyerror(err_mes);                                                                                   \
    sprintf(err_mes, "%s New Value for %s : %s",err1,identifier_buffer,value);                          \
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


%type <sval> value expression rel_expression bin_expression logic_expression arith_expression inc_dec_expression
%%
start:              header {printf("Program accepted\n"); }
    ;
header:             PRE_DIR header
    |               main    {printf("End of Main Function\n"); }
    ;
main:               PRO_BEG left_brac_s right_brac_s left_brac_c compound_statement right_brac_c 
    ;
left_brac_s:        '('
    |               error { yyerror("Missing (\n");}
    ;
right_brac_s:       ')'
    |               error { yyerror("Missing )\n");}
    ;		    
left_brac_c:        '{'   { ++scope; }
    ;
right_brac_c:       '}'   { SYM_TAB_DEL(scope); --scope; }
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
    |               error {yyerror("Invalid statement") ;}
    ;

datatype:          TYPE_SPEC                                             { TYPE_SPEC_SAVE($1); }
    ;
declaration:         datatype list_var_declaration
    |                datatype array_declaration
    ;

array_declaration:   IDENT '[' ']' '=' '{' list_value '}'                    { sprintf(var, "%s array", type_spec_buffer);  SYM_TAB_DECL(scope, $1, var, 1, "None", line_number); }
    |                IDENT '[' expression ']'                                { sprintf(var, "%s array", type_spec_buffer);  SYM_TAB_DECL(scope, $1, var, 0, "None", line_number); }
    |                IDENT '['expression ']' '=' '{' list_value '}'          { sprintf(var, "%s array", type_spec_buffer);  SYM_TAB_DECL(scope, $1, var, 1, "None", line_number); }
    ;

list_value:             value ',' list_value
    |                   value
    ;          

list_var_declaration:   IDENT                                         { SYM_TAB_DECL(scope, $1, type_spec_buffer, 0, "None", line_number); }
    |                   IDENT '=' expression                          { SYM_TAB_DECL(scope, $1, type_spec_buffer, 1, $3 , line_number);}
    |                   IDENT ',' list_var_declaration                { SYM_TAB_DECL(scope, $1, type_spec_buffer, 0, "None" ,line_number); }
    |                   IDENT '=' expression                          { SYM_TAB_DECL(scope, $1, type_spec_buffer, 1, $3 , line_number);}           ',' list_var_declaration
    ;

list_var:               IDENT '=' expression                         { SYM_TAB_ADD(scope, $1, $3, line_number);}
    |                   IDENT ',' list_var                           { SYM_TAB_ADD(scope, $1, GET_VALUE(scope,$1) ,line_number); }
    |                   IDENT '=' expression                         { SYM_TAB_ADD(scope, $1, $3, line_number);}              ',' list_var
    ;

if_header:              IF left_brac_s expression right_brac_s      { ++scope; }
    ;

if_statement:           if_header '{' compound_statement '}'  %prec IFX              { SYM_TAB_DEL(scope); --scope; }
    |                   if_header '{' compound_statement '}' else_statement          
    |                   if_header statement %prec IFX                                { SYM_TAB_DEL(scope); --scope; }
    |                   if_header statement else_statement                           
    ;

else_header:            ELSE                                            { SYM_TAB_DEL(scope); --scope; ++scope; }
    ;

else_statement:         else_header statement                           { SYM_TAB_DEL(scope); --scope; }
    |                   else_header '{' compound_statement '}'          { SYM_TAB_DEL(scope); --scope; }
    ;

while_header:           WHILE left_brac_s expression right_brac_s       { ++scope; ++loop ; }
    ;

loop_statement:         while_header '{' compound_statement '}'         { SYM_TAB_DEL(scope); --scope; --loop;}
    |                   while_header statement                          { SYM_TAB_DEL(scope); --scope; --loop;}
    ;

jump_statement:         BREAK                                           {CHECK_LOOP(loop,"Break"); }
    |                   CONTINUE                                        {CHECK_LOOP(loop,"Continue"); }
    |                   RETURN expression
    ;

switch_header:           SWITCH left_brac_s IDENT right_brac_s                     { ++loop ; SYM_TAB_ADD(scope, $3, GET_VALUE(scope,$3), line_number);}
    ;

switch_statement:       switch_header left_brac_c cases right_brac_c              { --loop ;}
    |                   switch_header left_brac_c cases default right_brac_c      { --loop ;}
    ;

cases:                  CASE INT_CONS ':' compound_statement
    |                   cases CASE INT_CONS ':' compound_statement
    ;
                    
default:                DEFAULT ':' compound_statement
    ;


value:                  CHAR_CONS           {sprintf(var,"%s", $1); $$ = var; type=1;}
    |                   INT_CONS            {sprintf(var,"%d", $1); $$ = var; type=2;}
    |                   FLOAT_CONS          {sprintf(var,"%f", $1); $$ = var; type=3;}
    |                   BOOL_CONS           {sprintf(var,"%s", $1); $$ = var; type=4;} 
    |                   STRING_CONS         {sprintf(var,"%s", $1); $$ = var; type=5;}
    ;

expression:             rel_expression
    |                   bin_expression
    |                   logic_expression
    |                   arith_expression                    
    |                   inc_dec_expression          
    |                   value                               
    |                   IDENT                                    {SYM_TAB_ADD(scope, $1, GET_VALUE(scope,$1), line_number); }                             
    ;

rel_expression:         expression LT expression                {int temp ; if (find_val($1) < find_val($3)) temp = 1; else temp = 0; sprintf($$,"%d", temp);}                 
    |                   expression GT expression                {int temp ; if (find_val($1) > find_val($3)) temp = 1; else temp = 0; sprintf($$,"%d", temp);}
    |                   expression LE expression                {int temp ; if (find_val($1) <= find_val($3)) temp = 1; else temp = 0; sprintf($$,"%d", temp);}
    |                   expression GE expression                {int temp ; if (find_val($1) >= find_val($3)) temp = 1; else temp = 0; sprintf($$,"%d", temp);}
    |                   expression EQ expression                {int temp ; if (find_val($1) == find_val($3)) temp = 1; else temp = 0; sprintf($$,"%d", temp);}
    |                   expression NE expression                {int temp ; if (find_val($1) != find_val($3)) temp = 1; else temp = 0; sprintf($$,"%d", temp);}
    ;

arith_expression:       expression '+' expression               {float temp = find_val($1) + find_val($3)  ;  sprintf($$,"%f", temp); }     
    |                   expression '-' expression               {float temp = find_val($1) - find_val($3)  ;  sprintf($$,"%f", temp); } 
    |                   expression '/' expression               {float temp = find_val($1) / find_val($3)  ;  sprintf($$,"%f", temp); } 
    |                   expression '*' expression               {float temp = find_val($1) * find_val($3)  ;  sprintf($$,"%f", temp); } 
    |                   expression '%' expression               {int temp = find_val_int($1) % find_val_int($3)  ;  sprintf($$,"%d", temp); } 
    ;

bin_expression:         B_NOT expression                        {float temp = !find_val($2)  ;  sprintf($$,"%f", temp); }
    |                   expression B_XOR expression             {int temp = find_val_int($1) ^ find_val_int($3)  ;  sprintf($$,"%d", temp); }
    |                   expression B_AND expression             {int temp = find_val_int($1) & find_val_int($3)  ;  sprintf($$,"%d", temp); }
    |                   expression B_OR expression              {int temp = find_val_int($1) | find_val_int($3)  ;  sprintf($$,"%d", temp); }
    |                   expression B_LSHIFT expression          {int temp = find_val_int($1) << find_val_int($3)  ;  sprintf($$,"%d", temp); }
    |                   expression B_RSHIFT expression          {int temp = find_val_int($1) >> find_val_int($3)  ;  sprintf($$,"%d", temp); }
    ;

logic_expression:       NOT expression                          {int temp = !find_val_int($2)  ;  sprintf($$,"%d", temp); }
    |                   expression AND expression               {int temp = find_val_int($1) && find_val_int($3)  ;  sprintf($$,"%d", temp); }         
    |                   expression OR expression                {int temp = find_val_int($1) || find_val_int($3)  ;  sprintf($$,"%d", temp); } 
    ;

inc_dec_expression:     INCREMENT IDENT                               { float temp = find_val($2) ; temp +=1 ; char res[20];  sprintf(res,"%f", temp); SYM_TAB_ADD(scope, $2, res, line_number);$$ = res;}
    |                   DECREMENT IDENT                               { float temp = find_val($2) ; temp -=1 ; char res[20];  sprintf(res,"%f", temp); SYM_TAB_ADD(scope, $2, res, line_number);$$ = res;}
    |                   IDENT INCREMENT                               { float temp = find_val($1) ; temp +=1 ; char res[20];  sprintf(res,"%f", temp); SYM_TAB_ADD(scope, $1, res, line_number);$$ = res;}
    |                   IDENT DECREMENT                               { float temp = find_val($1) ; temp -=1 ; char res[20];  sprintf(res,"%f", temp); SYM_TAB_ADD(scope, $1, res, line_number);$$ = res;}
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
    symbol_table_fp = fopen("symbol_table.txt", "w");

    yyparse();

    fclose(f_tokens);
    return 0;
}


char* GET_VALUE(int scope,char* name){
        char * ans = (char*)(malloc(sizeof(char)*20)); 
        strcpy(ans,"None");
        get_ident_value(scope,name,ans);
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