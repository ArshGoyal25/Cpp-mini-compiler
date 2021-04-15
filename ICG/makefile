LEX = lex
YACC = yacc
CC = gcc
YFLAGS = -d
DEBUG = -v

all: mini_compiler

mini_compiler: y.tab.o icg.o quad.o
	gcc y.tab.o icg.o quad.o -o miniCompiler

lex.yy.c: lex_icg.l
	$(LEX) lex_icg.l

y.tab.c: grammar_icg.y lex.yy.c
	$(YACC) $(YFLAGS) grammar_icg.y

y.tab.o: y.tab.c
	gcc -c y.tab.c

icg.o: icg.c
	gcc -c icg.c

quad.o: quad.c
	gcc -c quad.c

clean:
	rm -rf *.o y.tab.o y.tab.c lex.yy.c miniCompiler y.tab.h y.output *.txt