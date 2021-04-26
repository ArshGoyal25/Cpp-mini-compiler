#include "icg.h"
#include "quad.h"
#include<stdlib.h>
#include<stdio.h>
#include<string.h>
int top = -1;
int inter_var_no = 0;
int branch_no = 0;
int switch_no = 0;
int top_br = -1;
int case_no = 0;
int top_loop = -1;
int inside_switch = 0;

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
    char val_being_assign[20];
    pop_from_icg_stack(val_being_assign);

    char var_getting_val[20];
    pop_from_icg_stack(var_getting_val);

    fprintf(f_icg,"    %s = %s\n",var_getting_val,val_being_assign);
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
    
    fprintf(f_icg,"    %s = %s %s %s\n",new_var,left_operand,oper,right_operand);

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

    fprintf(f_icg,"    %s = %s %s %s\n",new_var,left_operand,oper,right_operand);

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

    fprintf(f_icg,"    %s = %s %s %s\n",new_var,left_operand,oper,right_operand);
    
    push_onto_icg_stack(new_var);

    insert_into_quad(oper,left_operand,right_operand,new_var);
}

void logic_icg(){
    char right_operand[20];
    pop_from_icg_stack(right_operand);

    char oper[20];
    pop_from_icg_stack(oper);

    char left_operand[20];
    pop_from_icg_stack(left_operand);

    char new_var[20];
    create_inter_var(new_var);

    fprintf(f_icg,"    %s = %s %s %s\n",new_var,left_operand,oper,right_operand);
    
    push_onto_icg_stack(new_var);

    insert_into_quad(oper,left_operand,right_operand,new_var);
}

void inc_icg(){
    char operand[20];
    pop_from_icg_stack(operand);
        
    char new_var[20];
    create_inter_var(new_var);

    fprintf(f_icg,"    %s = %s %s %s\n",new_var,"1","+",operand);
    insert_into_quad("+","1",operand,new_var);

    fprintf(f_icg,"    %s = %s\n",operand,new_var);
    insert_into_quad("=",new_var,"",operand);

    push_onto_icg_stack(operand);
}

void dec_icg(){
    char operand[20];
    pop_from_icg_stack(operand);
        
    char new_var[20];
    create_inter_var(new_var);

    fprintf(f_icg,"    %s = %s %s %s\n",new_var,"1","-",operand);
    insert_into_quad("-","1",operand,new_var);

    fprintf(f_icg,"    %s = %s\n",operand,new_var);
    insert_into_quad("=",new_var,"",operand);

    push_onto_icg_stack(operand);

}

void create_new_branch_var(char branch[20])
{
    strcpy(branch,"L");
    char digit[20];
    sprintf(digit,"%d",branch_no);
    strcat(branch,digit);

    top_br++;
    branch_stk[top_br] = branch_no;
    branch_no++;
}

void create_branch()
{
    char branch[20];
    create_new_branch_var(branch);

    fprintf(f_icg,"%s:\n",branch);
    insert_into_quad("goto","","",branch);
    top_loop++;
    loop_stk[top_loop] = branch_no;
}

void rel_expr()
{
    char val[20];
    pop_from_icg_stack(val);

    char var_getting_val[20];
    create_inter_var(var_getting_val);
    
    fprintf(f_icg,"    %s = not %s\n",var_getting_val,val);
    insert_into_quad("not",val,"",var_getting_val);
    
    char branch[20];
    create_new_branch_var(branch);
    fprintf(f_icg,"    if %s GOTO %s\n",var_getting_val,branch);
    insert_into_quad("if",var_getting_val,"",branch);
}

void while_branch_end(){
    int br = branch_stk[top_br];
    char branch[20];
    strcpy(branch,"L");
    char digit[20];
    sprintf(digit,"%d",br-1);
    strcat(branch,digit);

    fprintf(f_icg,"    GOTO %s\n",branch);
    insert_into_quad("goto","","",branch);

    strcpy(branch,"L");
    sprintf(digit,"%d",br);
    strcat(branch,digit);
    fprintf(f_icg,"%s:\n",branch);
    top_br -= 2;
    top_loop--;
}

void if_branch_end(){
    int br = branch_stk[top_br];
    top_br--;

    char branch[20];
    strcpy(branch,"L");
    char digit[20];
    sprintf(digit,"%d",br);
    strcat(branch,digit);

    fprintf(f_icg,"%s:\n",branch);
}

void if_branch_end_with_else(){

    char branch[20];

    create_new_branch_var(branch);

    fprintf(f_icg,"    GOTO %s\n",branch);
    insert_into_quad("goto","","",branch);

    int br = branch_stk[top_br-1];

    strcpy(branch,"L");
    char digit[20];
    sprintf(digit,"%d",br);
    strcat(branch,digit);

    fprintf(f_icg,"%s:\n",branch);
    
}

void break_icg(){
    if(inside_switch){
        case_end();
    }
    else{
        int br = loop_stk[top_loop];
        char branch[20];
        strcpy(branch,"L");
        char digit[20];
        sprintf(digit,"%d",br);
        strcat(branch,digit);

        fprintf(f_icg,"    GOTO %s\n",branch);
        insert_into_quad("goto","","",branch);
    }
}

void return_icg(){
    char val[20];
    pop_from_icg_stack(val);
    fprintf(f_icg,"    return %s\n",val);
    insert_into_quad("return","","",val);
    char branch[20];
    strcpy(branch,"end");

    fprintf(f_icg,"    GOTO %s\n",branch);
    insert_into_quad("goto","","",branch);

}

void switch_test(){
    char val[20];
    pop_from_icg_stack(val);

    char new_var[20];
    create_inter_var(new_var);

    fprintf(f_icg,"    %s = %s\n",new_var,val);
    insert_into_quad("=",val,"",new_var);
    push_onto_icg_stack(new_var);
    
    char branch[20];
    strcpy(branch,"Test");
    char digit[20];
    sprintf(digit,"%d",switch_no);
    strcat(branch,digit);

    fprintf(f_icg,"    GOTO %s\n",branch);
    insert_into_quad("goto","","",branch);
    case_no = 0;
    inside_switch = 1;
}

void switch_case(){
    char branch[20];
    create_new_branch_var(branch);
    case_no +=1;
    strcpy(switch_stk[case_no],branch);
    fprintf(f_icg,"%s:\n",branch);
    // insert_into_quad("goto","","",branch);
}

void case_end(){
    char branch[20];
    strcpy(branch,"Last");
    char digit[20];
    sprintf(digit,"%d",switch_no);
    strcat(branch,digit);
    fprintf(f_icg,"    GOTO %s\n",branch);
    insert_into_quad("goto","","",branch);
}

void switch_case_end(){
    case_end();
    char branch[20];
    strcpy(branch,"Test");
    char digit[20];
    sprintf(digit,"%d",switch_no);
    strcat(branch,digit);
    fprintf(f_icg,"%s:\n",branch);

    char val[20];
    char cases[10][20];
    int temp = case_no;
    while(temp!=0){
        pop_from_icg_stack(val);
        strcpy(cases[temp],val);
        temp -=1;
    }

    char var_been_checked[20];
    pop_from_icg_stack(var_been_checked);
        
    temp += 1;
    while(temp <= case_no && strcmp(cases[temp],"None")!=0 ){

        char new_var[20];
        create_inter_var(new_var);
        
        fprintf(f_icg,"    %s : %s %s %s\n",new_var,var_been_checked,"==",cases[temp]);
        insert_into_quad("==",var_been_checked,cases[temp],new_var);

        fprintf(f_icg,"    if %s GOTO %s\n",new_var, switch_stk[temp]);
        insert_into_quad("if",new_var,"",switch_stk[temp]);
        temp +=1;
    }
    if(strcmp(cases[temp],"None")==0){
        fprintf(f_icg,"    GOTO %s\n",switch_stk[temp]);
        insert_into_quad("goto","","",switch_stk[temp]);
    }
    strcpy(branch,"Last");
    sprintf(digit,"%d",switch_no);
    strcat(branch,digit);
    fprintf(f_icg,"%s:\n",branch);
    inside_switch = 0;
    switch_no +=1;
}

void main_start(){
    char branch[20];
    strcpy(branch,"main");
    fprintf(f_icg,"%s:\n",branch);
}
void main_end(){
    char branch[20];
    strcpy(branch,"end");
    fprintf(f_icg,"%s:\n",branch);
}