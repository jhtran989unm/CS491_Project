#include <mpi.h>
#include <math.h>
#include <stdlib.h>
#include <iostream>
#include <assert.h>

#include "raptor.hpp"
#include "util/linalg/external/parmetis_wrapper.hpp"

// Personal Addition
#include <fstream>


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
    ParVector tmp = ParVector(A->global_num_rows, A->local_num_rows);


    int n_iter = 30; // changed from 5
    double bnorm = b.norm(2);

    /*
     * create data file to store the five data values in
     * - Hybrid time
     * - Hybrid residual
     * - Repartition time
     * - Repartitioned Hybrid time
     * - Repartitioned Hybrid residual
     */
    ofstream dataFile;
    dataFile.open ("data.txt", ios_base::app);
  
    // Jacobi
    x.set_const_value(1.0);
    MPI_Barrier(MPI_COMM_WORLD);
    t0 = MPI_Wtime();
    jacobi(A, x, b, tmp, n_iter);
    tfinal = MPI_Wtime() - t0;
    MPI_Reduce(&tfinal, &t0, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);
    if (rank == 0) printf("Jacobi Time : %e\n", t0);

    // write Jacobi time
    // dataFile << t0 << "\n";

    A->residual(x, b, tmp);
    double norm = tmp.norm(2);
    double residualJacobi = norm/bnorm;
    if (rank == 0) printf("Relative Residual %e\n\n", residualJacobi);

    // write Jacobi residual
    // dataFile << residualJacobi << "\n";

    // Hybrid Jacobi/GS
    x.set_const_value(1.0);
    MPI_Barrier(MPI_COMM_WORLD);
    t0 = MPI_Wtime();
    ssor(A, x, b, tmp, n_iter);
    tfinal = MPI_Wtime() - t0;
    MPI_Reduce(&tfinal, &t0, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);
    if (rank == 0) printf("Hybrid Jacobi Time : %e\n", t0);

    // write Hybrid time
    dataFile << t0 << "\n";

    A->residual(x, b, tmp);
    norm = tmp.norm(2);
    double residualHybrid = norm/bnorm;
    if (rank == 0) printf("Relative Residual %e\n\n", residualHybrid);

    // write Hybrid residual
    dataFile << residualHybrid << "\n";

    // Repartitioning : 
    MPI_Barrier(MPI_COMM_WORLD);
    t0 = MPI_Wtime();
    int* parts = parmetis_partition(A);
    std::vector<int> new_local_rows;
    ParCSRMatrix* A_part = repartition_matrix(A, parts, new_local_rows);
    ParVector x_part = ParVector(A_part->global_num_cols, A_part->on_proc_num_cols);
    ParVector b_part = ParVector(A_part->global_num_rows, A_part->local_num_rows);
    ParVector tmp_part = ParVector(A_part->global_num_rows, A_part->local_num_rows);
    x_part.set_rand_values();
    A_part->mult(x_part, b_part);
    tfinal = MPI_Wtime() - t0;
    MPI_Reduce(&tfinal, &t0, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);
    if (rank == 0) printf("Repartition Time : %e\n\n", t0);

    // write Repartition time
    dataFile << t0 << "\n";

    // Repartitioned Jacobi
    x_part.set_const_value(1.0);
    MPI_Barrier(MPI_COMM_WORLD);
    t0 = MPI_Wtime();
    jacobi(A_part, x_part, b_part, tmp_part, n_iter);
    tfinal = MPI_Wtime() - t0;
    MPI_Reduce(&tfinal, &t0, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);
    if (rank == 0) printf("Repartitioned Jacobi Time : %e\n", t0);
    A_part->residual(x_part, b_part, tmp_part);
    norm = tmp_part.norm(2);
    if (rank == 0) printf("Relative Residual %e\n\n", norm/bnorm);

    // Repartitioned Hybrid Jacobi/GS
    x_part.set_const_value(1.0);
    MPI_Barrier(MPI_COMM_WORLD);
    t0 = MPI_Wtime();
    ssor(A_part, x_part, b_part, tmp_part, n_iter);
    tfinal = MPI_Wtime() - t0;
    MPI_Reduce(&tfinal, &t0, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);
    if (rank == 0) printf("Repartitioned Hybrid Jacobi Time : %e\n", t0);

    // write Repartitioned Hybrid time
    dataFile << t0 << "\n";

    A_part->residual(x_part, b_part, tmp_part);
    norm = tmp_part.norm(2);
    double residualRepartHybrid = norm/bnorm;
    if (rank == 0) printf("Relative Residual %e\n", residualRepartHybrid);

    // write Repartitioned Hybrid residual
    dataFile << residualRepartHybrid << "\n";

    delete A;

    MPI_Finalize();

    // close the file
    dataFile.close();

    return 0;
}
