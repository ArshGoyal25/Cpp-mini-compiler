#include<stdio.h>
#include<stdlib.h>



//ICG
char icg_var_stack[100][20];
int branch_stk[50];
char switch_stk[100][20];
FILE *f_icg;

//ICG
void push_onto_icg_stack(char val[20]);
void pop_from_icg_stack(char val[20]);
void assign_icg();
void arit_icg();
void rel_icg();
void bin_icg();
void inc_dec_icg();
void create_branch();
void rel_expr();
void while_branch_end();
void if_branch_end();
void if_branch_end_with_else();
void break_icg();
void switch_test();
void switch_case();
void case_end();
void switch_case_end();



