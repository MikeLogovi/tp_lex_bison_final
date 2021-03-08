#ifndef __SYMBOLE_TABLE__
#define __SYMBOLE_TABLE__
#define MINIMUM_ELEMENT_IN_SYMBOLE_TABLE 1000000
typedef struct SymboleTable SymboleTable;
typedef struct Symbole Symbole;
struct Symbole{
    char name[15];
    char type[6];
    bool isConstant;
    bool isSet;
    float value;
    
};
struct SymboleTable{
    Symbole **symboles;
    int* keys;
    int nbElements;
    int length;
};
SymboleTable* createSymboleTable();
extern void deleteSymboleTable(SymboleTable* symboleTable);
extern int hash(SymboleTable* t,char* s);
extern void insertSymbole(SymboleTable** symboleTable,Symbole* symbole);
extern Symbole* createSymbole(char* name,char* type,bool isConstant,bool isSet,float value);
extern void deleteSymbole(Symbole* s);
extern void updateSymbole(SymboleTable *t,char* s,char type[],float value);
extern int symbolExists(SymboleTable *t,char* s);
extern float symboleVal(SymboleTable *t,char* s);
extern char* symboleType(SymboleTable *t,char* s);
extern void setSymboleConstant(SymboleTable *t,char* s);
extern void printSymboleTable(SymboleTable *t);

#endif