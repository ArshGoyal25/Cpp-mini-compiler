LEX = lex
YACC = yacc
CC = gcc
YFLAGS = -d
DEBUG = -v

all: mini_compiler

mini_compiler: y.tab.o symbol_table.o
	gcc y.tab.o symbol_table.o -o miniCompiler

lex.yy.c: token.l
	$(LEX) token.l

y.tab.c: grammar.y lex.yy.c
	$(YACC) $(YFLAGS) grammar.y -v

symbol_table.o: symbol_table.c
	gcc -c symbol_table.c

y.tab.o: y.tab.c
	gcc -c y.tab.c

clean:
	rm -rf *.o y.tab.c lex.yy.c miniCompiler y.tab.h y.output *.txt