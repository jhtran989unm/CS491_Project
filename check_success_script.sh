# preprocess the dir (delete the 1, 4, 16 dir)

#root="/users/jtran989/cs491/hw4/dense-linear-algebra-Astrolace/" -- ran from root of repository
up="../"
output_array=("inner_prod_output/" "matvec_output/" "matvec_2d_output/" "cannon_output/")
child_array=("1" "4" "16")
profile_trace_array=("profile/" "trace/")
profile_trace_output_array=("profile.*" "events.*")

for output in "${output_array[@]}"
do
	cd ${output}
	
	for child in "${child_array[@]}"
	do
		cd ${child}
		echo "${output%_output/}, processes: ${child}"
		
		length=${#profile_trace_array[*]}
		for (( i=0; i<$(( $length )); i++ ))
		do 
			cd ${profile_trace_array[$i]}
		
			if [ -n "$(find . -name "${profile_trace_output_array[$i]}" | head -1)" ]
			then
				echo "${profile_trace_array[$i]%/}: success"
			else
				echo "${profile_trace_array[$i]%/}: missing"
			fi
		
			cd ${up}
		done
		
		# for profile_trace in "${profile_trace_array[@]}"
		# do
		# 	cd ${profile_trace}
		#
		# 	echo "${output}, ${child} nodes"
		#
		# 	if [ -n "$(find . -name "${profile_trace}" | head -1)" ]
		# 	then
		# 		echo "${profile_trace}: success"
		# 	else
		# 		echo "${profile_trace}: missing"
		# 	fi
		#
		# 	cd ${up}
		# done
		
		cd ${up}
	done
	
	cd ${up}
	echo ""
done

