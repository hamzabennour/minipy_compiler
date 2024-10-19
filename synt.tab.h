
/* A Bison parser, made by GNU Bison 2.4.1.  */

/* Skeleton interface for Bison's Yacc-like parsers in C
   
      Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

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
     val_entier = 258,
     val_flottant = 259,
     val_char = 260,
     mc_int = 261,
     mc_float = 262,
     mc_char = 263,
     mc_bool = 264,
     idf = 265,
     vrg = 266,
     NewLine = 267,
     bool_vrai = 268,
     bool_faux = 269,
     affect = 270,
     mc_if = 271,
     deuxPoints = 272,
     parentOuvrante = 273,
     parentFermante = 274,
     crochetG = 275,
     crochetD = 276,
     mc_while = 277,
     mc_for = 278,
     mc_inRange = 279,
     mc_in = 280,
     mc_else = 281,
     INDENT = 282,
     UNINDENT = 283,
     sep_apos = 284,
     op_div = 285,
     op_mul = 286,
     op_add = 287,
     op_sub = 288,
     op_and = 289,
     op_or = 290,
     op_not = 291,
     op_diff = 292,
     op_eg = 293,
     op_inf = 294,
     op_infg = 295,
     op_sup = 296,
     op_supg = 297
   };
#endif



#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 1676 of yacc.c  */
#line 19 "synt.y"
 
   int entier;
   float real;
   char* str;
   struct
    {
     char* type;
     char* valeur;
   }t_exp_op;



/* Line 1676 of yacc.c  */
#line 107 "synt.tab.h"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;


