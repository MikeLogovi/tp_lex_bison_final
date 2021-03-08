%{
   #include<stdio.h>
   #include<stdlib.h>
   #include<stdbool.h>
   #include<string.h>
   #include "symbole_table.h"
   #include "linked_list_identifier.h"
   #include "quadruples.h"
   #include "utilities.h"

   extern int yylex();
   extern void yyerror(char* err);
   SymboleTable* t ;
   QuadrupleTable* q;
   int IQ=1;
   int j=0;
   char arguments[10000][1000];
   char labels[10000][10000];
   Symbole* s;
   char myType[6]; 
   char argument1[20];
   char argument2[20];
   ListIdentifier* identifiers;
   
%}
%start program
%token BEGIN_ END_ IDENTIFIER CONST  INT FLOAT BOOL  NUMBER STRING IF ELSE FOR COMMENT AFF INC DEC NEWLINE PRINT 
%left GE LE EQ NE DIFF '>' '<'
%left '+' '-'
%left '/' '*'
%nonassoc UMINUS

%left INC DEC
%union{
    float float_val;
    char identifier[10];
    char type[6];
    char string[10000];
}
%type<identifier> IDENTIFIER  dec_begin
%type <identifier> assignment
%type<type> type INT FLOAT BOOL
%type<float_val> expression NUMBER  increment decrement  condition computation
%type<string> STRING
%%
program: declarations core  
       ;
declarations:  
            | declaration declarations
           ;
declaration: CONST type  dec_begin_const listidentifiers_const      {deleteListAndSetTypeToIdentifier(&identifiers,t,$2,true);identifiers = NULL;}
           | type  dec_begin listidentifiers                        {deleteListAndSetTypeToIdentifier(&identifiers,t,$1,false);identifiers = NULL;}           
           ;
dec_begin: IDENTIFIER                { s = createSymbole($1 ,"" ,false,false,0); insertSymbole(&t,s);push(&identifiers,$1);}
         | IDENTIFIER '=' expression {Quadruple *qd =createQuadruple(":=",labels[j-1],"_",$1);insertQuadruple(&q,qd);} { s = createSymbole($1 ,"" ,false,true,$3); insertSymbole(&t,s);push(&identifiers,$1);}
         ;
dec_begin_const:IDENTIFIER           { s = createSymbole($1 ,"" ,true,false,0); insertSymbole(&t,s); push(&identifiers,$1);}
               |IDENTIFIER '=' expression {Quadruple *qd =createQuadruple(":=",labels[j-1],"_",$1);insertQuadruple(&q,qd);} { s = createSymbole($1 ,"" ,true,true,$3); insertSymbole(&t,s);push(&identifiers,$1);}
               ;
listidentifiers:',' IDENTIFIER listidentifiers                  { s = createSymbole($2 ,"" ,false,false,0); insertSymbole(&t,s); push(&identifiers,$2);}
               | ',' IDENTIFIER '=' expression {Quadruple *qd =createQuadruple(":=",labels[j-1],"_",$2);insertQuadruple(&q,qd);} listidentifiers  { s = createSymbole($2 ,"" ,false,true,$4); insertSymbole(&t,s); push(&identifiers,$2);}
               | ';'
               ;
listidentifiers_const: ',' IDENTIFIER '=' expression listidentifiers_const  { s = createSymbole($2 ,"" ,true,true,$4); insertSymbole(&t,s); push(&identifiers,$2);}
               |       ',' IDENTIFIER  listidentifiers_const  {s = createSymbole($2 ,"" ,true,false,0); insertSymbole(&t,s); push(&identifiers,$2);}    
               | ';'
               ;
type: INT     { strcpy($$,$1);}
    | FLOAT   { strcpy($$,$1);}
    | BOOL    { strcpy($$,$1);}
    ;

core:                       {;}
    |BEGIN_ main_core END_ 
    ;
main_core: 
         | list_instructions
         ;
list_instructions: assignment ';'
                 | COMMENT
                 | if_statement
                 | for_loop
                 | increment ';'
                 | decrement ';'
                 | print 
                 | list_instructions for_loop
                 | list_instructions if_statement
                 | list_instructions assignment ';'
                 | list_instructions increment ';'
                 | list_instructions decrement ';'
                 | list_instructions COMMENT 
                 | list_instructions print
                 ;
assignment:IDENTIFIER AFF  expression   {strcpy(myType,getExpressionType($3));updateSymbole(t,$1,myType,$3);Quadruple *qd =createQuadruple(":=",labels[j-1],"_",$1);insertQuadruple(&q,qd);}
          |IDENTIFIER AFF  increment    {strcpy(myType,getExpressionType($3));updateSymbole(t,$1,myType,$3);}
          |IDENTIFIER AFF  decrement    {strcpy(myType,getExpressionType($3));updateSymbole(t,$1,myType,$3);}
          ;
expression:  IDENTIFIER                      {$$=symboleVal(t,$1);strcpy(arguments[IQ++],$1);} 
           | NUMBER                          {$$ = $1;strcpy(argument1,"t"); sprintf(argument2,"%d",j++);strcat(argument1,argument2);strcpy(labels[j-1],argument1);sprintf(argument1,"%f",$1);strcpy(arguments[IQ++],argument1); Quadruple *qd =createQuadruple(":=",argument1,"_",labels[j-1]);insertQuadruple(&q,qd);}
           | computation
           | condition                       {$$ = $1;}
           | '(' increment ')'               {$$ = $2;}
           | '(' decrement ')'               {$$ = $2 ;}
           | '(' expression ')'              {$$ =$2;}
           | '-' expression                  {$$ = -$2;}
           | '+' expression                  {$$ = $2;}
           ;
computation: expression  '+'  expression     {$$ = $1 + $3; strcpy(argument1,"t"); sprintf(argument2,"%d",j++);strcat(argument1,argument2);Quadruple *qd =createQuadruple("+",arguments[IQ-2],arguments[IQ-1],argument1);insertQuadruple(&q,qd);strcpy(labels[j++],argument1);}
           | expression  '-'  expression     {$$ = $1 - $3; strcpy(argument1,"t"); sprintf(argument2,"%d",j++);strcat(argument1,argument2);Quadruple *qd =createQuadruple("-",arguments[IQ-2],arguments[IQ-1],argument1);insertQuadruple(&q,qd);strcpy(labels[j++],argument1);}
           | expression  '*'  expression     {$$ = $1 * $3; strcpy(argument1,"t"); sprintf(argument2,"%d",j++);strcat(argument1,argument2);Quadruple *qd =createQuadruple("*",arguments[IQ-2],arguments[IQ-1],argument1);insertQuadruple(&q,qd);strcpy(labels[j++],argument1);}
           | expression  '/'  expression     {if($3==0) yyerror("Erreur, division par zéro non autorisé\n"); else $$ = $1 / $3; strcpy(argument1,"t"); sprintf(argument2,"%d",j++);strcat(argument1,argument2);Quadruple *qd =createQuadruple("/",arguments[IQ-2],arguments[IQ-1],argument1);insertQuadruple(&q,qd);strcpy(labels[j++],argument1);}        
           ;
condition: expression  '<'  expression     {$$ = $1 < $3;strcpy(argument1,"t"); sprintf(argument2,"%d",j++);strcat(argument1,argument2);Quadruple *qd =createQuadruple("<",arguments[IQ-2],arguments[IQ-1],argument1);insertQuadruple(&q,qd);strcpy(labels[j++],argument1);}
         | expression  '>'  expression     {$$ = $1 > $3;strcpy(argument1,"t"); sprintf(argument2,"%d",j++);strcat(argument1,argument2);Quadruple *qd =createQuadruple(">",arguments[IQ-2],arguments[IQ-1],argument1);insertQuadruple(&q,qd);strcpy(labels[j++],argument1);}
         | expression  NE  expression      {$$ = $1 != $3;strcpy(argument1,"t"); sprintf(argument2,"%d",j++);strcat(argument1,argument2);Quadruple *qd =createQuadruple("!=",arguments[IQ-2],arguments[IQ-1],argument1);insertQuadruple(&q,qd);strcpy(labels[j++],argument1);}
         | expression  EQ  expression      {$$ = $1 == $3; strcpy(argument1,"t"); sprintf(argument2,"%d",j++);strcat(argument1,argument2);Quadruple *qd =createQuadruple("==",arguments[IQ-2],arguments[IQ-1],argument1);insertQuadruple(&q,qd);strcpy(labels[j++],argument1);}
         | expression  LE  expression      {$$ = $1 <= $3; strcpy(argument1,"t"); sprintf(argument2,"%d",j++);strcat(argument1,argument2);Quadruple *qd =createQuadruple("<=",arguments[IQ-2],arguments[IQ-1],argument1);insertQuadruple(&q,qd);strcpy(labels[j++],argument1);}
         | expression  GE  expression      {$$ = $1 >= $3;strcpy(argument1,"t"); sprintf(argument2,"%d",j++);strcat(argument1,argument2);Quadruple *qd =createQuadruple(">=",arguments[IQ-2],arguments[IQ-1],argument1);insertQuadruple(&q,qd);strcpy(labels[j++],argument1);}
         ;
list_computation:computation 
                |inc_dec     
                ;
inc_dec:increment
       |decrement
       ;
list_assignments: assignment
                ;
increment:INC IDENTIFIER                    {float value = symboleVal(t,$2); strcpy(myType,getExpressionType(value)); updateSymbole(t,$2,myType,value+1); $$ =value +1;}
         |IDENTIFIER INC                    {float value = symboleVal(t,$1); strcpy(myType,getExpressionType(value)); $$ =value; updateSymbole(t,$1,myType,value+1); }
         ; 
decrement:DEC IDENTIFIER                    {float value = symboleVal(t,$2); strcpy(myType,getExpressionType(value)); updateSymbole(t,$2,myType,value-1); $$ =value -1;}
         |IDENTIFIER DEC                    {float value = symboleVal(t,$1); $$ =value; strcpy(myType,getExpressionType(value)); updateSymbole(t,$1,myType,value-1); $$ =value;}
         ;

if_statement: simple_if  
            | simple_if ELSE '{' list_instructions '}'  
            ;
simple_if:IF '(' condition  ')''{' list_instructions '}'
for_loop: FOR '(' assignment ';' condition ';' compteur ')' '{' list_instructions '}'        {;}         
        ;
compteur:
        |list_assignments
        |list_computation
        |list_assignments ',' compteur
        |list_computation ',' compteur
        ;
print:print_identifier
     |print_string
     ;
print_identifier: PRINT IDENTIFIER  ';'  { 
                             if(strcmp(symboleType(t,$2),"INT")==0)
                                printf("%d\n",(int)symboleVal(t,$2));
                             else if(strcmp(symboleType(t,$2),"FLOAT"))
                                printf("%f\n",symboleVal(t,$2));
                             else
                                printf("%d\n",(bool)symboleVal(t,$2));
                            }
                ;
print_string:PRINT STRING ';' {int i;for(i=1;i<strlen($2)-1;i++)printf("%c",($2)[i]);printf("\n");}
%%

int main(){
    t=createSymboleTable();
    q=createQuadrupleTable();
    identifiers = NULL;
    yyparse();
    if(t)
    printSymboleTable(t);
    deleteSymboleTable(t);
    return 0;
}
SymboleTable* createSymboleTable(){
    SymboleTable* symboleTable =(SymboleTable*)malloc(sizeof(SymboleTable));
    symboleTable->symboles = (Symbole**)calloc(MINIMUM_ELEMENT_IN_SYMBOLE_TABLE,sizeof(Symbole));
    symboleTable->keys = (int*) calloc(MINIMUM_ELEMENT_IN_SYMBOLE_TABLE,sizeof(int));
    symboleTable->nbElements=0;
    symboleTable->length = MINIMUM_ELEMENT_IN_SYMBOLE_TABLE;
    return symboleTable;
}
