# preprocess the dir (delete the 1, 4, 16 dir)

#root="/users/jtran989/cs491/hw4/dense-linear-algebra-Astrolace/" -- ran from root of repository
up="../"
output_array=("inner_prod_output/" "matvec_output/" "matvec_2d_output/" "cannon_output/")
child_array=("1" "4" "16")

for output in "${output_array[@]}"
do
	cd ${output}
	for child in "${child_array[@]}"
	do
		[[ -d ${child} ]] && rm -r ${child} # remove the three cases for 1, 4, and 16 nodes
	done
	#rm -r -d 1 4 16 
	cd ${up}
done

./dense_run_script.sh -n i
./dense_run_script.sh -p i
./dense_run_script.sh -t i

./dense_run_script.sh -n m
./dense_run_script.sh -p m
./dense_run_script.sh -t m

./dense_run_script.sh -n m2
./dense_run_script.sh -p m2
./dense_run_script.sh -t m2

./dense_run_script.sh -n c
./dense_run_script.sh -p c
./dense_run_script.sh -t c
