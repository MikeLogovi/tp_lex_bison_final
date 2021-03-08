%{
   #include<stdio.h>
   #include<stdlib.h>
   #include<stdbool.h>
   #include<string.h>
   #include "symbole_table.h"
   #include "quadruples.h"
   #include "utilities.h"
   extern void setSymboleType(SymboleTable* t,char*s,char*type);
   void addQuadruple();
   void addLabel();
   void createLabel();
   void createLabelIf();
   void createLabelElse();
   void createLabelFor();
   void pushLabelStack(char*);
   char* popLabelStack();
   void pushStack(char*);
   char* pop();
   extern int yylex();
   extern void yyerror(char* err);
  struct Stack{
    char *items[10000];
    int top;
  }Stk;
   struct LabelStack{
   char *items[10000];
   int top;
  }Label;    
  SymboleTable* t ;
  QuadrupleTable* q;
  int temp_var=0;
  int temp_label_var=0;
  int temp_label_if_var=0;
  int temp_label_else_var=0;
  int temp_label_for_var=0;
  char temp_label[20];
  char temp_label2[20];
  Symbole* s;
  char myType[6]; 
  char currentType[6];
%}
%start program
%token BEGIN_ END_ IDENTIFIER CONST  INT FLOAT BOOL  NUMBER STRING IF ELSE FOR COMMENT AFF INC DEC NEWLINE PRINT AND OR NOT
%left GE LE EQ NE DIFF '>' '<'
%left '+' '-'
%left '/' '*' '%'
%left INC DEC
%left OR
%left AND
%left NOT
%nonassoc UMINUS

%union{
    float float_val;
    char identifier[11];
    char type[6];
    char string[10000];
}
%type<identifier> IDENTIFIER  dec_begin
%type <identifier> assignment
%type<type> type INT FLOAT BOOL
%type<float_val> expression NUMBER  increment decrement  condition computation complexe
%type<string> STRING
%%
program: declarations core  
       ;
declarations:  
            | declaration declarations
           ;
declaration: CONST type {strcpy(currentType,$2);}  dec_begin_const listidentifiers_const
           | type {strcpy(currentType,$1);} dec_begin listidentifiers
           ;
dec_begin: IDENTIFIER                { s = createSymbole($1 ,"" ,false,false,0); insertSymbole(&t,s);setSymboleType(t,s->name,currentType);}
         | IDENTIFIER '=' expression { s = createSymbole($1 ,"" ,false,true,$3); insertSymbole(&t,s);setSymboleType(t,s->name,currentType);}
         ;
dec_begin_const:IDENTIFIER           { s = createSymbole($1 ,"" ,true,false,0); insertSymbole(&t,s);setSymboleType(t,s->name,currentType);setSymboleConstant(t,s->name);}
               |IDENTIFIER '=' expression { s = createSymbole($1 ,"" ,true,true,$3); insertSymbole(&t,s);setSymboleType(t,s->name,currentType);setSymboleConstant(t,s->name);}
               ;
listidentifiers:',' IDENTIFIER { s = createSymbole($2 ,"" ,false,false,0); insertSymbole(&t,s);setSymboleType(t,s->name,currentType);} listidentifiers  
               | ',' IDENTIFIER '=' expression  { s = createSymbole($2 ,"" ,false,true,$4); insertSymbole(&t,s);setSymboleType(t,s->name,currentType);} listidentifiers  
               | ';'
               ;
listidentifiers_const: ',' IDENTIFIER '=' expression { s = createSymbole($2 ,"" ,true,true,$4); insertSymbole(&t,s); setSymboleType(t,s->name,currentType);setSymboleConstant(t,s->name);} listidentifiers_const  
               |       ',' IDENTIFIER  {s = createSymbole($2 ,"" ,true,false,0); insertSymbole(&t,s); setSymboleType(t,s->name,currentType);setSymboleConstant(t,s->name);} listidentifiers_const      
               | ';'
               ;
type: INT     { strcpy($$,$1);}
    | FLOAT   { strcpy($$,$1);}
    | BOOL    { strcpy($$,$1);}
    ;
core:BEGIN_ main_core END_ {;}
    ;
main_core: 
         | list_instructions
         ;
list_instructions: instruction list_instructions
                 | instruction
instruction:      assignment ';'
                 | COMMENT
                 | if_statement
                 | for_loop
                 | increment ';'
                 | decrement ';'
                 | print 
                 ;
assignment:IDENTIFIER affectation  IDENTIFIER   { strcpy(myType,getExpressionType(symboleVal(t,$3)));updateSymbole(t,$1,myType,symboleVal(t,$3));
                                                  Quadruple *qd =createQuadruple("=",$3,"_",$1);
                                                  insertQuadruple(&q,qd);
                                                }
          |IDENTIFIER affectation  NUMBER       { strcpy(myType,getExpressionType($3));updateSymbole(t,$1,myType,$3);
                                                  char temp[10];
                                                  snprintf(temp,10,"%f",$3);
                                                  Quadruple *qd =createQuadruple("=",temp,"_",$1);
                                                  insertQuadruple(&q,qd);  
                                                }
          |IDENTIFIER affectation  computation    {strcpy(myType,getExpressionType($3));updateSymbole(t,$1,myType,$3);
                                                    Quadruple *qd =createQuadruple("=",pop(),"_",$1);
                                                    insertQuadruple(&q,qd);
                                                  }
          |IDENTIFIER affectation  condition    {  strcpy(myType,getExpressionType($3));updateSymbole(t,$1,myType,$3);
                                                   Quadruple *qd =createQuadruple("=",pop(),"_",$1);
                                                   insertQuadruple(&q,qd);
                                                }
          |IDENTIFIER affectation  complexe    {strcpy(myType,getExpressionType($3));updateSymbole(t,$1,myType,$3);
                                                 Quadruple *qd =createQuadruple("=",pop(),"_",$1);
                                                 insertQuadruple(&q,qd);
                                               }
          |IDENTIFIER affectation  IDENTIFIER INC    {float value = symboleVal(t,$3); 
                                                      strcpy(myType,getExpressionType(value)); 
                                                      updateSymbole(t,$1,myType,value);
                                                      updateSymbole(t,$3,myType,value+1);
                                                      Quadruple *qd =createQuadruple("=",$3,"_",$1);
                                                      insertQuadruple(&q,qd);
                                                      char temp[10];snprintf(temp,10,"%d",1); 
                                                      pushStack(temp);pushStack($3); 
                                                      addQuadruple("+"); 
                                                      Quadruple *qd1 =createQuadruple("=",pop(),"_",$3);
                                                      insertQuadruple(&q,qd1);    
                                                      }
           |IDENTIFIER affectation  INC IDENTIFIER     {float value = symboleVal(t,$4); 
                                                         strcpy(myType,getExpressionType(value)); 
                                                         updateSymbole(t,$1,myType,value+1);
                                                         updateSymbole(t,$4,myType,value+1);
                                                         char temp[10];snprintf(temp,10,"%d",1); 
                                                         pushStack(temp);pushStack($4); 
                                                         addQuadruple("+"); 
                                                         Quadruple *qd1 =createQuadruple("=",pop(),"_",$4);
                                                         insertQuadruple(&q,qd1); 
                                                         Quadruple *qd =createQuadruple("=",$4,"_",$1);
                                                          insertQuadruple(&q,qd);   
                                                       }
          |IDENTIFIER affectation  IDENTIFIER DEC    {
                                                      float value = symboleVal(t,$3); 
                                                      strcpy(myType,getExpressionType(value)); 
                                                      updateSymbole(t,$1,myType,value);
                                                      updateSymbole(t,$3,myType,value-1);
                                                      Quadruple *qd =createQuadruple("=",$3,"_",$1);
                                                      insertQuadruple(&q,qd);
                                                      char temp[10];snprintf(temp,10,"%d",1); 
                                                      pushStack(temp);pushStack($3); 
                                                      addQuadruple("-"); 
                                                      Quadruple *qd1 =createQuadruple("=",pop(),"_",$3);
                                                      insertQuadruple(&q,qd1);                                                         
                                                      }
            |IDENTIFIER affectation  DEC IDENTIFIER     { float value = symboleVal(t,$4); 
                                                          strcpy(myType,getExpressionType(value)); 
                                                          updateSymbole(t,$1,myType,value-1);
                                                          updateSymbole(t,$4,myType,value-1);
                                                          char temp[10];snprintf(temp,10,"%d",1); 
                                                          pushStack(temp);pushStack($4); 
                                                          addQuadruple("-"); 
                                                          Quadruple *qd1 =createQuadruple("=",pop(),"_",$4);
                                                          insertQuadruple(&q,qd1); 
                                                          Quadruple *qd =createQuadruple("=",$4,"_",$1);
                                                           insertQuadruple(&q,qd);   
                                                        }                                           
          ;
expression:  IDENTIFIER                      {  $$=symboleVal(t,$1);
                                                pushStack($1);
                                             } 
           | NUMBER                          {  $$ = $1; 
                                                char temp[10];
                                                snprintf(temp,10,"%f",$1);   
                                                pushStack(temp);  
                                             }
           | computation                     {$$ =$1;}
           | condition                       {$$ = $1;}
           | complexe                        {$$ = $1; }
complexe:    '(' increment ')'               {$$ = $2;}
           | '(' decrement ')'               {$$ = $2; }
           | '(' expression ')'              {$$ = $2;}
           | '-' expression                  {$$ = -$2;}
           | '+' expression                  {$$ = $2;}
           ;
           
computation: expression  '+'  expression     {$$ = $1 + $3; addQuadruple("+");}
           | expression  '-'  expression     {$$ = $1 - $3; addQuadruple("-");}
           | expression  '*'  expression     {$$ = $1 * $3;addQuadruple("*"); }
           | expression  '%'  expression     {if($3==0) yyerror("Erreur, division par zéro non autorisée\n"); if(strcmp(getExpressionType($1),"FLOAT")==0 || strcmp(getExpressionType($3),"FLOAT")==0)yyerror("Opération autorisée uniquement pour les entiers autorisée\n");$$ = ((int)$1) % ((int)$3);addQuadruple("%"); }
           | expression  '/'  expression     {if($3==0) yyerror("Erreur, division par zéro non autorisée\n"); else $$ = $1 / $3;addQuadruple("/");}        
           ;
condition: expression  '<'  expression       {$$ = $1 < $3;addQuadruple("lt");}
         | expression  '>'  expression       {$$ = $1 > $3;addQuadruple("gt");}
         | expression  NE  expression        {$$ = $1 != $3;addQuadruple("ne");}
         | expression  EQ  expression        {$$ = $1 == $3;addQuadruple("eq");}
         | expression  LE  expression        {$$ = $1 <= $3;addQuadruple("lte");}
         | expression  GE  expression        {$$ = $1 >= $3;addQuadruple("gte");}
         | expression  AND  expression       {$$ = $1 && $3;addQuadruple("and");}
         | expression  OR  expression        {$$ = $1 || $3;addQuadruple("or");}
         | NOT expression                    {$$ = !$2  ;char str[5],str1[5]="t";sprintf(str, "%d", temp_var); strcat(str1,str);temp_var++;Quadruple *qd1 =createQuadruple("not",pop(),"_",str1);insertQuadruple(&q,qd1);sprintf(str, "%d", !$2);pushStack(str);}

         ;
affectation:AFF
           |'=';
list_computation:computation 
                |inc_dec     
                ;
inc_dec:increment
       |decrement
       ;
list_assignments: assignment
                ;
increment:INC IDENTIFIER                    {float value = symboleVal(t,$2); strcpy(myType,getExpressionType(value)); updateSymbole(t,$2,myType,value+1); $$ =value +1; char temp[10];snprintf(temp,10,"%d",1); pushStack(temp);pushStack($2); addQuadruple("+"); Quadruple *qd =createQuadruple("=",pop(),"_",$2);insertQuadruple(&q,qd); }
         |IDENTIFIER INC                    {char temp[10];snprintf(temp,10,"%d",1); pushStack(temp);pushStack($1); addQuadruple("+"); Quadruple *qd =createQuadruple("=",pop(),"_",$1);insertQuadruple(&q,qd);   float value = symboleVal(t,$1); strcpy(myType,getExpressionType(value)); $$ =value; updateSymbole(t,$1,myType,value+1); }
         ; 
decrement:DEC IDENTIFIER                    {float value = symboleVal(t,$2); strcpy(myType,getExpressionType(value)); updateSymbole(t,$2,myType,value-1); $$ =value -1; char temp[10];snprintf(temp,10,"%d",1); pushStack(temp);pushStack($2); addQuadruple("-"); Quadruple *qd =createQuadruple("=",pop(),"_",$2);insertQuadruple(&q,qd); }
         |IDENTIFIER DEC                    {char temp[10];snprintf(temp,10,"%d",1); pushStack(temp);pushStack($1); addQuadruple("-"); Quadruple *qd =createQuadruple("=",pop(),"_",$1);insertQuadruple(&q,qd); float value = symboleVal(t,$1); strcpy(myType,getExpressionType(value)); updateSymbole(t,$1,myType,value-1); $$ =value;}
         ;

if_statement: simple_if  
            | simple_if ELSE {createLabelElse() ;addLabel();}'{' job '}'  
            ;
simple_if:IF {createLabelIf();addLabel()} '(' condition  ')' {createLabel();strcpy(temp_label,popLabelStack());Quadruple *qd =createQuadruple("jez",pop(),"_",temp_label);insertQuadruple(&q,qd);}'{' job '}' {pushLabelStack(temp_label);addLabel();}
for_loop: FOR {createLabelFor();addLabel()} '(' assignment ';'  {createLabel();strcpy(temp_label2,popLabelStack());Quadruple *qd =createQuadruple("_","_","_",temp_label2);insertQuadruple(&q,qd);} condition ';' {createLabel();strcpy(temp_label,popLabelStack());Quadruple *qd =createQuadruple("jez",pop(),"_",temp_label);insertQuadruple(&q,qd);} compteur ')' '{' job '}'        {Quadruple *qd =createQuadruple("jump","_","_",temp_label2);insertQuadruple(&q,qd);pushLabelStack(temp_label);addLabel();}         
        ;
job:
   |list_instructions
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
    FILE* f = fopen("quadruplets.txt","w");
    if(!f)
        yyerror("Erreur de creation du fichier des quadruplets\n");
    Stk.top = -1;
    Label.top = -1;
    t=createSymboleTable();
    q=createQuadrupleTable();
    yyparse();
    if(t)
    if(t->nbElements)
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
void pushStack(char *str)
{
    Stk.top++;
    Stk.items[Stk.top]=(char *)malloc(strlen(str)+1);
  strcpy(Stk.items[Stk.top],str);
}
char * pop()
{
  int i;
  if(Stk.top==-1)
  {
     printf("\nPile vide!! \n");
     exit(0);
  }
  char *str=(char *)malloc(strlen(Stk.items[Stk.top])+1);;
  strcpy(str,Stk.items[Stk.top]);
  Stk.top--;
  return(str);
}
void pushLabelStack(char *str)
{
  Label.top++;
    Label.items[Label.top]=(char *)malloc(strlen(str)+1);
  strcpy(Label.items[Label.top],str);
}
char * popLabelStack()
{
  int i;
  if(Label.top==-1)
  {
     printf("\nPile vide!! \n");
     exit(0);
  }
  char *str=(char *)malloc(strlen(Label.items[Label.top])+1);;
  strcpy(str,Label.items[Label.top]);
  Label.top--;
  return(str);
}
void  createLabel(){
     char str[5],str1[5]="L";
     sprintf(str, "%d:", temp_label_var);     
     strcat(str1,str);
     temp_label_var++;
     pushLabelStack(str1);
} 
void  createLabelIf(){
     char str[20],str1[20]="IF";
     sprintf(str, "%d:", temp_label_if_var);     
     strcat(str1,str);
     temp_label_if_var++;
     pushLabelStack(str1);
}     
void  createLabelElse(){
     char str[20],str1[20]="ELSE";
     sprintf(str, "%d:", temp_label_else_var);     
     strcat(str1,str);
     temp_label_else_var++;
     pushLabelStack(str1);
}   
void  createLabelFor(){
     char str[20],str1[20]="FOR";
     sprintf(str, "%d:", temp_label_for_var);     
     strcat(str1,str);
     temp_label_for_var++;
     pushLabelStack(str1);
}   
void addLabel(){
    Quadruple *qd =createQuadruple("_","_","_",popLabelStack());
    insertQuadruple(&q,qd);  
}
void addQuadruple(char op[]){
     char str[5],str1[5]="t";
     sprintf(str, "%d", temp_var);       
     strcat(str1,str);
     temp_var++;
     char a[20];
     char b[20];
     strcpy(a,pop());
     strcpy(b,pop());
     Quadruple *qd =createQuadruple(op,b,a,str1);
     insertQuadruple(&q,qd);
     pushStack(str1);
}
