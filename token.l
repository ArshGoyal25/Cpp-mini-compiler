%{
#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include "y.tab.h"

extern YYSTYPE yylval;

int line_number = 1;
int line_of_declaration = 0;
int scope = 0;
#define report_token(type, lexeme, line_number) fprintf(f_tokens, "<%s, '%s', %d>\n", type, lexeme, line_number);

FILE *f_tokens;

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

%%

	/* comments and white spaces */
([ ]*|(\n\t)*|(\n)*|(\t)*)*\/\/.* 
([ ]*|(\n\t)*|(\n)*|(\t)*)*\/\*(.*\n)*.*\*\/ 

int[ ]main 			{ report_token("KEYW", "int", line_number); report_token("KEYW", "main", line_number); return PRO_BEG;}


int|char|float|void|double|long[ ]+long { report_token("KEYW", yytext, line_number); return TYPE_SPEC;}

	/* ___ PREPROCESS DIRECTIVE ___ */
{preprocess}			{ return PRE_DIR; }

	/* ___ KEYWORDS ___*/

if 					{  return IF;}
break 				{ report_token("KEYW", yytext, line_number); return BREAK;}
continue			{ report_token("KEYW", yytext, line_number); return CONTINUE;}
while				{ report_token("KEYW", yytext, line_number); return WHILE;}
return				{ report_token("KEYW", yytext, line_number); return RETURN;}
switch				{ report_token("KEYW", yytext, line_number); return SWITCH;}
case				{ report_token("KEYW", yytext, line_number); return CASE;}
default				{ report_token("KEYW", yytext, line_number); return DEFAULT;}


	/* ___ ARITHMETIC AND ASSIGNMENT OPERATORS __ */
\+|\-|\*|\/|\%		{ report_token("ARITH_OP", yytext, line_number); return yytext[0];}
\= 					{ report_token("ASSIGNMENT_OP", yytext, line_number); return yytext[0];}
\+\=				{ report_token("ASSIGNMENT_OP", yytext, line_number); return ASSIGN_ADD;}
\-\=				{ report_token("ASSIGNMENT_OP", yytext, line_number); return ASSIGN_SUB;}
\/\=				{ report_token("ASSIGNMENT_OP", yytext, line_number); return ASSIGN_DIV;}
\*\=				{ report_token("ASSIGNMENT_OP", yytext, line_number); return ASSIGN_MUL;}
\%\=				{ report_token("ASSIGNMENT_OP", yytext, line_number); return ASSIGN_MOD;}
\<\<\=				{ report_token("ASSIGNMENT_OP", yytext, line_number); return ASSIGN_B_LSHIFT;}
\>\>\=				{ report_token("ASSIGNMENT_OP", yytext, line_number); return ASSIGN_B_RSHIFT;}
\&\=				{ report_token("ASSIGNMENT_OP", yytext, line_number); return ASSIGN_B_AND;}
\|\=				{ report_token("ASSIGNMENT_OP", yytext, line_number); return ASSIGN_B_OR;}
\^\=				{ report_token("ASSIGNMENT_OP", yytext, line_number); return ASSIGN_B_XOR;}


	/* ___ RELATIONAL OPERATORS ___ */
\< 					{ report_token("REL_OP", yytext, line_number); return LT;}
\> 					{ report_token("REL_OP", yytext, line_number); return GT;}
\<\= 				{ report_token("REL_OP", yytext, line_number); return LE;}
\>\= 				{ report_token("REL_OP", yytext, line_number); return GE;}
\=\= 				{ report_token("REL_OP", yytext, line_number); return EQ;}
\!\= 				{ report_token("REL_OP", yytext, line_number); return NE;}	

	/* ___ LOGICAL OPERATORS __ */
\&\& 				{ report_token("LOG_OP", yytext, line_number); return AND;}
\|\| 				{ report_token("LOG_OP", yytext, line_number); return OR;}
\!	 				{ report_token("LOG_OP", yytext, line_number); return NOT;}

	/* ___ BINARY OPERATORS __ */
\^					{ report_token("BIN_OP", yytext, line_number); return B_XOR; }
\~					{ report_token("BIN_OP", yytext, line_number); return B_NOT; }
\&					{ report_token("BIN_OP", yytext, line_number); return B_AND; }
\|					{ report_token("BIN_OP", yytext, line_number); return B_OR; }
\<\<				{ report_token("BIN_OP", yytext, line_number); return B_LSHIFT; }
\>\>				{ report_token("BIN_OP", yytext, line_number); return B_RSHIFT; }

\(|\[|\{			{ report_token("SEP", yytext, line_number); return yytext[0];}
\)|\]|\}			{ report_token("SEP", yytext, line_number); return yytext[0];}
\;|\,|\:			{ report_token("SEP", yytext, line_number); return yytext[0];}


	/* ___ CONSTANTS ___ */
true|TRUE				{ report_token("CONS", yytext, line_number); return BOOL_CONS;}
false|FALSE				{ report_token("CONS", yytext, line_number); return BOOL_CONS;}

{id}            		{ yylval.sval=strdup(yytext); fprintf(f_tokens,"<ID, '%s', %d, %d>\n",yytext,scope,line_number); return IDENT;}
{digits}        		{ yylval.ival=atoi(yytext); fprintf(f_tokens,"<CONS, 'INT', %d, %d>\n",yylval.ival,line_number); return INT_CONS;}
{digits}{opFraction}	{ yylval.fval=atof(yytext); fprintf(f_tokens,"<CONS, 'FLOAT', %f, %d>\n",yylval.fval,line_number); return FLOAT_CONS;}
\'{letter}\' 			{ yylval.sval=strdup(yytext); fprintf(f_tokens,"<CONS, 'CHAR', %c, %d>\n",yylval.sval[1],line_number); return CHAR_CONS;}
\".*\" 					{ yylval.sval=strdup(yytext); fprintf(f_tokens,"<CONS, 'STRING', %s, %d>\n",yytext,line_number); return STRING_CONS;}
{header}				{ yylval.sval=strdup(yytext); fprintf(f_tokens,"<CONS, 'HEADER', %s, %d>\n",yytext,line_number); return HEADER;}


[\n] { line_number++;}
[ |\t] ;
.               		{ return ERR; }
%%
int yywrap()
{
	return 1;
}