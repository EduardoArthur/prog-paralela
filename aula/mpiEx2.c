#include <mpi.h>
#include <stdio.h>

#define N 9
main (int argc, char** argv[]) {

    int rank, size;
    int tag = 0;
    int a[N];
    
    MPI_Status status;

    MPI_Init(&argc, &argv);
    
    
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    printf("Eu sou %d de %d\n", rank, size);

    int msgSize = N/size;
    
    if (rank == 0) {
        for (int i=0; i < N; i++){
            a[i] = i * (-1);
        }
        for (int i=1; i < size; i++){
            if (i == size - 1) {
                MPI_Send(a + (msgSize * i), N - (msgSize * i), MPI_INT, i, tag, MPI_COMM_WORLD);
            } else {
                MPI_Send(a + (msgSize * i), msgSize, MPI_INT, i, tag, MPI_COMM_WORLD);
            }
        }
    } else {
        if (rank == size - 1) {
            MPI_Recv(a, N - (msgSize * rank), MPI_INT, 0, tag, MPI_COMM_WORLD, &status);
        } else {
            MPI_Recv(a, msgSize, MPI_INT, 0, tag, MPI_COMM_WORLD, &status);
        }

        printf(" Processo %d: ", rank);
        for (int i=0; i < N; i++){
            printf(" %d ", a[i]);
        }
        printf("\n");
    }
    
    MPI_Finalize();
    return 0;

}
