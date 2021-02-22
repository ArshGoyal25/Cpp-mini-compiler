%{
#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include "y.tab.h"

extern YYSTYPE yylval;

int line_no = 1;
int line_of_declaration = 0;
int scope = 0;

FILE *f_tokens;

%}

digit       [0-9]
letter      [a-zA-Z_]
id          {letter}({letter}|{digit})*
digits      {digit}+
opFraction  (\.{digits})?
opExponent  ([Ee][+-]?{digits})?
number      {digits}{opFraction}{opExponent}

%%

	/* comments and white spaces */
([ ]*|(\n\t)*|(\n)*|(\t)*)*\/\/.* 
([ ]*|(\n\t)*|(\n)*|(\t)*)*\/\*(.*\n)*.*\*\/ 

int[ ]main 			{ fprintf(f_tokens,"<KEYW, 'int', %d>\n",line_no); fprintf(f_tokens,"<KEYW, 'main', %d>\n",line_no); return PRO_BEG;}


int|char|float|void { fprintf(f_tokens,"<KEYW, '%s', %d>\n",yytext,line_no); return TYPE_SPEC;}

if 					{ fprintf(f_tokens,"<KEYW, '%s', %d>\n",yytext,line_no); return IF;}
break 				{ fprintf(f_tokens,"<KEYW, '%s', %d>\n",yytext,line_no); return BREAK;}
continue			{ fprintf(f_tokens,"<KEYW, '%s', %d>\n",yytext,line_no); return CONTINUE;}
while				{ fprintf(f_tokens,"<KEYW, '%s', %d>\n",yytext,line_no); return WHILE;}
return				{ fprintf(f_tokens,"<KEYW, '%s', %d>\n",yytext,line_no); return RETURN;}
switch				{ fprintf(f_tokens,"<KEYW, '%s', %d>\n",yytext,line_no); return SWITCH;}
case				{ fprintf(f_tokens,"<KEYW, '%s', %d>\n",yytext,line_no); return CASE;}
default				{ fprintf(f_tokens,"<KEYW, '%s', %d>\n",yytext,line_no); return DEFAULT;}
cout 				{ fprintf(f_tokens,"<KEYW, '%s', %d>\n",yytext,line_no); return COUT;}


\+|\-|\*|\/|\%		{ fprintf(f_tokens,"<ARITH_OP, '%s', %d>\n",yytext,line_no); return yytext[0];}
\= 					{ fprintf(f_tokens,"<ASSIGN, '%s', %d>\n",yytext,line_no); return yytext[0];}


\< 					{ fprintf(f_tokens,"<REL_OP, '%s', %d>\n",yytext,line_no); return LT;}
\> 					{ fprintf(f_tokens,"<REL_OP, '%s', %d>\n",yytext,line_no); return GT;}
\<\= 				{ fprintf(f_tokens,"<REL_OP, '%s', %d>\n",yytext,line_no); return LE;}
\>\= 				{ fprintf(f_tokens,"<REL_OP, '%s', %d>\n",yytext,line_no); return GE;}
\=\= 				{ fprintf(f_tokens,"<REL_OP, '%s', %d>\n",yytext,line_no); return EQ;}
\!\= 				{ fprintf(f_tokens,"<REL_OP, '%s', %d>\n",yytext,line_no); return NE;}

\&\& 				{ fprintf(f_tokens,"<LOG_OP, '%s', %d>\n",yytext,line_no); return AND;}
\|\| 				{ fprintf(f_tokens,"<LOG_OP, '%s', %d>\n",yytext,line_no); return OR;}
\!	 				{ fprintf(f_tokens,"<LOG_OP, '%s', %d>\n",yytext,line_no); return NOT;}


\(|\{|\[			{ fprintf(f_tokens,"<SEP, '%s', %d>\n",yytext,line_no); return yytext[0];}
\)|\}|\]			{ fprintf(f_tokens,"<SEP, '%s', %d>\n",yytext,line_no); return yytext[0];}
\;|\,|\:			{ fprintf(f_tokens,"<SEP, '%s', %d>\n",yytext,line_no); return yytext[0];}

\<\< 				{ fprintf(f_tokens,"<REDIR, '%s', %d>\n",yytext,line_no); return REDIR_OP_OUT;}
\>\> 				{ fprintf(f_tokens,"<REDIR, '%s', %d>\n",yytext,line_no); return REDIR_OP_IN;}


true|TRUE				{ fprintf(f_tokens,"<CONS, '%s', %d>\n",yytext,line_no); return BOOL_CONS;}
false|FALSE				{ fprintf(f_tokens,"<CONS, '%s', %d>\n",yytext,line_no); return BOOL_CONS;}

{id}            		{ yylval.sval=strdup(yytext); fprintf(f_tokens,"<ID, '%s', %d, %d>\n",yytext,scope,line_no); return ID;}
{digits}        		{ yylval.ival=atoi(yytext); fprintf(f_tokens,"<CONS, 'INT', %d, %d>\n",yylval.ival,line_no); return INT_CONS;}
{digits}{opFraction}	{ yylval.fval=atof(yytext); fprintf(f_tokens,"<CONS, 'FLOAT', %f, %d>\n",yylval.fval,line_no); return FLOAT_CONS;}
\'{letter}\' 			{ yylval.sval=strdup(yytext); fprintf(f_tokens,"<CONS, 'CHAR', %c, %d>\n",yylval.sval[1],line_no); return CHAR_CONS;}
\".*\" 					{ yylval.sval=strdup(yytext); fprintf(f_tokens,"<CONS, 'STRING', %s, %d>\n",yytext,line_no); return STRING_CONS;}


[\n] { line_no++;}
[ |\t] ;
.               		{ return ERR; }
%%
int yywrap()
{
	return 1;
}