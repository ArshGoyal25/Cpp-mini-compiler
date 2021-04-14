#include<stdio.h>
#include<stdlib.h>



//ICG
char icg_var_stack[100][20];
FILE *f_icg;

//ICG
void push_onto_icg_stack(char val[20]);
void pop_from_icg_stack(char val[20]);
void assign_icg();
void arit_icg();
void rel_icg();
void bin_icg();



