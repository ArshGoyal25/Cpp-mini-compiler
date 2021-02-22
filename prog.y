%{
#include<stdio.h>
int yylex();
void yyerror(char *s);
%}
%token ID NUM INT FLOAT CHAR
%%
Prog	: Declr	{printf("Valid"); YYACCEPT;}
		;
Declr	: Type ListVar ';'
		;
Type	: INT | FLOAT | CHAR
		;
ListVar	: ID | ListVar ',' ID
		;;
%%
void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}
int main()
{
yyparse();
return 0;
}

