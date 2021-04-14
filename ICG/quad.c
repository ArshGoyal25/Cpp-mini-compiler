#include "icg.h"
#include "quad.h"
#include<stdlib.h>
#include<stdio.h>
#include<string.h>

quad *headq = NULL;

void insert_into_quad(char op[20], char arg1[20], char arg2[20], char res[20])
{
    quad *temp = (quad *)malloc(sizeof(quad));
    strcpy(temp->op,op);
    strcpy(temp->arg1,arg1);
    strcpy(temp->arg2,arg2);
    strcpy(temp->res,res);

    if(headq == NULL)
    {
        headq = temp;
    }
    else
    {
        quad *temp1 = headq;
        while(temp1->link)
        {
            temp1 = temp1->link;
        }
        temp1->link = temp;
    }
}

void write_quad(FILE *f_quad)
{
    quad *temp = headq;
    fprintf(f_quad,"%s\t\t%20s\t\t%20s\t\t%20s\t\t%20s\n\n","Pos","Op","Arg1","Arg2","Res");
    int pos = 1;
    while(temp)
    {
        fprintf(f_quad,"%d\t\t%20s\t\t%20s\t\t%20s\t\t%20s\n",pos,temp->op,temp->arg1,temp->arg2,temp->res);
        temp = temp->link;
        pos++;
    }
}