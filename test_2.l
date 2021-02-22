%{
#include<stdio.h>
%}
digit       [0-9]
letter      [a-zA-Z]
id          {letter}({letter}|{digit})*
digits      {digit}+
opFraction  (\.{digits})?
opExponent  ([Ee][+-]?{digits})?
number      {digits}{opFraction}{opExponent}
%%
int|float|char  printf("KEYWORD\n");
{id}            printf("Identifier\n");
{number}        printf("Number\n");
>|>=|<|<=|==|!= printf("RELOP\n");
[\n|\t|\s] ;
