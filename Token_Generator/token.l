%{
#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include "y.tab.h"

extern YYSTYPE yylval;

char err_mes[200];
char err_mes1[50];
int line_number = 1;
int col_number = 1;
int line_of_declaration = 0;
int scope = 0;
int loop = 0;
int block = 0;
int inter_var_no = 0;
int storage;
#define report_token(type, lexeme, line_number,col_number) 									\
	fprintf(f_tokens, "<%s, '%s', %d, %d >\n", type, lexeme, line_number,col_number);		\
	col_number ++;
void yyerror(char *);
FILE *f_tokens;
FILE* symbol_table_fp;
FILE* symbol_table_one_fp;

%}

digit       		[0-9]
letter      		[a-zA-Z_]
id          		{letter}({letter}|{digit})*
header				[<]({letter})+[.][h][>]
digits      		{digit}+
opFraction  		(\.{digits})?
opExponent  		([Ee][+-]?{digits})?
number      		{digits}{opFraction}{opExponent}
preprocess 			#(define|include<.+>)
special				[!@#$^&.:;_]

%%

	/* comments and white spaces */
([ ]*|(\n\t)*|(\n)*|(\t)*)*\/\/.* { line_number++;}
([ ]*|(\n\t)*|(\n)*|(\t)*)*\/\*(.*\n)*.*\*\/  { line_number++;}

int[ ]main 			{ report_token("KEYW", "int", line_number,col_number); report_token("KEYW", "main", line_number,col_number); return PRO_BEG;}


int					{yylval.sval = strdup(yytext); report_token("KEYW", yytext, line_number, col_number); storage = 2 ;return TYPE_SPEC;}
char				{yylval.sval = strdup(yytext); report_token("KEYW", yytext, line_number, col_number); storage = 1 ;return TYPE_SPEC;}
float				{yylval.sval = strdup(yytext); report_token("KEYW", yytext, line_number, col_number); storage = 4 ;return TYPE_SPEC;}
double				{yylval.sval = strdup(yytext); report_token("KEYW", yytext, line_number, col_number); storage = 8 ;return TYPE_SPEC;}
void				{yylval.sval = strdup(yytext); report_token("KEYW", yytext, line_number, col_number); storage = 0 ;return TYPE_SPEC;}
bool			 	{yylval.sval = strdup(yytext); report_token("KEYW", yytext, line_number, col_number); storage = 1 ;return TYPE_SPEC;}
long[ ]+long 		{yylval.sval = strdup(yytext); report_token("KEYW", yytext, line_number, col_number); storage = 16 ;return TYPE_SPEC;}


	/* ___ PREPROCESS DIRECTIVE ___ */
{preprocess}			{ report_token("PREPROCESS", yytext, line_number, col_number);return PRE_DIR; }

	/* ___ KEYWORDS ___*/

if 					{ report_token("KEYW", yytext, line_number, col_number); return IF;}
else 				{ report_token("KEYW", yytext, line_number, col_number); return ELSE;}
break 				{ report_token("KEYW", yytext, line_number, col_number); return BREAK;}
continue			{ report_token("KEYW", yytext, line_number, col_number); return CONTINUE;}
while				{ report_token("KEYW", yytext, line_number, col_number); return WHILE;}
return				{ report_token("KEYW", yytext, line_number, col_number); return RETURN;}
switch				{ report_token("KEYW", yytext, line_number, col_number); return SWITCH;}
case				{ report_token("KEYW", yytext, line_number, col_number); return CASE;}
default				{ report_token("KEYW", yytext, line_number, col_number); return DEFAULT;}


	/* ___ ARITHMETIC AND ASSIGNMENT OPERATORS __ */
\+|\-|\*|\/|\%		{ report_token("ARITH_OP", yytext, line_number, col_number); return yytext[0];}
\= 					{ report_token("ASSIGNMENT_OP", yytext, line_number, col_number); return yytext[0];}
\+\=				{ report_token("ASSIGNMENT_OP", yytext, line_number, col_number); return ASSIGN_ADD;}
\-\=				{ report_token("ASSIGNMENT_OP", yytext, line_number, col_number); return ASSIGN_SUB;}
\/\=				{ report_token("ASSIGNMENT_OP", yytext, line_number, col_number); return ASSIGN_DIV;}
\*\=				{ report_token("ASSIGNMENT_OP", yytext, line_number, col_number); return ASSIGN_MUL;}
\%\=				{ report_token("ASSIGNMENT_OP", yytext, line_number, col_number); return ASSIGN_MOD;}
\<\<\=				{ report_token("ASSIGNMENT_OP", yytext, line_number, col_number); return ASSIGN_B_LSHIFT;}
\>\>\=				{ report_token("ASSIGNMENT_OP", yytext, line_number, col_number); return ASSIGN_B_RSHIFT;}
\&\=				{ report_token("ASSIGNMENT_OP", yytext, line_number, col_number); return ASSIGN_B_AND;}
\|\=				{ report_token("ASSIGNMENT_OP", yytext, line_number, col_number); return ASSIGN_B_OR;}
\^\=				{ report_token("ASSIGNMENT_OP", yytext, line_number, col_number); return ASSIGN_B_XOR;}

	/* ___ INCREMENT AND DECREMENT OPERATORS __ */
\+\+				{ report_token("INCREMENT_OP", yytext, line_number, col_number); return INCREMENT;}
\-\-				{ report_token("DECREMENT_OP", yytext, line_number, col_number); return DECREMENT;}

	/* ___ RELATIONAL OPERATORS ___ */
\< 					{ report_token("REL_OP", yytext, line_number, col_number); return LT;}
\> 					{ report_token("REL_OP", yytext, line_number, col_number); return GT;}
\<\= 				{ report_token("REL_OP", yytext, line_number, col_number); return LE;}
\>\= 				{ report_token("REL_OP", yytext, line_number, col_number); return GE;}
\=\= 				{ report_token("REL_OP", yytext, line_number, col_number); return EQ;}
\!\= 				{ report_token("REL_OP", yytext, line_number, col_number); return NE;}	

	/* ___ LOGICAL OPERATORS __ */
\&\& 				{ report_token("LOG_OP", yytext, line_number, col_number); return AND;}
\|\| 				{ report_token("LOG_OP", yytext, line_number, col_number); return OR;}
\!	 				{ report_token("LOG_OP", yytext, line_number, col_number); return NOT;}

	/* ___ BINARY OPERATORS __ */
\^					{ report_token("BIN_OP", yytext, line_number, col_number); return B_XOR; }
\~					{ report_token("BIN_OP", yytext, line_number, col_number); return B_NOT; }
\&					{ report_token("BIN_OP", yytext, line_number, col_number); return B_AND; }
\|					{ report_token("BIN_OP", yytext, line_number, col_number); return B_OR; }
\<\<				{ report_token("BIN_OP", yytext, line_number, col_number); return B_LSHIFT; }
\>\>				{ report_token("BIN_OP", yytext, line_number, col_number); return B_RSHIFT; }

\(|\[|\{			{ report_token("SEP", yytext, line_number, col_number); return yytext[0];}
\)|\]|\}			{ report_token("SEP", yytext, line_number, col_number); return yytext[0];}
\;|\,|\:			{ report_token("SEP", yytext, line_number, col_number); return yytext[0];}


	/* ___ CONSTANTS ___ */
true|TRUE				{ yylval.sval=strdup(yytext); fprintf(f_tokens,"<CONS, 'BOOL', %s, %d, %d>\n",yytext,line_number, col_number); return BOOL_CONS;}
false|FALSE				{ yylval.sval=strdup(yytext); fprintf(f_tokens,"<CONS, 'BOOL', %s, %d, %d>\n",yytext,line_number, col_number); return BOOL_CONS;}
{digits}{id}			{ sprintf(err_mes, "Invalid String: %s", yytext); yyerror(err_mes);}
{id}            		{ yylval.sval=strdup(yytext); fprintf(f_tokens,"<ID, '%s', %d, %d, %d>\n",yytext,scope,line_number, col_number); return IDENT;}
{digits}        		{ yylval.ival=atoi(yytext); fprintf(f_tokens,"<CONS, 'INT', %d, %d, %d>\n",yylval.ival,line_number, col_number); return INT_CONS;}
{digits}{opFraction}	{ yylval.fval=atof(yytext); fprintf(f_tokens,"<CONS, 'FLOAT', %f, %d, %d>\n",yylval.fval,line_number, col_number); return FLOAT_CONS;}
\'.\' 					{ yylval.sval=strdup(yytext); fprintf(f_tokens,"<CONS, 'CHAR', %c, %d, %d>\n",yylval.sval[1],line_number, col_number); return CHAR_CONS;}
\".*\" 					{ yylval.sval=strdup(yytext); fprintf(f_tokens,"<CONS, 'STRING', %s, %d, %d>\n",yytext,line_number, col_number); return STRING_CONS;}
{header}				{ yylval.sval=strdup(yytext); fprintf(f_tokens,"<CONS, 'HEADER', %s, %d, %d>\n",yytext,line_number, col_number); return HEADER;}

{special}{letter}+		{yyerror("Improper string");printf("%s\n",yytext);} 


[\n] 					{ line_number++; col_number = 1;}
[ |\t] ;
.	              		{ yyerror("invalid") ;  }
%%

int yywrap()
{
	return 1;
}