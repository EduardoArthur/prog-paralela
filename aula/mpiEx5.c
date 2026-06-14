#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>

#define DEFAULT_SIZE 8

double a[DEFAULT_SIZE][DEFAULT_SIZE];
double b[DEFAULT_SIZE][DEFAULT_SIZE];
double c[DEFAULT_SIZE][DEFAULT_SIZE];

int main(int argc, char * argv[]) {
    int N;
    int i, j, k;
    int rank, size;
    
    int tag = 0;

    MPI_Status status;

    MPI_Init(&argc, &argv);
    
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
     
     if (rank == 0) {
        if (argc > 1) {
            N = atoi(argv[1]);
        } else {
            N = DEFAULT_SIZE;
        }
        for (i = 0; i < N; i++)  {
            for (j = 0; j < N; j++) {
                c[i][j] = 0;
                a[i][j] = 1; 
                b[i][j] = 1; 
            }
        }
     }
    


    int sizeMatriz = N/size;
    
    // Multiplicacao de matrizes

    MPI_Bcast(&N, 1, MPI_INT, 0, MPI_COMM_WORLD);
    MPI_Bcast(&sizeMatriz, 1, MPI_INT, 0, MPI_COMM_WORLD);

    //double* local_a = (double *)malloc(N * sizeof(double));
    MPI_Scatter(a, sizeMatriz * N, MPI_DOUBLE, a, sizeMatriz * N, MPI_DOUBLE, tag, MPI_COMM_WORLD);

    MPI_Bcast(b, N*N, MPI_DOUBLE, 0, MPI_COMM_WORLD);
        
    for (i = 0; i < sizeMatriz; i++) {
        for (j = 0; j < N; j++) {
            c[i][j] = 0;
            for (k = 0; k < N; k++) {
                c[i][j] = c[i][j] + a[i][k] * b[k][j];
            }
        }
    }

    if (rank == 1 ) {
        printf("\n Matriz rank 1 \n");
        for (i = 0; i < sizeMatriz; i++) {
            for (j = 0; j < N; j++) {
                printf("%f ", c[i][j]);
            }
            printf("\n");
        }
    }

    MPI_Gather(c, sizeMatriz*N, MPI_DOUBLE, c, sizeMatriz*N, MPI_DOUBLE, tag, MPI_COMM_WORLD);

    if (rank == 0) {
        printf("\n Matriz rank 0 \n");
        for (i = 0; i < N; i++) {
            for (j = 0; j < N; j++) {
                printf("%f ", c[i][j]);
            }
            printf("\n");
        }
        printf("\n");
    }

    MPI_Finalize();

    return 0;
}