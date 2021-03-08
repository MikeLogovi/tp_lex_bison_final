%{
   #include "jecode.tab.h"
   #include<stdlib.h>
   #include<errno.h>
   #include<string.h>
   extern YYSTYPE yylval;
   int yylcol=0;
   void yyerror(char *s) {
    fprintf(stderr, "line %d:%d: %s ", yylineno,yylcol, s);
    exit(EXIT_FAILURE);
   }
   char error[1000];
%}
%option yylineno
idf [A-Z](_?[0-9a-zA-Z])*
digit [0-9]+
cst ({digit}(\.{digit})?)|0
string ("\""(.|\n)*"\"")|("'"(.|\n)*"'")
%%
"BEGIN"   {yylcol+=yyleng;return BEGIN_;}
"END"     {yylcol+=yyleng;return END_;}
"If"      {yylcol+=yyleng; return IF;}
"else"    {yylcol+=yyleng; return ELSE;}
"For"     {yylcol+=yyleng;return FOR;}
"INT"     {strcpy(yylval.type,yytext);yylcol+=yyleng;return INT;}
"FLOAT"   {strcpy(yylval.type,yytext); yylcol+=yyleng;return FLOAT;}
"BOOL"    {strcpy(yylval.type,yytext); yylcol+=yyleng;return BOOL;}
"CONST"   {yylcol+=yyleng;return CONST;}
"print"   {yylcol+=yyleng; return PRINT;}
{idf} {
        yylcol+=yyleng;
        if(yyleng>10){
            sprintf(error,"La taille de l'identifiant %s doit être inferieure ou  égale à 10 caractères\n",yytext);
            yyerror(error);
        }
        else{
            if(yytext[strlen(yytext)-1]=='_'){
                sprintf(error,"Un identifiant ne doit pas se terminer par _ \n");
                yyerror(error);
            }
            strcpy(yylval.identifier,yytext);
             return IDENTIFIER;
        }   
      }

{cst} { yylcol+=yyleng;
        yylval.float_val = atof(yytext);
        return NUMBER;
      }
{string}        {yylcol+=yyleng;strcpy(yylval.string,yytext);return STRING;}
[+-<>/*(){};.=%] { yylcol+=yyleng;return yytext[0];}
">="            { yylcol+=yyleng;return GE; }
"<="            { yylcol+=yyleng;return LE; }
"=="            { yylcol+=yyleng;return EQ; }
"<>"            { yylcol+=yyleng;return NE; } 
":="            { yylcol+=yyleng;return AFF; }
"++"            { yylcol+=yyleng;return INC; }
"--"            { yylcol+=yyleng;return DEC; }
"&&"            { yylcol+=yyleng;return AND; }
"||"            { yylcol+=yyleng;return OR; }
"!"            { yylcol+=yyleng;return NOT; }
"/"\*[^*]*[^/]*\*"/" { yylcol+=yyleng; return COMMENT; }
[ \t\r]         { yylcol+=yyleng; }
[\n]            { yylcol=0; }   
.               { yylcol+=yyleng;yyerror("Erreur lexicale\n");   }
%%
int yywrap(void){
    return 1;
}