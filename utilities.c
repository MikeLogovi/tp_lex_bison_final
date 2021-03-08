#include<string.h>
#include<stdbool.h>
#include"utilities.h"
#include<math.h>
char* getExpressionType(float value){
    if(value == 0 || value ==1)
        return "BOOL";
    value = fabs(value);
    if((value - (int)value) == 0.0)
        return "INT";
    return "FLOAT";
}
bool  areTypesCompatibable(char* type1,char* type2){
    if(strcmp(type1,"BOOL")==0){
        if(strcmp(type2,"BOOL")==0)
            return true;
        if(strcmp(type2,"INT")==0)
            return false;
        if(strcmp(type2,"FLOAT")==0)
            return false;
    }
    if(strcmp(type1,"INT")==0){
        if(strcmp(type2,"BOOL")==0)
            return true;
        if(strcmp(type2,"INT")==0)
            return true;
        if(strcmp(type2,"FLOAT")==0)
            return false;
    }
    return true;
}
int nbDigits(int value){
    if(!value)
        return 1;
    int result=0;
    if(value<0) result++;
    while(value){
        value/=10;
        result++;
    }
    return result;
}