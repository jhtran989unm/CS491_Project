import sys
from convert_petsc import convert


if __name__ == "__main__":
    if len(sys.argv) == 1:
        print(f"ERROR. Please enter a file input as an argument.")
    else:  # assume only 1 argument was given...
        list_args = list(sys.argv)
        #print(f"{list_args}")

        matrix_mtx = list_args[1]
        split_matrix_mtx = matrix_mtx.split(".")

        matrix_pm = split_matrix_mtx[0] + ".pm"

        convert(matrix_mtx, matrix_pm)

