%{
/*==========================Partie 1 : includes et inits===============================================*/
    int nbChar=0,nbWord=0;
    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>
    #include "synt.tab.h"
    #include "TS.h"
    #include "quadruplets.h"
    
extern  int col; //nombre de colonne
extern int nbLine;//nombre de lignes
int current_line_indent = 0;//Indentation de ligne courante 
int indent_level = 0;//Niveau d'indentation 
extern YYSTYPE yylval;
/*==========================Partie 2 : les regex !===============================================*/
%}

newline "\n"
chiffre [0-9]
intNonSigne [1-9]{chiffre}*|0
intSigne {parentOuvrante}([+-]({intNonSigne})){parentFermente}
floatNonSigne ({intNonSigne})\.{chiffre}+
floatSigne {parentOuvrante}((\+|\-){floatNonSigne}){parentFermente}
caractere [a-zA-Z]
bool_vrai "true"  
bool_faux "false"
idf [A-Z][0-9a-z]+
comment_T1 ^"#".*\n 
comment_T2  "#".*/\n
int "int "
float "float "
char "char "
bool "bool "
typeVar "TYPE "
typeTab "type "
if "if"
else "else"
for "for"
inRange "in range"
in "in "
while "while"
virgule ","
apostrophe "'"
plus "+"
moins "-"
fois "*"
div "/"
and "and "
or "or "
not "not"
infOuEgal "<="
supOuEgal ">="
egal "=="
affectation "="
inf "<"
sup ">"
different "!="
parentOuvrante "("
parentFermente ")"
crochetGauche "["
crochetDroit "]"
deuxPoints ":"


%x indent

%%

<indent>" "      { 
  /*==========================Partie 3 : les actions !===============================================*/
  //PS: <indent>" " fait partie de la partie 3 bien sur, c'est juste que j'ai pas pu mettre ce comment en haut
  //a cause de la sensibilite de FLEX !!!
  //printf("TEST1\n");
current_line_indent++; }
<indent>"\t"     { //printf("TEST2\n");
current_line_indent = (current_line_indent +4 ) & ~3; }
<indent>"\n"     { //printf("TEST3\n"); 
current_line_indent = 0;}
<indent>.        {
                   //printf("TEST5\n");
                   unput(*yytext);
                   printf("Niveau: %d Indent courant: %d\n",indent_level,current_line_indent);
                   if (current_line_indent > 4*indent_level+3) {
                    //Si la ligne courante contient une tabulation ou plus (par rapport a la ligne precedente)
                    //alors augmenter le niveau d'indentation
                       indent_level++;
                       printf("indent\n");
                       return INDENT;
                   } else if (current_line_indent < 4*indent_level) {
                    //Si la ligne courante est moins indentee que la ligne precedent alors
                    //diminuer le niveau d'indentation (sortir du bloc)
                       indent_level--;
                        printf("UNINDENT\n");
                       return UNINDENT;
                   } else {
                    //printf("TEST6\n");
                    BEGIN INITIAL;
                   }
                 }
<indent><<EOF>>         {
                    if (current_line_indent < 4*indent_level) {
                        indent_level -= 1;
                        //Cas ou il plusieurs sortie de bloc s'accumenlent vers la fin du fichier
                        return UNINDENT;
                    } else return 1;
                }
{newline}     {//printf("TEST4\n"); 
current_line_indent = 0;
col=0;
++nbLine; 
BEGIN indent;
return NewLine;}

{idf} {recherche (yytext,"idf","",0, 0); col = col + strlen(yytext);
    if (yyleng <=8 ) { 
           yylval.str=strdup(yytext); 
         printf("L'entite \"%s\" de type \"Identificateur\" est reconnue\n",yytext);}
     else {printf("\nERREUR LEXICALE: L'entite \"%s\" de type \"Identificateur\" est trop longue\n\n",yytext);
    exit(1);}
   nbChar+=yyleng; ++nbWord; return idf;
    }

{floatSigne} {
    char * token = strtok(yytext,"(");//Enlever les parenthese dans les floats signee
   char * token1 = strtok(yytext,")");
   float float_yytext = atof(token);
   yylval.real=float_yytext;
    //inserer dans la TS
    //apres avoir verifier si l'entite existe ou pas 
    recherche(token,"floatNonSigne","float",atof(token), 0);col = col + strlen(yytext);
    printf("L'entite \"(%s)\" de type \"Flottant\" est reconnue\n",token); 
nbChar+=yyleng; ++nbWord; return val_flottant;}

{floatNonSigne} { yylval.real=atof(yytext);
                 recherche(yytext,"floatNonSigne","float",atof(yytext), 0);col = col + strlen(yytext);
                printf("L'entite \"%s\" de type \"Flottant\" est reconnue\n",yytext); 
                nbChar+=yyleng; ++nbWord; return val_flottant;}
{intSigne} {
   
  char * token = strtok(yytext,"(");//Enlever les parenthese dans les ints signee
  char * token1 = strtok(yytext,")");
  int int_yytext = atoi(token);
    if(int_yytext <= 32767 && int_yytext >= -32768)
     { yylval.entier=int_yytext;
      printf("L'entite \"(%s)\" de type \"Entier\" est reconnue\n",token);
     recherche(token,"intSigne","int",atof(token),0);
     }
    else 
    {printf("\nERREUR LEXICALE: L'entite \"(%s)\" de type \"Entier\" est trop longue\n\n",token);
    yyterminate();}
    nbChar+=yyleng; ++nbWord;
    return val_entier;
}
{intNonSigne} {
    int int_yytext = atof(yytext);
    if(int_yytext <= 32767 && int_yytext >= -32768)
     { yylval.entier=int_yytext;
      printf("L'entite \"%s\" de type \"Entier\" est reconnue\n",yytext);
     recherche(yytext,"intNonSigne","int",atof(yytext),0); col = col + strlen(yytext);
     }
    else 
    {printf("\nERREUR LEXICALE: L'entite \"%s\" de type \"Entier\" est trop longue\n\n",yytext);
    yyterminate();}
    nbChar+=yyleng; ++nbWord;
    return val_entier;
}
{virgule} {recherche (yytext,"Separateur","",0, 2); col = col + strlen (yytext);printf("L'entite \"%s\" de type \"Separateur: %s\" est reconnue\n",yytext,yytext);nbChar+=yyleng; ++nbWord; return vrg;}
{apostrophe} {recherche (yytext,"Separateur","",0,2); col = col + strlen (yytext);printf("L'entite \"%s\" de type \"Separateur: %s\" est reconnue\n",yytext,yytext);nbChar+=yyleng; ++nbWord;return sep_apos;}
{infOuEgal} {recherche (yytext,"Separateur","",0, 2); col = col + strlen (yytext);printf("L'entite \"%s\" de type \"Separateur: %s\" est reconnue\n",yytext,yytext);nbChar+=yyleng; ++nbWord;return op_infg;}
{supOuEgal} {recherche (yytext,"Separateur","",0, 2); col = col + strlen (yytext);printf("L'entite \"%s\" de type \"Separateur: %s\" est reconnue\n",yytext,yytext);nbChar+=yyleng; ++nbWord;return op_supg;}
{egal} {recherche (yytext,"Separateur","",0, 2); col = col + strlen (yytext);printf("L'entite \"%s\" de type \"Separateur: %s\" est reconnue\n",yytext,yytext);nbChar+=yyleng; ++nbWord;return op_eg;}
{affectation} {recherche (yytext,"Separateur","",0, 2); col = col + strlen (yytext);printf("L'entite \"%s\" de type \"Separateur: %s\" est reconnue\n",yytext,yytext);nbChar+=yyleng; ++nbWord; return affect;}
{inf} {recherche (yytext,"Separateur","",0, 2); col = col + strlen (yytext);printf("L'entite \"%s\" de type \"Separateur: %s\" est reconnue\n",yytext,yytext);nbChar+=yyleng; ++nbWord;return op_inf;}
{sup} {recherche (yytext,"Separateur","",0, 2); col = col + strlen (yytext);printf("L'entite \"%s\" de type \"Separateur: %s\" est reconnue\n",yytext,yytext);nbChar+=yyleng; ++nbWord;return op_sup;}
{different} {recherche (yytext,"Separateur","",0, 2); col = col + strlen (yytext);printf("L'entite \"%s\" de type \"Separateur: %s\" est reconnue\n",yytext,yytext);nbChar+=yyleng; ++nbWord;return op_diff;}
{parentOuvrante} {recherche (yytext,"Separateur","",0, 2); col = col + strlen (yytext);printf("L'entite \"%s\" de type \"Separateur: %s\" est reconnue\n",yytext,yytext);nbChar+=yyleng; ++nbWord; return parentOuvrante;}
{parentFermente} {recherche (yytext,"Separateur","",0, 2); col = col + strlen (yytext);printf("L'entite \"%s\" de type \"Separateur: %s\" est reconnue\n",yytext,yytext);nbChar+=yyleng; ++nbWord; return parentFermante;}
{crochetGauche} {recherche(yytext,"Separateur","",0, 2); col = col + strlen (yytext);printf("L'entite \"%s\" de type \"Separateur: %s\" est reconnue\n",yytext,yytext);nbChar+=yyleng; ++nbWord; return crochetG;}
{crochetDroit} {recherche (yytext,"Separateur","",0, 2); col = col + strlen (yytext);printf("L'entite \"%s\" de type \"Separateur: %s\" est reconnue\n",yytext,yytext);nbChar+=yyleng; ++nbWord; return crochetD;}
{deuxPoints} {recherche(yytext,"Separateur","",0, 2); col = col + strlen (yytext);printf("L'entite \"%s\" de type \"Separateur: %s\" est reconnue\n",yytext,yytext);nbChar+=yyleng; ++nbWord; return deuxPoints;}
{plus} {recherche (yytext,"Separateur","",0, 2); col = col + strlen(yytext);printf("L'entite \"%s\" de type \"Separateur: %s\" est reconnue\n",yytext,yytext);nbChar+=yyleng; ++nbWord; return op_add;}
{moins} {recherche (yytext,"Separateur","",0, 2);  col = col + strlen(yytext);printf("L'entite \"%s\" de type \"Separateur: %s\" est reconnue\n",yytext,yytext);nbChar+=yyleng; ++nbWord;return op_sub;}
{fois} {recherche (yytext,"Separateur","",0, 2); col = col + strlen (yytext);printf("L'entite \"%s\" de type \"Separateur: %s\" est reconnue\n",yytext,yytext);nbChar+=yyleng; ++nbWord;return op_mul;}
{div} {recherche (yytext,"Separateur","",0, 2); col = col + strlen (yytext);printf("L'entite \"%s\" de type \"Separateur: %s\" est reconnue\n",yytext,yytext);nbChar+=yyleng; ++nbWord;return op_div;}
{and} {recherche (yytext,"Separateur","",0, 2); col = col + strlen (yytext);printf("L'entite \"%s\" de type \"Separateur: %s\" est reconnue\n",yytext,yytext);nbChar+=yyleng; ++nbWord;return op_and;}
{or} {recherche(yytext,"Separateur","",0, 2); col = col + strlen (yytext);printf("L'entite \"%s\" de type \"Separateur: %s\" est reconnue\n",yytext,yytext);nbChar+=yyleng; ++nbWord;return op_or;}
{not} {recherche (yytext,"Separateur","",0, 2); col = col + strlen (yytext);printf("L'entite \"%s\" de type \"Separateur: %s\" est reconnue\n",yytext,yytext);nbChar+=yyleng; ++nbWord;return op_not;}
{int} { yylval.str=strdup(yytext);recherche (yytext,"Mot cles"," ",0, 1); col = col + strlen(yytext);printf("L'entite \"%s\" de type \"Mot cles: %s\" est reconnue\n",yytext,yytext);nbChar+=yyleng; ++nbWord; return mc_int; }
{float} { yylval.str=strdup(yytext);recherche (yytext,"Mot cles"," ",0, 1); col = col + strlen(yytext);printf("L'entite \"%s\" de type \"Mot cles: %s\" est reconnue\n",yytext,yytext);nbChar+=yyleng; ++nbWord;return mc_float;}
{char} {yylval.str=strdup(yytext); recherche (yytext,"Mot cles"," ",0, 1); col = col + strlen(yytext);printf("L'entite \"%s\" de type \"Mot cles: %s\" est reconnue\n",yytext,yytext);nbChar+=yyleng; ++nbWord;return mc_char;}
{bool} { yylval.str=strdup(yytext);recherche (yytext,"Mot cles"," ",0, 1); col = col + strlen(yytext);printf("L'entite \"%s\" de type \"Mot cles: %s\" est reconnue\n",yytext,yytext);nbChar+=yyleng; ++nbWord;return mc_bool;}
{typeVar} {recherche (yytext,"Mot cles"," ",0, 1); col = col + strlen(yytext);printf("L'entite \"%s\" de type \"Mot cles: %s\" est reconnue\n",yytext,yytext);nbChar+=yyleng; ++nbWord;}
{typeTab} {recherche (yytext,"Mot cles"," ",0, 1); col = col + strlen(yytext);printf("L'entite \"%s\" de type \"Mot cles: %s\" est reconnue\n",yytext,yytext);nbChar+=yyleng; ++nbWord;}
{if} {recherche (yytext,"Mot cles","",0, 1); col = col + strlen(yytext);printf("L'entite \"%s\" de type \"Mot cles: %s\" est reconnue\n",yytext,yytext);nbChar+=yyleng; ++nbWord; return mc_if;}
{else} {recherche (yytext,"Mot cles"," ",0, 1); col = col + strlen(yytext);printf("L'entite \"%s\" de type \"Mot cles: %s\" est reconnue\n",yytext,yytext);nbChar+=yyleng; ++nbWord;return mc_else;}
{for} {recherche (yytext,"Mot cles"," ",0, 1); col = col + strlen(yytext);printf("L'entite \"%s\" de type \"Mot cles: %s\" est reconnue\n",yytext,yytext);nbChar+=yyleng; ++nbWord; return mc_for;}
{inRange} {recherche (yytext,"Mot cles"," ",0, 1); col = col + strlen(yytext);printf("L'entite \"%s\" de type \"Mot cles: %s\" est reconnue\n",yytext,yytext);
nbChar+=yyleng; ++nbWord; return mc_inRange;}
{in} {recherche (yytext,"Mot cles"," ",0, 1); col = col + strlen(yytext);printf("L'entite \"%s\" de type \"Mot cles: %s\" est reconnue\n",yytext,yytext); ++nbWord;return mc_in;}
{while} {recherche (yytext,"Mot cles"," ",0, 1); col = col + strlen(yytext);printf("L'entite \"%s\" de type \"Mot cles: %s\" est reconnue\n",yytext,yytext);nbChar+=yyleng; ++nbWord; return mc_while;}
{bool_vrai} {recherche (yytext,"Mot cles"," ",0, 1); col = col + strlen(yytext);printf("L'entite \"%s\" de type \"bool\" est reconnue\n",yytext);
nbChar+=yyleng; ++nbWord;
return bool_vrai;
}
{bool_faux} {recherche (yytext,"Mot cles"," ",0, 1); col = col + strlen(yytext);printf("L'entite \"%s\" de type \"bool\" est reconnue\n",yytext);
nbChar+=yyleng; ++nbWord;
return bool_faux;
}
{caractere} { yylval.str=strdup(yytext);
              recherche (yytext,"idf","char",atof(yytext), 0);
              printf("L'entite \"%s\" de type \"Caractere\" est reconnue\n",yytext);
              col = col + strlen(yytext);  nbChar+=yyleng; ++nbWord; return val_char;}
{comment_T1} {/*printf("PS: C'est un commentaire ! Ne rien faire\n"); */}
{comment_T2} {
/*y a deux type de commentaire le T1 vient au debut de la ligne donc
le \n est ignore avec le comment

y a aussi le T2 qui vient vers la fin du ligne donc le \n n'est pas pris avec le comment */}
" "  {}
. {printf("\nERREUR LEXICALE: Entite \"%s\" non reconnue\n\n",yytext);nbChar+=yyleng; ++nbWord; exit(1);}
%%


int white_count(char* line) {
  unsigned int count = 0 ;
  while (*line == ' ')
    count++, line++ ;

  return count ;
}//fonction qui compte le nombre d'espace vide....useless en vrai
