%{
/*==========================Partie 1 : includes et inits===============================================*/
 #include <stdlib.h>
 #include <stdio.h>
 #include <string.h>

int yylex(void); 
int yyerror(char* s);
int col=1;	
int nbLine=1;
char sauvType[50];//Sauvegarder le type de l'entite
int sauvTypeVal;
char sauvOpr[5];//Sauvegarder l'operateur
int Fin_if=0,deb_else=0;//Pour mettre a jour les etiq
int qc=0;//On a pas eu le temps de terminer les quadruplets : (
%}
/*==========================Partie 2 : Grammaires ===============================================*/
%union 
{ 
   int entier;
   float real;
   char* str;
   struct
    {
     char* type;
     char* valeur;
   }t_exp_op;
}
%token  <entier>val_entier <real>val_flottant <str>val_char <str>mc_int <str>mc_float <str>mc_char <str>mc_bool <str>idf vrg NewLine bool_vrai bool_faux 
%token affect mc_if deuxPoints parentOuvrante parentFermante 
%token crochetG crochetD mc_while mc_for mc_inRange mc_in mc_else INDENT UNINDENT sep_apos
%token op_div op_mul op_add op_sub op_and op_or op_not
%token op_diff op_eg op_inf op_infg op_sup op_supg
%left op_or 
%left op_and
%left op_not
%left op_add op_sub 
%left op_mul op_div
%right parentFermante parentOuvrante
%start S

%%
//Le programme minipy est un ensemble de lignes
S : LIGNES {printf("\nSUCCESS: Programme syntaxiquement correct\n\n");YYACCEPT;}
;
LIGNES: LIGNE LIGNES | LIGNE// (derniere instruction pas la peine ???)//je pense que si mais bon 
;

//Une ligne peut contenir soit une insruction sequentiel: comme une declaration ou une affectation
//Ou bien une instruction non sequentielles: c.a.d une instruction conditionelle ou une boucle 
LIGNE: INST_SEQ NewLine | INST_NON_SEQ
;

//Une instruction sequentielle est soit: une declaration, une affectation
//Ou une declaration et affectation a la fois, exemple: int Cpt = 5 
INST_SEQ: DECLARATION | INST_AFF | DEC_AFF //| EXPRESSION_LOG
;

//On declare soit une seule variable, soit plusieurs separees par des virgules
DECLARATION: TYPE LIST_IDF 
;
LIST_IDF: IDF vrg LIST_IDF |IDF
; 

//Un identificateur peut etre soit un nom de tableau ou une variable simple
IDF: idf  {if(doubleDeclaration($1)==0){
              insererTYPE($1,sauvType);
              }
            else  
                {printf("\nERREUR SEMANTIQUE ligne %d: Double declaration  de \"%s\"\n\n",nbLine-1,$1);
                exit(1);}
        }
 | IDF_TAB
;

//le tableau est sous la forme Tableau[taille]
IDF_TAB:idf crochetG BORNE_TAILLE crochetD 
 {  if (sauvTypeVal>0) {
        //printf("TEST %d\n",sauvTypeVal);

        //traiter le cas de double declaration
           if(doubleDeclaration($1)==0)
                insererTYPE($1,sauvType); 
        else{
            printf("\nERREUR SEMANTIQUE ligne %d: Double declaration  de \"%s\"\n\n",nbLine-1,$1);
            exit(1);}
        }
    else if(sauvTypeVal==0) 
        {printf("\nERREUR SEMANTIQUE ligne %d colonne %d: taille de tableau nulle\n\n ",nbLine, col); 
         exit(1);}
    else
        {printf("\nERREUR SEMANTIQUE ligne %d colonne %d: taille de tableau negative (%d)\n\n ",nbLine, col,sauvTypeVal); 
         exit(1);}
 }
;

//Les differents types de minipy
TYPE:  mc_int  {strcpy(sauvType,$1);}
      |mc_float {strcpy(sauvType,$1);}
      |mc_char {strcpy(sauvType,$1);}
      |mc_bool {strcpy(sauvType,$1);}
;

//La taille du tableau qui doit etre une valeur entiere strictement positive 
BORNE_TAILLE: val_entier  {
    sauvTypeVal=$1;
    //printf("%d\n",$1);

    }   | val_flottant {{printf("\nERREUR SEMANTIQUE ligne %d colonne %d: La taille ne peut pas etre un flottant\n\n ",nbLine, col); 
         exit(1);}}     
;

//Les instruction non sequentielle c'est soit des conditionelle ou des boucles
INST_NON_SEQ: INST_ALT_COND |INST_BOUCLE
;

//L'instuction  alternative avec indent et unindent pour prendre en consideration le debut d'un bloc
INST_ALT_COND: mc_if parentOuvrante EXP_LOG_COMP parentFermante deuxPoints NewLine INDENT LIGNES UNINDENT ELSE
;

//la partie else est optionelle
ELSE: |mc_else deuxPoints NewLine INDENT LIGNES UNINDENT
;

//il y a deux grands types de boucles: soit for soit while
INST_BOUCLE: INST_BOUCLE_WHILE | INST_BOUCLE_FOR
;

//la boucle while teste soit avec une expression logique ou de comparaison ou une fusion des deux
//l'essentiel c'est la valeur de retour la cond est soit 0 ou 1
//avec biensur indent et unindent pour marquer le debut et la fin d'un bloc 
INST_BOUCLE_WHILE: mc_while parentOuvrante EXP_LOG_COMP parentFermante deuxPoints NewLine INDENT LIGNES UNINDENT
;

//La boucle for elle meme dans minipy contient deux types
INST_BOUCLE_FOR: INST_BOUCLE_FOR1 | INST_BOUCLE_FOR2
;

//le 1er type de la boucle for
INST_BOUCLE_FOR1: mc_for idf mc_inRange parentOuvrante CONSTANTE vrg CONSTANTE parentFermante deuxPoints NewLine INDENT LIGNES UNINDENT
;

//le 2eme type 
INST_BOUCLE_FOR2: mc_for idf mc_in IDF_TAB deuxPoints NewLine INDENT LIGNES UNINDENT
;

//Declarer et affecter une valeur à un idf en une instruction
DEC_AFF: TYPE idf affect EXP_ARTH_VAL 
         {if(doubleDeclaration($2)==0)
                     insererTYPE(sauvType,$2);
            else  
                printf("\nERREUR SEMANTIQUE ligne %d: Double declaration  de \"%s\"\n\n",nbLine-1,$2);
        }
;

//L'affectation
INST_AFF: idf SUITE_INST_AFF
 /* {
                    if(doubleDeclaration($1)==0){
                        printf("\nErreur semantique: Non declaration de {{%s}} a la ligne [%d]\n\n",$1,nb_ligne);
                    }

                    if(cc==1)
                        {
                            printf("\nErreur semantique: Non declaration de {{%s}} a la ligne [%d]\n\n",NomIdf2,nb_ligne);
                            cc=0;
                        }}*/
;

//On peut affecter soit a un tableau ou un idf regulier
SUITE_INST_AFF: crochetG val_entier crochetD affect EXP_ARTH_VAL| affect EXP_ARTH_VAL
;

//On affecte soit une expression arithmetique soit un operande simple (y compris un char)
EXP_ARTH_VAL: EXPRESSION_ARITH | OPERANDE | sep_apos val_char sep_apos
;

//La condition est soit une expression logique soit 
//une expression de comparaison (fusionne plusieurs cas avec arithm et comp et log)
EXP_LOG_COMP:EXPRESSION_COMP|EXPRESSION_LOG;

//une expression arithmetique peut ou pas avoir des parentheses 
EXPRESSION_ARITH:EXPRESSION_SPAR
                |EXPRESSION_PAR;

//expression arithmetique sans parentheses 
EXPRESSION_SPAR: OPERANDE OPERATEUR_ARITH OPERANDE 
    

          |OPERANDE OPERATEUR_ARITH EXPRESSION_ARITH

//expression arithmetiques sans parentheses       
OPERATEUR_ARITH:  op_add {strcpy(sauvOpr,"+");}
         | op_sub {strcpy(sauvOpr,"-");}
         | op_mul {strcpy(sauvOpr,"*");}
         | op_div {strcpy(sauvOpr,"/");}
         | op_and {strcpy(sauvOpr,"and");}
         | op_or {strcpy(sauvOpr,"or");}
         | op_not  {strcpy(sauvOpr,"not");}
;

//expression arithmetique avec parenthese 
EXPRESSION_PAR: parentOuvrante EXPRESSION_SPAR parentFermante
          | parentOuvrante EXPRESSION_PAR parentFermante
          | parentOuvrante EXPRESSION_SPAR parentFermante OPERATEUR_ARITH EXPRESSION_ARITH
          | parentOuvrante EXPRESSION_SPAR parentFermante OPERATEUR_ARITH OPERANDE
          | parentOuvrante EXPRESSION_PAR parentFermante OPERATEUR_ARITH EXPRESSION_PAR
          | parentOuvrante EXPRESSION_PAR parentFermante OPERATEUR_ARITH OPERANDE
          | parentOuvrante EXPRESSION_PAR parentFermante OPERATEUR_ARITH EXPRESSION_SPAR
;

//les operandes 
OPERANDE: val_entier|val_flottant|idf

;

//Les expressions de comparaison
//une expression de comparaison peut etre soit avec ou sans parentheses
EXPRESSION_COMP: EXPRESSION_COMP_SP | EXPRESSION_COMP_P;
//Une expression de comparaison sans parenthese est une comparaison entre deux expression arithmetiques
//simples (operandes) ou pas  
EXPRESSION_COMP_SP:EXP_ARTH_VAL OPERATEUR_COMP EXP_ARTH_VAL;
//bah on rajoute juste les parenthses 
EXPRESSION_COMP_P: parentOuvrante EXPRESSION_COMP_SP parentFermante;

//les differents operateurs de comparaison 
OPERATEUR_COMP: op_diff | op_eg | op_inf | op_infg | op_sup | op_supg;

//une expression logique peut etre soit unaire soit binaire
EXPRESSION_LOG:EXPRESSION_LOG_BI | EXPRESSION_LOG_UN;

//une expression logique binaire peut etre soit avec ou sans parentheses
EXPRESSION_LOG_BI: EXPRESSION_LOG_BI_SP| EXPRESSION_LOG_BI_P;
EXPRESSION_LOG_BI_P: parentOuvrante EXPRESSION_LOG_BI_SP parentFermante;

//Une expression logiques contient une operation logiques entre deux operandes logiques 
//simples ou pas
EXPRESSION_LOG_BI_SP:OPERANDE_LOG OPERATEUR_LOG EXPRESSION_LOG 
| EXPRESSION_LOG_UN OPERATEUR_LOG OPERANDE_LOG
| EXPRESSION_LOG_UN OPERATEUR_LOG EXPRESSION_LOG
| OPERANDE_LOG OPERATEUR_LOG OPERANDE_LOG
; 

EXPRESSION_LOG_UN: op_not EXPRESSION_LOG_BI_P | op_not EXPRESSION_LOG_UN |op_not OPERANDE_LOG; 

//Un operande logique peut etre soit une expression de comparaisn, la valeur vrai ou la valaur faux
OPERANDE_LOG: EXPRESSION_COMP_P | bool_vrai|bool_faux;
OPERATEUR_LOG: op_and | op_or;

//les constantes 
CONSTANTE: val_entier 
          |val_flottant 
;

%%
/*==========================Partie 3 : Appel du main ===============================================*/
int main()
{
printf("\n****************************************** DEBUT ***************************************\n");
initialisation();

   yyparse();
afficher();
return 0;
}
//pour la fin 
 yywrap()
{}

//pour les erreurs
int yyerror (char *msg ) { 
        printf ("\nERREUR SYNTAXIQUE: ligne %d colonne %d\n\n",nbLine,col); 
        return 1; }


/*========================== Merci !!! ===============================================*/