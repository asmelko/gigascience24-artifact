#!/bin/bash

#SBATCH --time=10:00:00           # walltime for the job in format (days-)hours:minutes:seconds
#SBATCH --nodes=64               
#SBATCH --cpus-per-task=32         # cpus per tasks
#SBATCH --mem=64000               # memory resource per node

build_dir=build/MaBoSS-MPI
results_dir=results
out_file=mpi_out_real.csv
data_dir=data

threads_to_test="16"
mpi_nodes="1 2 4 8 16 32 64"

mkdir -p ${results_dir}

function runonce {
  sbatch --ntasks-per-node 8 --ntasks-per-socket 1 -c 16 --mem 64  ${build_dir}/MaBoSS_1024n ${1}.bnd -c ${1}.cfg -e thread_count=16 -o ${build_dir}/res | cut -f2 -d' ' | tr '\n' ';' >> ${results_dir}/${out_file}${2}
}

for m in ${mpi_nodes}
do
  for t in ${threads_to_test}
  do
      echo "name;nodes;sample_count;threads;mpi_nodes;parsing;simulation;visualization;" > ${results_dir}/${out_file}${m}
      for r in {1..5}
      do
        runonce ${data_dir}/sizek $m
      done
  done
done
