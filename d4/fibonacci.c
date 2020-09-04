/**
 * C-ohjelma Fibonaccin lukujen laskemiseen.
 * Demotehtävässä vastaava koodi annettu C#-kielellä ja tehtäväksi 
 * annettu kääntää ohjelma C-kielelle.
 */


#include<stdio.h>
#include<stdlib.h>

typedef struct _luku luku;

struct _luku  {
    int arvo;
    struct _luku *seuraava;
};

luku *lisaa(luku *lukujono, int arvo) {
    luku *uusi = NULL;
    uusi = malloc(sizeof(luku));
    uusi->arvo = arvo;
    uusi->seuraava = lukujono;
    return uusi;
}

void tyhjenna(luku *lukujono) {
    if (lukujono == NULL) return;
    luku *seuraava = lukujono->seuraava;
    free(lukujono);
    tyhjenna(seuraava);
}

luku *laske_fibo(luku *lukujono, int lkm) {
    for (int i=0; i<lkm; i++) {
      int e = lukujono->arvo;
      int ee = lukujono->seuraava->arvo;
      int uusi = e+ee;  // summa järkevintä laskea ilman erillistä aliohjelmaa
      lukujono = lisaa(lukujono, uusi);
    }
    return lukujono;
}

void tulosta_luvut(luku *lukujono) {
    luku *nykyinen = lukujono;
    if (nykyinen == NULL) return;
    tulosta_luvut(nykyinen->seuraava);
    printf("%d ",nykyinen->arvo);
}

int main(int argc, char **argv) {
    if (argc != 2) {
        printf("Anna argumenttina tulostettavien lukujen lukumäärä, joka on >= 2.\n");
        return 1;
    }

    int lkm = atoi(argv[1]);
    lkm = lkm - 2; // Lukumäärästä pois ekat kaksi

    if (lkm < 0) {
        printf("Lukumäärän tulee olla >= 2.");
        return 1;
    }

    luku *lukujono = lisaa(NULL, 1);
    lukujono = lisaa(lukujono, 1);

    // Fibonaccin lukujen laskeminen:

    lukujono = laske_fibo(lukujono, lkm);
    tulosta_luvut(lukujono);
    printf("\n");

    tyhjenna(lukujono);

    return 0;
}
