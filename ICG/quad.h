#include<stdio.h>
#include<stdlib.h>

typedef struct quadruples{
	char op[20];
	char arg1[20];
	char arg2[20];
	char res[20];
	struct quadruples *link;
} quad;

//QUAD
void insert_into_quad(char op[20], char arg1[20], char arg2[20], char res[20]);
void write_quad(FILE *f_quad);