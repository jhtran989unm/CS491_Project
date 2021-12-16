# -------------------------------------------
# move cleaning to individual run script...
# actually, can't since the script is called multiple times (3, one for each type of parallel)...
# -------------------------------------------

# preprocess the dir (delete the 1, 4, 16 dir)

#root="/users/jtran989/cs491/hw4/dense-linear-algebra-Astrolace/" -- ran from root of repository
# up="../"
# output_array=("relaxation_output/")
# matrix_dir_array=("gr_30_30_output/")
#child_array=("1" "4" "16")

# called at the root of the repo

# matrix name (used for the others below)
# see run script (changed...)
# TODO: !!!REMEMBER TO UPDATE!!! -- need to find some way to read from a file, like .json
# already did gr_30_30, now just the others
matrix_name_array=("bcsstm07" "ex3" "Journals" "nasa2146" "Trefethen_700")
# matrix_name_array=("gr_30_30")

# matrix_dir_array=("nasa2146_output/")
matrix_dir_array=()
for matrix_name in "${matrix_name_array[@]}"
do
	matrix_dir_array+=(${matrix_name}"_output/")
done

# clean out directory after each run (from artifacts of debugging...)
for matrix_dir in "${matrix_dir_array[@]}"
do
	[[ -d ${matrix_dir} ]] && rm -r ${matrix_dir}
done

./run_script.sh -n
./run_script.sh -p
./run_script.sh -t
