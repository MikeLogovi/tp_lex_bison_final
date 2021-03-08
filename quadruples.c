#include <stdio.h>
#include<stdlib.h>
#include<string.h>
#include "quadruples.h"
#define MAX_NB_ELEMENTS 10000
extern void yyerror(char *err);

QuadrupleTable* createQuadrupleTable(){
    QuadrupleTable *quadrupleTable = (QuadrupleTable*) malloc(sizeof(QuadrupleTable));
    quadrupleTable->quadruples = (Quadruple**)malloc(sizeof(Quadruple)*MAX_NB_ELEMENTS);
    quadrupleTable->length=MAX_NB_ELEMENTS;
    quadrupleTable->nbElements=0;
    return quadrupleTable;
}
Quadruple* createQuadruple(char *operation,char *argument1,char *argument2,char *result){
    Quadruple* quadruple = (Quadruple*) malloc(sizeof(Quadruple));
    strcpy(quadruple->operation,operation);
    strcpy(quadruple->argument1,argument1);
    strcpy(quadruple->argument2,argument2);
    strcpy(quadruple->result,result);
    return quadruple;
}
void insertQuadruple(QuadrupleTable **quadrupleTableP,Quadruple *quadruple){
    FILE* file=NULL;
    QuadrupleTable *quadrupleTable = *quadrupleTableP;
    if(quadrupleTable->nbElements >= quadrupleTable->length){
        quadrupleTable->quadruples = (Quadruple**) realloc(quadrupleTable->quadruples,quadrupleTable->length+100);
        quadrupleTable->length+=100;
    }
    quadrupleTable->quadruples[quadrupleTable->nbElements++] = quadruple;
    file = fopen("quadruplets.txt","a");
    if(!file)
        yyerror("Impossible d'ouvrir le fichier des quadruplets\n");
    fprintf(file,"%d-(%s,%s,%s,%s)\n",quadrupleTable->nbElements-1,quadruple->operation,quadruple->argument1,quadruple->argument2,quadruple->result);
    fclose(file);
}