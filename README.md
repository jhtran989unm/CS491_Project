# README
## CS 491 Project 
### Relaxation - Hybrid Jacobi/Gauss Seidel
#### Stephanus Huang, Jiajun Guo, John Tran

-

List of `output` dir

- `bcsstm07_output` (unused) 
- `ex3_output	` 
- `gr_30_30_output`
- `Journals_output` (unused)
- `nasa2146_output` (unused)
- `Trefethen_700_output`

There will also be a `matrix_list.txt` file that contains all the matrices used to run the code with (some were unused, mentioned above) &mdash; all were gotten from the `suitesparse` link provided to us (more details in report).

As mentioned in the report, the `communication` bottleneck was scratched because we were not able to make Wheeler allocate only 1 process per node...so only `optimal` is left.

The dir hierarchy for each `output` dir above will be as follows:

`output` (matrix) dir -> `program output` dir -> `optimal` -> `process` dir -> `normal`/`profile`/`trace` dir

An example would be:

`gr_30_30_output` dir -> `repart_relax_output` dir -> `optimal` -> `1` dir -> `normal`/`profile`/`trace` dir

The `process` dir will have various dir with different number of processes (name is just the number of processes, like `1` or `32`). In each `process` dir (under `normal`/`profile`/`trace`), we will have output files corresponding to the `job` script in that dir.

In addition, we have the `plots_code` dir that has the `generate_plot.py` Python script that will generate the code from the data in each of the processes case (`1`, `2`, `4`, `8`, `16`, `32`) and store it in the root of the `program output` dir.

List of `shell` scripts:

- `run_script.sh`
- `run_script_niter.sh` (unused)
- `run_all_script.sh`

Once on wheeler, just type

```
$ ./run_all_script.sh
```

at the root of the project to submit all the jobs with matrices, processes, etc. specified in the `run_script.sh` script. For a list of options for `run_script.sh`, just use the `-h` option.

Then when all the data has been run, type 

```
$ ./run_script.sh -d
```

to consolidate all the data for each `program output` dir for each matrix (`output` dir) at the `program output` root and copy them over to the `plots_code` dir. Then type

```
$ ./run_script.sh -y
```

generate all the plots (timing and residual) for all the data files consolidated with the `-d` option -- stored in the `plots_code` dir with the corresponding matrix and program names used to generate the plot (e.g., `ex3_relax_repart_timing_plot.png`).

-




#### TODO

- create `python` script to create the `.pm` file from the `.mtx` file 
- finish the `shell` scripts
- add some more methods (other than `relaxation`)