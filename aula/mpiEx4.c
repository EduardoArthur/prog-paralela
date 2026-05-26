#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>

#define DEFAULT_SIZE 10

double dot_product(double x[], double y[], int n) {
    int i;
    double result = 0.0;
    for (int i = 0; i < n; i++) {
        result += x[i] * y[i];
    }
    printf("Resultado Parcial %f \n", result);
    return result;
}

int main (int argc, char *argv[]) {

    int rank, size;
    int tag = 0;
    int N;
    double *a, *b;
    double resultFinal = 0.0;
    double resultParcial = 0.0;

    MPI_Status status;

    MPI_Init(&argc, &argv);
    
    
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    
    printf("Eu sou %d de %d\n", rank, size);

    
    if (rank == 0) {

        if (argc > 1) {
            N = atoi(argv[1]);
        } else {
            N = DEFAULT_SIZE;
        }

        a = (double *)malloc(N * sizeof(double)); 
        b = (double *)malloc(N * sizeof(double));

        for (int i=0; i < N; i++){
            a[i] = 1.0;
            b[i] = 1.0;
        }
        
    } 

    MPI_Bcast(&N, 1, MPI_INT, 0, MPI_COMM_WORLD);

    int n_bar = N/size;

    double* local_x = (double *)malloc(N * sizeof(double));
    double* local_y = (double *)malloc(N * sizeof(double));

    MPI_Scatter(a, n_bar, MPI_DOUBLE, local_x, n_bar, MPI_DOUBLE, 0, MPI_COMM_WORLD);
    MPI_Scatter(b, n_bar, MPI_DOUBLE, local_y, n_bar, MPI_DOUBLE, 0, MPI_COMM_WORLD);

    resultParcial = dot_product(a, b, n_bar);

    free(local_x);
    free(local_y);

    MPI_Reduce(&resultParcial, &resultFinal, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD);

    if (rank == 0) {
        printf("Valor Final: %f \n", resultFinal);
    }
    MPI_Finalize();
    return 0;

}