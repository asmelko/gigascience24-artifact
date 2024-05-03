#!/bin/bash

#SBATCH --time=240:00:00           # walltime for the job in format (days-)hours:minutes:seconds
#SBATCH --nodes=192               
#SBATCH --ntasks-per-node=64      # processes per node
#SBATCH --mem=64000               # memory resource per node


build_dir=build/MaBoSS-MPI
results_dir=results
out_file=mpi_out_real.csv
data_dir=data

threads_to_test="64"
mpi_nodes="1 2 4 8 16 32 64 96 128 160 192"

mkdir -p ${results_dir}

echo "name;nodes;sample_count;threads;mpi_nodes;parsing;simulation;visualization;" > ${results_dir}/${out_file}

function runonce {
  for m in ${mpi_nodes}
  do
    for t in ${threads_to_test}
    do
        for r in {1..5}
        do
            printf "$2;$3;$4;$t;$m;" >> ${results_dir}/${out_file}
            ${build_dir}/MaBoSS_1024n ${1}.bnd -c ${1}.cfg -e thread_count=$t -o ${build_dir}/res | cut -f2 -d' ' | tr '\n' ';' >> ${results_dir}/${out_file}
            echo >> ${results_dir}/${out_file}
        done
    done
  done
}

runonce ${data_dir}/synth-100t-100n-4f-10000000s 100 100 4 10000000
