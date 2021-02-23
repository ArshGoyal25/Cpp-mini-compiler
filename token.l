%{
#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include "y.tab.h"

extern YYSTYPE yylval;

int line_no = 1;
int line_of_declaration = 0;
int scope = 0;
#define report_token(type, lexeme, line_no) fprintf(f_tokens, "<%s, '%s', %d>\n", type, lexeme, line_no);

FILE *f_tokens;

%}

digit       [0-9]
letter      [a-zA-Z_]
id          {letter}({letter}|{digit})*
header		[<]({letter})+[.][h][>]
digits      {digit}+
opFraction  (\.{digits})?
opExponent  ([Ee][+-]?{digits})?
number      {digits}{opFraction}{opExponent}

%%

	/* comments and white spaces */
([ ]*|(\n\t)*|(\n)*|(\t)*)*\/\/.* 
([ ]*|(\n\t)*|(\n)*|(\t)*)*\/\*(.*\n)*.*\*\/ 

int[ ]main 			{ report_token("KEYW", "int", line_no); report_token("KEYW", "main", line_no); return PRO_BEG;}


int|char|float|void|double|long\ +long { report_token("KEYW", yytext, line_no); return TYPE_SPEC;}

if 					{  return IF;}
break 				{ report_token("KEYW", yytext, line_no); return BREAK;}
continue			{ report_token("KEYW", yytext, line_no); return CONTINUE;}
while				{ report_token("KEYW", yytext, line_no); return WHILE;}
return				{ report_token("KEYW", yytext, line_no); return RETURN;}
switch				{ report_token("KEYW", yytext, line_no); return SWITCH;}
case				{ report_token("KEYW", yytext, line_no); return CASE;}
default				{ report_token("KEYW", yytext, line_no); return DEFAULT;}
cout 				{ report_token("KEYW", yytext, line_no); return COUT;}


\+|\-|\*|\/|\%		{ fprintf(f_tokens,"<ARITH_OP, '%s', %d>\n",yytext,line_no); return yytext[0];}
\= 					{ fprintf(f_tokens,"<ASSIGN, '%s', %d>\n",yytext,line_no); return yytext[0];}


\< 					{ report_token("REL_OP", yytext, line_no); return LT;}
\> 					{ report_token("REL_OP", yytext, line_no); return GT;}
\<\= 				{ report_token("REL_OP", yytext, line_no); return LE;}
\>\= 				{ report_token("REL_OP", yytext, line_no); return GE;}
\=\= 				{ report_token("REL_OP", yytext, line_no); return EQ;}
\!\= 				{ report_token("REL_OP", yytext, line_no); return NE;}


\&\& 				{ report_token("LOG_OP", yytext, line_no); return AND;}
\|\| 				{ report_token("LOG_OP", yytext, line_no); return OR;}
\!	 				{ report_token("LOG_OP", yytext, line_no); return NOT;}


\(|\{|\[			{ report_token("SEP", yytext, line_no); return yytext[0];}
\)|\}|\]			{ report_token("SEP", yytext, line_no); return yytext[0];}
\;|\,|\:			{ report_token("SEP", yytext, line_no); return yytext[0];}


\<\< 				{ report_token("REDIR", yytext, line_no); return REDIR_OP_OUT;}
\>\> 				{ report_token("REDIR", yytext, line_no); return REDIR_OP_IN;}

true|TRUE				{ report_token("CONS", yytext, line_no); return BOOL_CONS;}
false|FALSE				{ report_token("CONS", yytext, line_no); return BOOL_CONS;}

{id}            		{ yylval.sval=strdup(yytext); fprintf(f_tokens,"<ID, '%s', %d, %d>\n",yytext,scope,line_no); return ID;}
{digits}        		{ yylval.ival=atoi(yytext); fprintf(f_tokens,"<CONS, 'INT', %d, %d>\n",yylval.ival,line_no); return INT_CONS;}
{digits}{opFraction}	{ yylval.fval=atof(yytext); fprintf(f_tokens,"<CONS, 'FLOAT', %f, %d>\n",yylval.fval,line_no); return FLOAT_CONS;}
\'{letter}\' 			{ yylval.sval=strdup(yytext); fprintf(f_tokens,"<CONS, 'CHAR', %c, %d>\n",yylval.sval[1],line_no); return CHAR_CONS;}
\".*\" 					{ yylval.sval=strdup(yytext); fprintf(f_tokens,"<CONS, 'STRING', %s, %d>\n",yytext,line_no); return STRING_CONS;}
{header}				{ yylval.sval=strdup(yytext); fprintf(f_tokens,"<CONS, 'HEADER', %s, %d>\n",yytext,line_no); return HEADER;}


[\n] { line_no++;}
[ |\t] ;
.               		{ return ERR; }
%%
int yywrap()
{
	return 1;
}