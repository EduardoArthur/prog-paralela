#include <math.h>
#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>

int main (int argc, char *argv[]) {
    int n, i;
    double mypi, pi, h, sum, x, a;
    int rank, size;
    int tag = 0;

    n = atoi(argv[1]);
    h = 1.0 / (double) n;
    sum = 0.0;

    MPI_Status status;

    MPI_Init(&argc, &argv);
    
    
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    MPI_Bcast(&n, 1, MPI_INT, 0, MPI_COMM_WORLD);

    int n_bar = (n/size);
    int start = rank * n_bar;
    double sum_local = 0.0;
    
    for (i = start + 1; i <= n_bar * (rank + 1); i ++) {
        x = h * ((double) i - 0.5);
        sum_local += 4.0 / (1.0 + x*x);
    }

    printf("sumLocal is approximately %.16f\n", sum_local);

    MPI_Reduce(&sum_local, &sum, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD);

    if (rank == 0) {
        mypi = h * sum;

        printf("pi is approximately %.16f\n", mypi);
    }
    
    MPI_Finalize();

    return 0;
}