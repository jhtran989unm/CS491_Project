# preprocess the dir (delete the 1, 4, 16 dir)

#root="/users/jtran989/cs491/hw4/dense-linear-algebra-Astrolace/" -- ran from root of repository
up="../"
output_array=("relaxation_output/")
matrix_dir_array=("gr_30_30_output/")
#child_array=("1" "4" "16")

for matrix_dir in "${matrix_dir_array[@]}"
do
	[[ -d ${matrix_dir} ]] && rm -r ${matrix_dir}
done

# for output in "${output_array[@]}"
# do
# 	[[ -d ${output} ]] && rm -r ${output}
#
# 	# cd ${output}
# # 	for child in "${child_array[@]}"
# # 	do
# # 		[[ -d ${child} ]] && rm -r ${child} # remove the three cases for 1, 4, and 16 nodes
# # 	done
# # 	#rm -r -d 1 4 16
# # 	cd ${up}
# done

./run_script.sh -n
./run_script.sh -p
./run_script.sh -t

# ./dense_run_script.sh -n i
# ./dense_run_script.sh -p i
# ./dense_run_script.sh -t i
#
# ./dense_run_script.sh -n m
# ./dense_run_script.sh -p m
# ./dense_run_script.sh -t m
#
# ./dense_run_script.sh -n m2
# ./dense_run_script.sh -p m2
# ./dense_run_script.sh -t m2
#
# ./dense_run_script.sh -n c
# ./dense_run_script.sh -p c
# ./dense_run_script.sh -t c
