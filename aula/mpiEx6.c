#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>

#define DEFAULT_SIZE 8

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
     }
    
    MPI_Bcast(&N, 1, MPI_INT, 0, MPI_COMM_WORLD);

    int sizeMatriz = N/size;
    
    // Multiplicacao de matrizes
    
    double *a = NULL;
    double *c = NULL;

    double *b = (double *)malloc(N * N * sizeof(double));
    double *local_a = (double *)malloc(sizeMatriz * N * sizeof(double));
    double *local_c = (double *)malloc(sizeMatriz * N * sizeof(double));
        
    if (rank == 0) {
        a = (double *)malloc(N * N * sizeof(double));
        c = (double *)malloc(N * N * sizeof(double));
        
        for (i = 0; i < N; i++)  {
            for (j = 0; j < N; j++) {
                c[i * N + j] = 0;
                a[i * N + j] = 1; 
                b[i * N + j] = 1; 
            }
        }
    }

    MPI_Bcast(b, N*N, MPI_DOUBLE, 0, MPI_COMM_WORLD);

    MPI_Scatter(a, sizeMatriz * N, MPI_DOUBLE, local_a, sizeMatriz * N, MPI_DOUBLE, tag, MPI_COMM_WORLD);
        
    for (i = 0; i < sizeMatriz; i++) {
        for (j = 0; j < N; j++) {
            local_c[i * N + j] = 0;
            for (k = 0; k < N; k++) {
                local_c[i * N + j] = local_c[i * N + j] + local_a[i * N + k] * b[k * N + j];
            }
        }
    }

    if (rank == 1 ) {
        printf("\n Matriz rank 1 \n");
        for (i = 0; i < sizeMatriz; i++) {
            for (j = 0; j < N; j++) {
                printf("%f ", local_c[i * N + j]);
            }
            printf("\n");
        }
    }

    MPI_Gather(local_c, sizeMatriz * N, MPI_DOUBLE, c, sizeMatriz * N, MPI_DOUBLE, tag, MPI_COMM_WORLD);

    if (rank == 0) {
        printf("\n Matriz rank 0 \n");
        for (i = 0; i < N; i++) {
            for (j = 0; j < N; j++) {
                printf("%f ", c[i * N + j]);
            }
            printf("\n");
        }
        printf("\n");
    }

    if (rank == 0) {
        free(a);
        free(c);
    }
    free(b);
    free(local_a);
    free(local_c);

    MPI_Finalize();

    return 0;
}