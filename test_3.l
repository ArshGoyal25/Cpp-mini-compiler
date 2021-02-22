%{
#include<stdio.h>
#include "y.tab.h"
%}
digit       [0-9]
letter      [a-zA-Z]
id          {letter}({letter}|{digit})*
digits      {digit}+
opFraction  (\.{digits})?
opExponent  ([Ee][+-]?{digits})?
number      {digits}{opFraction}{opExponent}
%%
int             return INT;
float           return FLOAT;
char            return CHAR;
{id}            return ID;
"if"/"(".*")"   return IF;
{number}        return NUM;
[\n|\t|\s] ;
.               return *yytext;
