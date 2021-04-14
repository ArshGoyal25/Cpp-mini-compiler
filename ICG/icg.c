#include "icg.h"
#include "quad.h"
#include<stdlib.h>
#include<stdio.h>
#include<string.h>
int top = -1;
int inter_var_no = 0;
int branch_no = 0;

void create_inter_var(char inter[20])
{
    strcpy(inter,"t");
    char digit[20];
    sprintf(digit, "%d", inter_var_no);
    strcat(inter,digit);
    inter_var_no++;
}

void push_onto_icg_stack(char val[20])
{
    if(top != 99)
    {
        top++;
        strcpy(icg_var_stack[top],val);
    }
}

void pop_from_icg_stack(char val[20])
{
    if(top != -1)
    {
        strcpy(val,icg_var_stack[top]);
        top--;
    }
}

void assign_icg(){
    printf("assign_icg\n");
    char val_being_assign[20];
    pop_from_icg_stack(val_being_assign);

    char var_getting_val[20];
    pop_from_icg_stack(var_getting_val);

    fprintf(f_icg,"%s = %s\n",var_getting_val,val_being_assign);
    insert_into_quad("=",val_being_assign,"",var_getting_val);
}

void arit_icg(){
    char right_operand[20];
    pop_from_icg_stack(right_operand);

    char oper[20];
    pop_from_icg_stack(oper);

    char left_operand[20];
    pop_from_icg_stack(left_operand);

    char new_var[20];
    create_inter_var(new_var);
    
    fprintf(f_icg,"%s = %s %s %s\n",new_var,left_operand,oper,right_operand);

    push_onto_icg_stack(new_var);
    
    insert_into_quad(oper,left_operand,right_operand,new_var);

}

void rel_icg()
{
    char right_operand[20];
    pop_from_icg_stack(right_operand);

    char oper[20];
    pop_from_icg_stack(oper);

    char left_operand[20];
    pop_from_icg_stack(left_operand);

    char new_var[20];
    create_inter_var(new_var);

    fprintf(f_icg,"%s = %s %s %s\n",new_var,left_operand,oper,right_operand);

    push_onto_icg_stack(new_var);

    insert_into_quad(oper,left_operand,right_operand,new_var);
}

void bin_icg()
{
    char right_operand[20];
    pop_from_icg_stack(right_operand);

    char oper[20];
    pop_from_icg_stack(oper);

    char left_operand[20];
    pop_from_icg_stack(left_operand);

    char new_var[20];
    create_inter_var(new_var);

    fprintf(f_icg,"%s = %s %s %s\n",new_var,left_operand,oper,right_operand);
    
    push_onto_icg_stack(new_var);

    insert_into_quad(oper,left_operand,right_operand,new_var);
}
/////////////////////////////////////////////////////

