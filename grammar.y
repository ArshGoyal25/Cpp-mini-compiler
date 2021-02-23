%{
#include<stdio.h>
#include"lex.yy.c"
int yylex();
void yyerror(char *s);
%}
%union {
    int ival;
    float fval;
    char *sval;
}

%left ','
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
%token <sval> ID
%token <ival> INT_CONS
%token <fval> FLOAT_CONS
%token <sval> STRING_CONS CHAR_CONS BOOL_CONS HEADER

%token TYPE_SPEC PRO_BEG

%token IF BREAK CONTINUE RETURN COUT INCLUDE
%token WHILE SWITCH CASE DEFAULT

%token LT GT LE GE EQ NE
%token AND OR NOT
%token B_AND B_OR B_NOT B_LSHIFT B_RSHIFT B_XOR

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
                | error { yyerror("Missing left bracet s\n");}
    		    ;
right_brac_s    : ')'
                | error { yyerror("Missing right bracet s\n");}
    		    ;
left_brac_c     : '{'
                | error { yyerror("Missing left bracet c\n");}
    		    ;
right_brac_c    : '}'
                | error { yyerror("Missing right bracet c\n");}
    		    ;

compound_statement  : statement compound_statement 
                    | statement
                    ;

statement           : expression_statement
                    | if_statement
                    | loop_statement
                    | jump_statement semi
                    | switch_statement
                    ;

expression_statement    : expression semi
                        ;

expression              : TYPE_SPEC declaration
                        | ID '=' arit_expression
                        | rel_expression
                        | arit_expression
                        | print
                        ;
declaration             : list_var
                        | ID '=' arit_expression
                        | ID '=' arit_expression declaration
                        ;
list_var                : ID | list_var ',' ID 
                        ;

if_statement            : IF left_brac_s expression right_brac_s left_brac_c compound_statement right_brac_c
                        ;

loop_statement          : WHILE left_brac_s rel_expression right_brac_s left_brac_c compound_statement right_brac_c
                        ;

jump_statement          :   BREAK
                        |   CONTINUE 
                        |   RETURN expression
                        ;

switch_statement        : SWITCH left_brac_s ID right_brac_s left_brac_c cases right_brac_c
                        | SWITCH left_brac_s ID right_brac_s left_brac_c cases default right_brac_c
                        ;

cases                   : CASE INT_CONS ':' expression semi BREAK semi
                        | cases CASE INT_CONS ':' expression semi BREAK semi
                        ;
                    
default                 : DEFAULT ':' expression semi BREAK semi;
                        ;

rel_expression          :   arit_expression LT arit_expression
                        |   arit_expression GT arit_expression
                        |   arit_expression LE arit_expression
                        |   arit_expression GE arit_expression
                        |   arit_expression EQ arit_expression 
                        |   arit_expression NE arit_expression 
                        ;

arit_expression         : value
                        | value '+' arit_expression
                        | value '-' arit_expression
                        | value '*' arit_expression
                        | value '/' arit_expression       
                        | value '%' arit_expression                 
                        ;

value               :   ID {printf("%s ,line : %d \n", $1, line_number);}
                    |   INT_CONS 
                    |   FLOAT_CONS 
                    |   STRING_CONS
                    |   CHAR_CONS
                    ;

print               : COUT B_LSHIFT arit_expression

semi                :   ';'
                    |   error { yyerror("Missing semicolon");}
                    ;
%%

void yyerror(char *string)
{
	printf("At line no : %d\nError occured : %s\n",line_number,string);
}
int main()
{
    yyin = fopen("input_file.cpp","r");
    f_tokens = fopen("tokens.txt","w");

    yyparse();

    fclose(f_tokens);
    return 0;
}

