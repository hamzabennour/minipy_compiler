/*
 * Copyright (c) 2023 BENNOUR HAMZA and BENHADDA ZINA
 * All rights reserved.
 *
 */

This project is a simple miniPython compiler created using Flex and Bison. Below are the commands you will need to compile and run this program.

Prerequisites
Make sure you have the following tools installed:

Flex: A tool for generating lexical analyzers (scanners).
GCC: The GNU Compiler Collection, for compiling C programs.
Bison (if needed): A parser generator.
Useful Commands
============================== Generating the Lexical Analyzer
To generate the lexical analyzer using Flex, run:

bash
Copier le code
flex [file_name].l
This will produce a lex.yy.c file, which contains the generated lexical analyzer.

============================== Compiling the Lexical Analyzer
To compile the generated analyzer into an executable, use the following command:

bash
Copier le code
gcc lex.yy.c -o [executable_name].exe -lfl
This will create an executable file named [executable_name].exe.

============================== Running the Program
Once compiled, you can execute the program with the following command:

bash
Copier le code
.\[executable_name].exe
Replace [executable_name] with the actual name of your executable.


/*========================== Important ===============================================*/
 

Si vous souhaiter tester avec des fichier autres que 'exemple.txt' et 'exemple1.txt',

il faudra faire un saut de ligne vers la fin du fichier tout comme flex 
( de preference avec 0 car, j'ai essaye et ça a marche avec plusieurs car vides )

/*====================================================================================*/
