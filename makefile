LEX = lex
YACC = yacc
CC = gcc
YFLAGS = -d -v

all: 
	$(LEX) token.l
	$(YACC) $(YFLAGS) grammar.y
	$(CC) y.tab.c -ll
	./a.out