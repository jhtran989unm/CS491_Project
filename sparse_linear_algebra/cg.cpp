#include <mpi.h>
#include <math.h>
#include <stdlib.h>
#include <iostream>
#include <assert.h>

#include "raptor.hpp"

int main(int argc, char* argv[])
{
    MPI_Init(&argc, &argv);
    int rank, num_procs;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &num_procs);

    int iter;

    ParCSRMatrix* A;
    ParVector x;
    ParVector b;

    double t0, tfinal;
    double comm_t = 0;

    if (argc <= 1)
    {
        if (rank == 0) printf("Need Matrix Path as Command Line Arg\n");
        MPI_Finalize();
        return 0;
    }

    const char* file = argv[1];
    A = readParMatrix(file);
    x = ParVector(A->global_num_cols, A->on_proc_num_cols);
    b = ParVector(A->global_num_rows, A->local_num_rows);
    x.set_rand_values();
    A->mult(x, b);
    x.set_const_value(0.0);


    std::vector<double> new_res;
    comm_t = 0;
    CG(A, x, b, new_res, 1e-07, -1, &comm_t);
    iter = new_res.size() - 1;
    if (rank == 0) 
    {
        printf("Solved in %d iterations\n", iter);
    }

    delete A;

    MPI_Finalize();
    return 0;
}
