#ifndef __QUADRUPLES__H
#define __QUADRUPLES__H
typedef struct Quadruple Quadruple;
struct Quadruple{
    char operation[5];
    char argument1[11];
    char argument2[11];
    char result[11];
};
typedef struct QuadrupleTable QuadrupleTable;
struct QuadrupleTable{
    Quadruple** quadruples;
    int length;
    int nbElements;
};
extern QuadrupleTable* createQuadrupleTable();
extern Quadruple* createQuadruple(char*,char*,char*,char*);
extern void insertQuadruple(QuadrupleTable **quadrupleTable,Quadruple *quadruple);
#endif