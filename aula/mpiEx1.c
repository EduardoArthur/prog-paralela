#include <mpi.h>
#include <stdio.h>

#define N 5
main (int argc, char** argv[]) {

    int rank, size;
    int tag = 0;
    int a[N];
    
    MPI_Status status;

    MPI_Init(&argc, &argv);
    
    
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    printf("Eu sou %d de %d\n", rank, size);
    
    if (rank == 0) {
        for (int i=0; i < N; i++){
            a[i] = i * (-1);
        }
        for (int i=1; i < size; i++){
            MPI_Send(a, N, MPI_INT, i, tag, MPI_COMM_WORLD);
        }
    } else {
        MPI_Recv(a, N, MPI_INT, 0, tag, MPI_COMM_WORLD, &status);
        printf(" Processo %d: ", rank);
        for (int i=0; i < N; i++){
            printf(" %d ", a[i]);
        }
        printf("\n");
    }
    
    MPI_Finalize();
    return 0;

}
