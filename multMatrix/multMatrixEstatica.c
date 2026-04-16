#include <omp.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#define M 5000

double a[M][M];
double b[M][M];
double c[M][M];

int main(int argc, char * argv[]) {
    int N;
    int i, j, k;
    struct timeval tstart, tend;
    
    if (argc > 1) N = atoi(argv[1]);
    else N = M;
     
    for (i = 0; i < N; i++)  
        for (j = 0; j < N; j++) {
            c[i][j] = 0;
            a[i][j] = 1; 
            b[i][j] = 1; 
        }

    // Pega o tempo de início
    gettimeofday(&tstart, NULL);
    
    // Multiplicacao de matrizes
    #pragma omp parallel private(i, j, k)
    {
        #pragma omp for
        for (i = 0; i < N; i++) {
            for (j = 0; j < N; j++) {
                c[i][j] = 0;
                for (k = 0; k < N; k++) {
                    c[i][j] = c[i][j] + a[i][k] * b[k][j];
                }
            }
        }
    }
    
    // Pega o tempo de fim
    gettimeofday(&tend, NULL); 
    
    double elapsed_seconds = (tend.tv_sec - tstart.tv_sec) + ((tend.tv_usec - tstart.tv_usec) / 1000000.0);

    printf("Tempo de execucao: %f segundos\n", elapsed_seconds);

    return 0;
}