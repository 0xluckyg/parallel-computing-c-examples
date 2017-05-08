#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <string.h>

//gcc -g -Wall -fopenmp -o genprime genprime.c
//./genprime N t

void output(char *fileNumber, int *primeNumbers, int n, double tTaken) {
    FILE *f;
    char *fileName = malloc((strlen(fileNumber)+4) * sizeof(char));
    sprintf(fileName, "%d", n);
    strcat(fileName, ".txt");

    f = fopen(fileName, "w+");

    int i;
    int j = 0;
    int previousPrime = 2;
    for (i = 2; i < n; i++) {
        if (primeNumbers[i] != -1) {
            j++;
            int diff = i - previousPrime;
            previousPrime = i;
            fprintf(f, "%d %d %d\n", j, i, diff);
        }
    }

    fclose(f);
}

void genprime(char *argv1, char*argv2) {
    int n = atoi(argv1);
    int thread = atoi(argv2);
    int *primeList = calloc(n, sizeof(int));
    int mod;

    double tStart = 0.0, tTaken;

    omp_set_num_threads(thread);

    tStart = omp_get_wtime();
    for (mod=2; (mod*mod) < n; mod++) {
        if (primeList[mod] == -1) continue;
        int i;
        #pragma omp parallel for
        for (i = (mod*mod); i < n; i+=mod) {
            primeList[i] = -1;
        }
    }
    tTaken = omp_get_wtime() - tStart;
    printf("time taken: %f\n", tTaken);

    output(argv1, primeList, n, tTaken);
}

int main(int argc, char *argv[]) {
     if( argc != 3) {
        printf("Usage: ./genprime N t");
        exit(1);
    }
    if (atoi(argv[1]) < 2 || atoi(argv[1]) > 1000000) {
        printf("Usage: please make your N an integer between 2 and 1,000,000");
        exit(1);
    }
    if (atoi(argv[2]) < 1 || atoi(argv[2]) > 100) {
        printf("Usage: please make your t an integer between 1 and 100");
        exit(1);
    }
    genprime(argv[1], argv[2]);

    return 0;
}
