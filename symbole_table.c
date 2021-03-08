#include<stdbool.h>
#include<stdlib.h>
#include<stdio.h>
#include<string.h>
#include "utilities.h"
#include "symbole_table.h"
extern int  yylcol;
extern void yyerror(char *err);
char error[1000];
void deleteSymboleTable(SymboleTable* symboleTable){
    free(symboleTable->symboles);
    free(symboleTable);
}
int hash(SymboleTable* t,char* s){
    int resultat=0,i;
    for(i=0;i<(int)strlen(s);i++)
        resultat+=(int)s[i];
    resultat%=t->length;
    return resultat;    
}
void insertSymbole(SymboleTable** symboleTableP,Symbole* symbole){
    SymboleTable* symboleTable = *symboleTableP;
    if(symboleTable->nbElements > symboleTable->length){
        symboleTable->length = symboleTable->length +100;
        symboleTable->symboles = (Symbole**)realloc(symboleTable->symboles,symboleTable->length);
        symboleTable->keys = (int*) realloc(symboleTable->keys,symboleTable->length); 
    }
    int symboleHash = hash(symboleTable,symbole->name);
    while(symboleTable->symboles[symboleHash]){
        if(strcmp(symboleTable->symboles[symboleHash]->name,symbole->name)==0){
            sprintf(error,"Variable %s doublement déclarée\n",symbole->name);
            yyerror(error);
        }
        symboleHash++;
    }
    symboleTable->keys[symboleTable->nbElements]=symboleHash;
    symboleTable->nbElements++;
    symboleTable->symboles[symboleHash]= symbole;
}
Symbole* createSymbole(char* name,char* type,bool isConstant,bool isSet,float value){
    Symbole* s= malloc(sizeof(Symbole));
    strcpy(s->name,name);
    strcpy(s->type,type);
    s->isConstant = isConstant;
    s->isSet = isSet;
    s->value = value;
    return s;
}
void deleteSymbole(Symbole* s){
    free(s->name);
    free(s->type);
    free(s);
}
int symbolExists(SymboleTable *t,char* s){
    int hashSymbole = hash(t,s);
    if(!t->symboles[hashSymbole])
        yyerror("Variable non déclarée\n");
    while(t->symboles[hashSymbole] && (strcmp(t->symboles[hashSymbole]->name,s)!=0))
        hashSymbole++;
    if(!t->symboles[hashSymbole])
        yyerror("Variable non déclarée\n");
    return hashSymbole;
}
void updateSymbole(SymboleTable *t,char* s,char type[],float value){
    int hashSymbole = symbolExists(t,s);
    if(t->symboles[hashSymbole]->isConstant){
        sprintf(error,"%s est une constante et ne peut être modifiée \n" ,s);
        yyerror(error);
    }
    if(!areTypesCompatibable(t->symboles[hashSymbole]->type,type)){
        sprintf(error,"Vous tentez d'affectez un %s à un %s ; Operation non autorisée \n" ,type,t->symboles[hashSymbole]->type);
        yyerror(error);
    }
    t->symboles[hashSymbole]->isSet = true;
    t->symboles[hashSymbole]->value=value;
}
char* symboleType(SymboleTable *t,char* s){
    int hashSymbole = symbolExists(t,s); 
    return t->symboles[hashSymbole]->type;
}
void setSymboleType(SymboleTable *t,char* s,char type[]){
    int hashSymbole = symbolExists(t,s);
    if(!t->symboles[hashSymbole]->isSet){
        strcpy(t->symboles[hashSymbole]->type,type);
        return;
    }    
    char expressionType[6];
    strcpy(expressionType,getExpressionType(t->symboles[hashSymbole]->value));
    if(areTypesCompatibable(type,expressionType))
              strcpy(t->symboles[hashSymbole]->type,type);       
    else{
          sprintf(error,"Vous tentez d'affectez un %s à un %s ; Operation non autorisée \n" ,expressionType,type);
          yyerror(error);
    }
}
void setSymboleConstant(SymboleTable *t,char* s){
    int hashSymbole = symbolExists(t,s); 
    t->symboles[hashSymbole]->isConstant = true ;
}
float symboleVal(SymboleTable *t,char* s){
    int hashSymbole = symbolExists(t,s);
    if(!t->symboles[hashSymbole]->isSet){
        sprintf(error,"%s n'a pas été initialisée\n",s);
        yyerror(error);
    }
    return t->symboles[hashSymbole]->value;
}
void printSymboleTable(SymboleTable *t){
    int i,key;
    char oui[]="oui";
    char non[]="non";
            printf("----------------------------------------------------------------------------\n");
            printf("                            TABLE DE SYMBOLES                               \n");
            printf("----------------------------------------------------------------------------\n");
            printf("NOM         |         TYPE         |         VALEUR         |   CONSTANTE   \n");
            printf("----------------------------------------------------------------------------\n");
    for(i=0;i<t->nbElements;i++){
        key=t->keys[i];
        Symbole* s = t->symboles[key];
        char space_int[100];strcpy(space_int,"");
        char space[100];strcpy(space,"");
        char space_idf[100];strcpy(space_idf,"");
        int j;
        if(s->isSet){
            int nb_digits = nbDigits((int) s->value);
            
            for(j=1;j<=(24-nb_digits);j++)strcat(space_int," ");
            for(j=1;j<(18-nb_digits);j++)strcat(space," ");
            
        } 
        for(j=1;j<(13-strlen(s->name));j++)strcat(space_idf," "); 
        if(s->isSet){
            if(strcmp(s->type,"INT")==0)
                printf("%s%s|         %s          |%d%s|      %s      \n",s->name,space_idf,s->type,(int)s->value,space_int,s->isConstant?oui:non);  
            else if(strcmp(s->type,"FLOAT")==0)
                printf("%s%s|         %s        |%f%s|      %s     \n",s->name,space_idf,s->type,s->value,space,s->isConstant?oui:non);
            else if(strcmp(s->type,"BOOL")==0)
                printf("%s%s|         %s         |%d%s|      %s     \n",s->name,space_idf,s->type,(int)s->value,space_int,s->isConstant?oui:non);
        }else{
            if(strcmp(s->type,"INT")==0)
                printf("%s%s|         %s          |                        |      %s      \n",s->name,space_idf,s->type,s->isConstant?oui:non);
            else if(strcmp(s->type,"FLOAT")==0)
                printf("%s%s|         %s        |                        |      %s     \n",s->name,space_idf,s->type,s->isConstant?oui:non);
            else if(strcmp(s->type,"BOOL")==0)
                printf("%s%s|         %s         |                         |      %s     \n",s->name,space_idf,s->type,s->isConstant?oui:non);
        }
    }
}
