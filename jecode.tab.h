/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     BEGIN_ = 258,
     END_ = 259,
     IDENTIFIER = 260,
     CONST = 261,
     INT = 262,
     FLOAT = 263,
     BOOL = 264,
     NUMBER = 265,
     STRING = 266,
     IF = 267,
     ELSE = 268,
     FOR = 269,
     COMMENT = 270,
     AFF = 271,
     INC = 272,
     DEC = 273,
     NEWLINE = 274,
     PRINT = 275,
     AND = 276,
     OR = 277,
     NOT = 278,
     DIFF = 279,
     NE = 280,
     EQ = 281,
     LE = 282,
     GE = 283,
     UMINUS = 284
   };
#endif
/* Tokens.  */
#define BEGIN_ 258
#define END_ 259
#define IDENTIFIER 260
#define CONST 261
#define INT 262
#define FLOAT 263
#define BOOL 264
#define NUMBER 265
#define STRING 266
#define IF 267
#define ELSE 268
#define FOR 269
#define COMMENT 270
#define AFF 271
#define INC 272
#define DEC 273
#define NEWLINE 274
#define PRINT 275
#define AND 276
#define OR 277
#define NOT 278
#define DIFF 279
#define NE 280
#define EQ 281
#define LE 282
#define GE 283
#define UMINUS 284




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 54 "jecode.y"
{
    float float_val;
    char identifier[11];
    char type[6];
    char string[10000];
}
/* Line 1529 of yacc.c.  */
#line 114 "jecode.tab.h"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;

