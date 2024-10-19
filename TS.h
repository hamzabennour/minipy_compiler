//****************************************table de symboles********************************************************8
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
typedef struct elm
{
    int state;
    char name[50];
    char code[50];
    char type[50];
    float val;
    int sub;
    struct elm *suiv;
} element;
typedef struct eltm
{
    int state;
    char name[50];
    char code[50];
    char type[50];
    struct eltm *suiv;
} elt;

typedef element *Pelement; // cste et var
typedef elt *Pelt;         // separateur et mot cle
typedef struct lists
{
    Pelement Tete;
    Pelement Queue;
    int compt_tokens;
} Liste_elment;
typedef struct listsm
{
    Pelt Tete;
    Pelt Queue;
    int compt_tokens;
} Liste_elt;

Liste_elment *tab;
Liste_elt *sepataeurs, *motCles;

//-----------------------fonctions ---------------------------------
void initialisation()
{

    tab = (Liste_elment *)malloc(sizeof(Liste_elment));
    tab->Queue = NULL;
    tab->Tete = NULL;
    tab->compt_tokens = 0;

    sepataeurs = (Liste_elt *)malloc(sizeof(Liste_elt));
    sepataeurs->Queue = NULL;
    sepataeurs->Tete = NULL;
    sepataeurs->compt_tokens = 0;

    motCles = (Liste_elt *)malloc(sizeof(Liste_elt));
    motCles->Queue = NULL;
    motCles->Tete = NULL;
    motCles->compt_tokens = 0;
}
void inserer(char entite[], char code[], char type[], float val, int i, int y)
{

    switch (y)
    {
    case 0: /*insertion dans la table des IDF et CONST*/
    {
        Pelement newElmnt = (Pelement)malloc(sizeof(element));
        newElmnt->suiv = NULL;
        newElmnt->state = 1;
        newElmnt->val = val;
        strcpy(newElmnt->name, entite);
        strcpy(newElmnt->code, code);
        strcpy(newElmnt->type, type);

        if (tab->Tete == NULL)
        {
            tab->Tete = newElmnt;
            tab->Queue = newElmnt;
        }
        else
        {
            tab->Queue->suiv = newElmnt;
            tab->Queue = tab->Queue->suiv;
        }
        tab->compt_tokens++; // incrementer le nb d' entite
        break;
    }

    case 1: /*insertion dans la table des mots clés*/
    {

        Pelt newElmnt = (Pelt)malloc(sizeof(elt));
        newElmnt->suiv = NULL;
        newElmnt->state = 1;
        strcpy(newElmnt->name, entite);
        strcpy(newElmnt->code, code);
        strcpy(newElmnt->type, type);

        if (motCles->Tete == NULL)
        {
            motCles->Tete = newElmnt;
            motCles->Queue = newElmnt;
        }
        else
        {
            motCles->Queue->suiv = newElmnt;
            motCles->Queue = motCles->Queue->suiv;
        }
        motCles->compt_tokens++;
        break;
    }

    case 2: /*insertion dans la table des séparateurs*/
    {

        Pelt newSeprateur = (Pelt)malloc(sizeof(elt));
        newSeprateur->suiv = NULL;
        newSeprateur->state = 1;
        strcpy(newSeprateur->name, entite);

        strcpy(newSeprateur->code, code);

        strcpy(newSeprateur->type, type);

        if (sepataeurs->Tete == NULL)
        {
            sepataeurs->Tete = newSeprateur;
            sepataeurs->Queue = newSeprateur;
        }
        else
        {
            sepataeurs->Queue->suiv = newSeprateur;
            sepataeurs->Queue = sepataeurs->Queue->suiv;
        }
        sepataeurs->compt_tokens++;
        break;
    }
    }
}
void recherche(char entite[], char code[], char type[], float val, int y)
{
    int j, i;
    Pelement pelement = tab->Tete;
    Pelt pelt = NULL;
    switch (y)
    {

    case 0:
    {

        while (pelement != NULL && (strcmp(entite, pelement->name) != 0))
        {
            pelement = pelement->suiv;
        }
        if (pelement == NULL)
            inserer(entite, code, type, val, i, 0);
        else
            // printf("Entite \"%s\" existe deja dans la TS\n", entite);
            break;
    }

    case 1: /*verifier si la case dans la tables des mots clés est libre*/
    {
        pelt = motCles->Tete;

        while (pelt != NULL && (strcmp(entite, pelt->name) != 0))
        {
            pelt = pelt->suiv;
        }
        if (pelt == NULL)
            inserer(entite, code, type, val, i, 1);
        break;
    }
    case 2: /*verifier si la case dans la tables des séparateurs est libre*/
    {
        pelt = sepataeurs->Tete;
        while (pelt != NULL && (strcmp(entite, pelt->name) != 0))
        {
            pelt = pelt->suiv;
        }
        if (pelt == NULL)
            inserer(entite, code, type, val, i, 2);

        break;
    }
    } /* fin switch*/
}

void afficher()
{

    Pelement pelement = tab->Tete;
    Pelt pelt = NULL;

    printf("\n******************************************Table des symboles IDF***************************************\n");
    printf("____________________________________________________________________\n");
    printf("\t| Nom_Entite |  Code_Entite | Type_Entite | Val_Entite\n");
    printf("____________________________________________________________________\n");

    while (pelement != NULL)
    {
        printf("\t|%10s |%15s | %12s | %12f\n", pelement->name, pelement->code, pelement->type, pelement->val);
        pelement = pelement->suiv;
    }
    printf("____________________________________________________________________\n");
    printf("Nombre Total des symboles IDF : %d  \n", tab->compt_tokens);

    printf("\n/***************Table des symboles Mot Cles*************/\n");
    printf("____________________________________________________________________\n");
    printf("\t| Nom_Entite |  Code_Entite | Type_Entite | \n");
    printf("____________________________________________________________________\n");
    pelt = motCles->Tete;
    while (pelt != NULL)
    {
        printf("\t|%10s |%15s | %12s\n", pelt->name, pelt->code, pelt->type);
        pelt = pelt->suiv;
    }
    printf("____________________________________________________________________\n");
    printf("Nombre Total des symboles Mot Cles : %d  \n", motCles->compt_tokens);

    printf("\n/***************Table des symboles Separateurs*************/\n");
    printf("____________________________________________________________________\n");
    printf("\t| Nom_Entite |  Code_Entite | Type_Entite | \n");
    printf("____________________________________________________________________\n");
    pelt = sepataeurs->Tete;
    while (pelt != NULL)
    {
        printf("\t|%10s |%15s | %12s\n", pelt->name, pelt->code, pelt->type);
        pelt = pelt->suiv;
    }
    printf("____________________________________________________________________\n");
    printf("Nombre Total des symboles Separateurs : %d  \n", sepataeurs->compt_tokens);
}

Pelement Get_Position(char entite[])
{
    Pelement pelement = tab->Tete;

    while (pelement != NULL)
    {
        if (strcmp(entite, pelement->name) == 0)
            return pelement;
        pelement = pelement->suiv;
    }
    return NULL;
}
int doubleDeclaration(char entite[])
{
    Pelement pos;
    pos = Get_Position(entite);
    if (strcmp(pos->type, "") == 0 && pos != NULL)
    {
        // printf("%s\n", pos->name);
        return 0;
    }
    else
        return -1;
}
/*
char* Get_TypeEn(char entite[])
{
  Pelement pos =Get_Position(entite);
  return pos->type;
}
*/

void insererTYPE(char entite[], char type[])
{
    Pelement pos;
    pos = Get_Position(entite);
    if (pos != NULL)
    {
        strcpy(pos->type, type);
    }
}

/*
void insererVAL(char entite[], float val)
{
  int pos;
  pos=Get_Position(entite);
  if(pos!=-1)  { tab[pos].val=val; }
}
*/

/*
int GetTaille (char entite[],int cst)
{
 int pos;
 pos=  Get_Position(entite);
 if (tab[pos+1].val>cst)
   return 0;
   else return 1;
}*/
