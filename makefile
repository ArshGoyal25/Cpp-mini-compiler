LEX = lex
YACC = yacc
CC = gcc
YFLAGS = -d

all: 
	$(LEX) token.l
	$(YACC) $(YFLAGS) grammar.y
	$(CC) y.tab.c -ll
	./a.out