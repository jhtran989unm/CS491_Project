# processes array
num_processes=4
process_array=(1 2 4 8 16 32)

# program names
programs_dir="sparse_linear_algebra/"

# inner_prod_program="inner_prod"
# matvec_program="matvec"
# matvec_2d_program="matvec_2d"
# cannon_program="cannon"

run_script="job_script.pbs"

# dir names
up="../"
up2=${up}${up}
up3=${up}${up2}
up4=${up}${up3}
up5=${up}${up4}

# various roots
root="/users/jtran989/cs491/project/CS491_Project/"
programs_root=${root}${programs_dir}

# inner_prod_output="inner_prod_output/"
# matvec_output="matvec_output/"
# matvec_2d_output="matvec_2d_output/"
# cannon_output="cannon_output/"

# bottleneck cases
# optimal - max 8 processes per node (uses as few nodes as possible)
# communication - only 1 process per node (test limits of communication) where #nodes=#processes
bottleneck_dir_array=("optimal/" "communication/")

# g_30_30 matrix
# fetch the matrix MANUALLY
matrix_link=""

# matrix size -- REMEMBER TO EDIT
num_matrices=1

# matrix dir
matrix_dir_array=("gr_30_30_output/")

# matrix names
matrix_mtx_filename_array=("gr_30_30.mtx")
matrix_mtx_path_array=()
for matrix_mtx_filename in "${matrix_mtx_filename_array[@]}"
do
	matrix_mtx_path_array+=(${programs_root}"suitesparse/"${matrix_mtx_filename})
done

matrix_pm_filename_array=("gr_30_30.pm")
matrix_pm_path_array=()
for matrix_pm_filename in "${matrix_pm_filename_array[@]}"
do
	matrix_pm_path_array+=(${programs_root}"suitesparse/"${matrix_pm_filename})
done

# programs size -- REMEMBER TO EDIT
num_programs=1

# code array
code_array=("relaxation.cpp")

# program array
program_array=("relaxation")

# output array
output_array=("relaxation_output/")

normal_dir="normal/"
profile_dir="profile/"
trace_dir="trace/"

# flags for Tau profiling and tracing (and normal execution)
normal=0
tau_profile=0
tau_trace=0

# command line argument for the programs
num_elements_one=1000
num_elements_ten=10000

# remove ups since ABSOLUTE path is used

# changed from run_script_inner_prod
function run_script() {
	#move module load to the job script as well
	module load mpich-3.2-gcc-4.8.5-7ebkszx
	module load netlib-lapack-3.6.1-gcc-4.8.5-x3vu6o3
	
	# fetch the mtx (matrix marketplace) file first
	# then convert to .pm
	# MANUALLY
	
	for (( j=0; j<${num_matrices}; j++ ))
	do
		cd ${root}
		
		matrix_dir=${matrix_dir_array[$j]}
		matrix_pm_path=${matrix_pm_path_array[$j]}
		
		echo "DEBUG - matrix .pm path: ${matrix_pm_path}"
		
		mkdir -p ${matrix_dir}
		
		cd ${matrix_dir}
		
		for (( i=0; i<${num_programs}; i++ ))
		do
			cd ${programs_root}
		
			# move to run script (.pbs)
			#echo "current program: ${program_array[i]}"
		
			code=${code_array[$i]}
			program=${program_array[$i]}
			output=${output_array[$i]}
		
			# ASSUMING C++ CODE
			make
			#mpicxx -o ${program} ${code} -std=c++11
	
			#cd ${up}${matrix_dir}${output}
			cd ${root}${matrix_dir}
			
			mkdir -p ${output}
			
			cd ${output}
		
			for bottleneck_dir in "${bottleneck_dir_array[@]}"
			do
				mkdir -p ${bottleneck_dir}
				cd ${bottleneck_dir}
			
				for process in "${process_array[@]}"
				do
					mkdir -p ${process}
					cd ${process}
					
					#echo "TEST: ${bottleneck_dir%/}"
				
					if [[ "${bottleneck_dir%/}" == "optimal" ]]; then
						num_nodes=$(( process / 8 ))
						remainder=$(( process % 8 ))
					
						# just round up if there are still some processes left over
						if (( ${remainder} != 0 )); then
							num_nodes=$(( num_nodes + 1 ))
						fi
					
						num_processes_per_node=8
					else # connection bottleneck
						num_nodes=${process}
						num_processes_per_node=1
					fi
		
					# CREATE SEPARATE DIR FOR DIFFERENT TYPE BELOW
					# extra up for each...
	
					if (( ${normal} == 1 )); then 
						mkdir -p ${normal_dir}
						cd ${normal_dir}
						
						cp ${up5}${run_script} . 
					
						echo "echo normal: ${program}" >> ${run_script}
						#echo "echo normal: ${program}, nodes: ${process}" >> ${run_script}
						#echo "#PBS -lnodes=${process}:ppn=8" >> ${run_script}
						
						echo "echo current program: ${program_array[i]}" >> ${run_script}
						echo "echo " >> ${run_script}
						echo "echo bottleneck dir: ${bottleneck_dir}" >> ${run_script}
						echo "echo total num processes: ${process}" >> ${run_script}
						echo "echo num nodes: ${num_nodes}" >> ${run_script}
						echo "echo num processes per node: ${num_processes_per_node}" >> ${run_script}
					
						#
						echo "---------------------------------------------------"
						echo "current program: ${program_array[i]}" 
						echo ""
						echo "bottleneck dir: ${bottleneck_dir}" 
						echo "total num processes: ${process}" 
						echo "num nodes: ${num_nodes}" 
						echo "num processes per node: ${num_processes_per_node}" 
						echo "---------------------------------------------------"
					
						#REMEMBER to change line 9 if it changes
						#sed -i "9 i #PBS -lnodes=${process}:ppn=8" ${run_script}
						sed -i "9 i #PBS -lnodes=${num_nodes}:ppn=${num_processes_per_node}" ${run_script}
					
						# echo "mpirun -n ${process} ${up2}${programs_root}${program} ${num_elements}" >> ${run_script}
						#${up4}
						echo "mpirun -n ${process} ${programs_root}${program} ${matrix_pm_path}" >> ${run_script}
					
						#mpirun -n ${process} ${up2}${programs_root}${program} ${num_elements}
						qsub ${run_script}
				
						# no output files for normal
						# made a new dir for normal
						cd ${up}
					fi 
	
					if (( ${tau_trace} == 1 )); then 
						mkdir -p ${trace_dir}
						cd ${trace_dir}
			
						cp ${up5}${run_script} . 
			
						echo "export TAU_TRACE=1" >> ${run_script}
					
						#echo "echo trace: ${program}, nodes: ${process}" >> ${run_script}
						echo "echo trace: ${program}" >> ${run_script}
					fi
	
					if (( ${tau_profile} == 1 )); then 
						if (( ${tau_trace} == 0 )); then 
							mkdir -p ${profile_dir}
							cd ${profile_dir}
				
							cp ${up5}${run_script} . 
				
							#echo "echo profile: ${program}, nodes: ${process}" >> ${run_script}
							echo "echo profile: ${program}" >> ${run_script}
						fi
						
						echo "echo current program: ${program_array[i]}" >> ${run_script}
						echo "echo " >> ${run_script}
						echo "echo bottleneck dir: ${bottleneck_dir}" >> ${run_script}
						echo "echo total num processes: ${process}" >> ${run_script}
						echo "echo num nodes: ${num_nodes}" >> ${run_script}
						echo "echo num processes per node: ${num_processes_per_node}" >> ${run_script}
					
						#
						echo "---------------------------------------------------"
						echo "current program: ${program_array[i]}" 
						echo ""
						echo "bottleneck dir: ${bottleneck_dir}" 
						echo "total num processes: ${process}" 
						echo "num nodes: ${num_nodes}" 
						echo "num processes per node: ${num_processes_per_node}" 
						echo "---------------------------------------------------"
			
						#echo "#PBS -lnodes=${process}:ppn=8" >> ${run_script}
						#REMEMBER to change line 9 if it changes
						#sed -i "9 i #PBS -lnodes=${process}:ppn=8" ${run_script}
						sed -i "9 i #PBS -lnodes=${num_nodes}:ppn=${num_processes_per_node}" ${run_script}
					
						# echo "mpirun -n ${process} tau_exec ${up3}${programs_root}${program} ${num_elements}" >> ${run_script}
						#${up4}
						echo "mpirun -n ${process} tau_exec ${programs_root}${program} ${matrix_pm_path}" >> ${run_script}
						
						#mpirun -n ${process} tau_exec ${up3}${programs_root}${inner_prod_program} ${num_elements}
						qsub ${run_script}
			
						cd ${up}
					fi
		
					cd ${up}
				done
			
				cd ${up}
			done
		
			cd ${up}
		done
		
		cd ${up}
	done
	
	
	
	# cd to dense_linear_alg dir
	# cd ${root}
# 	echo "choice: "${choice}
#
# 	if [ "${choice}" == "i" ]
# 	then
# 		output=${inner_prod_output}
# 		program=${inner_prod_program}
# 		num_elements=${num_elements_ten}
# 	elif [ "${choice}" == "m" ]
# 	then
# 		output=${matvec_output}
# 		program=${matvec_program}
# 		num_elements=${num_elements_one}
# 	elif [ "${choice}" == "m2" ]
# 	then
# 		output=${matvec_2d_output}
# 		program=${matvec_2d_program}
# 		num_elements=${num_elements_one}
# 	elif [ "${choice}" == "c" ]
# 	then
# 		output=${cannon_output}
# 		program=${cannon_program}
# 		num_elements=${num_elements_one}
# 	else
# 		echo "Sorry, invalid option argument. Please choose from the following: [i, m, m2, c]"
# 		exit
# 	fi
#
# 	mpicxx -o ${program} inner_prod.cpp -std=c++11
#
# 	cd ${up}${output}
#
# 	for process in "${process_array[@]}"
# 	do
# 		mkdir -p ${process}
# 		cd ${process}
#
# 		# CREATE SEPARATE DIR FOR DIFFERENT TYPE BELOW
#
# 		if (( ${normal} == 1 )); then
# 			cp ${up2}${run_script} .
#
# 			echo "echo normal: ${program}, nodes: ${process}" >> ${run_script}
# 			#echo "#PBS -lnodes=${process}:ppn=8" >> ${run_script}
# 			#REMEMBER to change line 9 if it changes
# 			sed -i "9 i #PBS -lnodes=${process}:ppn=8" ${run_script}
# 			echo "mpirun -n ${process} ${up2}${programs_root}${program} ${num_elements}" >> ${run_script}
# 			#mpirun -n ${process} ${up2}${programs_root}${program} ${num_elements}
# 			qsub ${run_script}
# 		fi
#
# 		if (( ${tau_trace} == 1 )); then
# 			mkdir -p ${trace_dir}
# 			cd ${trace_dir}
#
# 			cp ${up3}${run_script} .
#
# 			echo "export TAU_TRACE=1" >> ${run_script}
# 			echo "echo trace: ${program}, nodes: ${process}" >> ${run_script}
# 		fi
#
# 		if (( ${tau_profile} == 1 )); then
# 			if (( ${tau_trace} == 0 )); then
# 				mkdir -p ${profile_dir}
# 				cd ${profile_dir}
#
# 				cp ${up3}${run_script} .
#
# 				echo "echo profile: ${program}, nodes: ${process}" >> ${run_script}
# 			fi
#
# 			#echo "#PBS -lnodes=${process}:ppn=8" >> ${run_script}
# 			#REMEMBER to change line 9 if it changes
# 			sed -i "9 i #PBS -lnodes=${process}:ppn=8" ${run_script}
# 			echo "mpirun -n ${process} tau_exec ${up3}${programs_root}${program} ${num_elements}" >> ${run_script}
# 			#mpirun -n ${process} tau_exec ${up3}${programs_root}${inner_prod_program} ${num_elements}
# 			qsub ${run_script}
#
# 			cd ${up}
# 		fi
#
# 		cd ${up}
# 	done
}

function run_script_matvec_2d {
	module load mpich-3.2-gcc-4.8.5-7ebkszx
	
	if (( ${normal} == 1 )); then 
		mpirun -n ${num_processes} ./example
	fi 
	
	if (( ${tau_trace} == 1 )); then 
		export TAU_TRACE=1
	fi
	
	if (( ${tau_profile} == 1 )); then 
		mpirun -n ${num_processes} tau_exec ./example
	fi
}

function run_script_cannon {
	module load mpich-3.2-gcc-4.8.5-7ebkszx
	
	if (( ${normal} == 1 )); then 
		mpirun -n ${num_processes} ./example
	fi 
	
	if (( ${tau_trace} == 1 )); then 
		export TAU_TRACE=1
	fi
	
	if (( ${tau_profile} == 1 )); then 
		mpirun -n ${num_processes} tau_exec ./example
	fi
}

function run_success_check {
	# preprocess the dir (delete the 1, 4, 16 dir)

	#root="/users/jtran989/cs491/hw4/dense-linear-algebra-Astrolace/" -- ran from root of repository
	#up="../"
	#output_array=("inner_prod_output/" "matvec_output/" "matvec_2d_output/" "cannon_output/")
	#child_array=("1" "4" "16")
	profile_trace_array=("normal/" "profile/" "trace/")
	profile_trace_output_array=("*" "profile.*" "events.*")
	
	for matrix_dir in "${matrix_dir_array[@]}"
	do
		cd ${matrix_dir}
		
		echo "============================================================================================="
		echo "============================================================================================="
		echo ${matrix_dir%/}
		echo "============================================================================================="
		echo "============================================================================================="
		
		for output_dir in "${output_array[@]}"
		do
			cd ${output_dir}
			
			echo ${output_dir%/}
			echo "============================================================================================="
			
			for bottleneck_dir in "${bottleneck_dir_array[@]}"
			do
				cd ${bottleneck_dir}
				
				echo ${bottleneck_dir%/}
				echo "============================================================================================="
				
				for process in "${process_array[@]}"
				do
					cd ${process}
					
					echo "num processes: ${process}"
					echo "============================================================================================="
					
					length=${#profile_trace_array[*]}
					
					for (( i=0; i<${length}; i++ ))
					do
						cd ${profile_trace_array[$i]}
						
						if [ -n "$(find . -name "${profile_trace_output_array[$i]}" | head -1)" ]
						then
							echo "${profile_trace_array[$i]%/}: success"
						else
							echo "${profile_trace_array[$i]%/}: missing"
						fi
						
						echo "-----------------------------------------------------------------------------------------------"
						
						cd ${up}
					done
					
					echo "============================================================================================="
					
					cd ${up}
				done
				
				cd ${up}
			done
			
			cd ${up}
		done
		
		echo "============================================================================================="
		echo "============================================================================================="
		
		cd ${up}
	done

	# for output in "${output_array[@]}"
# 	do
# 		cd ${output}
#
# 		for process in "${process_array[@]}"
# 		do
# 			cd ${child}
# 			echo "${output%_output/}, processes: ${child}"
#
# 			length=${#profile_trace_array[*]}
# 			for (( i=0; i<$(( $length )); i++ ))
# 			do
# 				cd ${profile_trace_array[$i]}
#
# 				if [ -n "$(find . -name "${profile_trace_output_array[$i]}" | head -1)" ]
# 				then
# 					echo "${profile_trace_array[$i]%/}: success"
# 				else
# 					echo "${profile_trace_array[$i]%/}: missing"
# 				fi
#
# 				cd ${up}
# 			done
#
# 			# for profile_trace in "${profile_trace_array[@]}"
# 			# do
# 			# 	cd ${profile_trace}
# 			#
# 			# 	echo "${output}, ${child} nodes"
# 			#
# 			# 	if [ -n "$(find . -name "${profile_trace}" | head -1)" ]
# 			# 	then
# 			# 		echo "${profile_trace}: success"
# 			# 	else
# 			# 		echo "${profile_trace}: missing"
# 			# 	fi
# 			#
# 			# 	cd ${up}
# 			# done
#
# 			cd ${up}
# 		done
#
# 		cd ${up}
# 		echo ""
# 	done
}

# module load mpich-3.2-gcc-4.8.5-7ebkszx
# mpirun -n ${num_processes} ./example

# ;; vs exit;; (one continues and the other exits)

# OPTIONS
while getopts "hnpts" args; do
	case $args in 
	h)
		echo "============================================================================================="
		echo "Arguments:"
		echo "  -h	check help (this prompt) for list of options"
		echo "  -n  run normally"
		echo "  -p  run with Tau profiling"
		echo "  -t  run with Tau tracing"
		echo "============================================================================================="
		exit;;
	n)
		normal=1
		#choice="${OPTARG}"
		echo "============================================================================================="
		echo "Executing normally"
		echo "============================================================================================="
		run_script
		exit;;
	p)
		tau_profile=1
		#choice=${OPTARG}
		echo "============================================================================================="
		echo "Executing with Tau profiling"
		echo "============================================================================================="
		run_script
		exit;;
	t)
		tau_profile=1
		tau_trace=1
		#choice=${OPTARG}
		echo "============================================================================================="
		echo "Executing with Tau tracing (and profiling)"
		echo "============================================================================================="
		run_script
		exit;;
	s)
		echo "============================================================================================="
		echo "Checking success of outputs..."
		echo "============================================================================================="
		run_success_check
		exit;;
	\?)
		echo "============================================================================================="
		echo "Sorry, invalid option. Please use option -h for valid options."
		echo "============================================================================================="
		exit;;
	esac
done 