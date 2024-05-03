#!/bin/bash

build_dir=build/MaBoSS-MPI
results_dir=results
out_file=mpi_out_real.csv
data_dir=data

threads_to_test="16"
mpi_nodes="1 2 4 8 16 32 64"

mkdir -p ${results_dir}

function runonce {
  # this "--ntasks-per-node 8 --ntasks-per-socket 1 -c 16" can not change -> https://hpc-docs.uni.lu/systems/aion/compute/
  # --mem is G per node
  sbatch -p batch --cluster aion -N $2 --ntasks-per-node 8 --ntasks-per-socket 1 -c 16 --mem 64 -t 12:00:00  ${build_dir}/MaBoSS_1024n ${1}.bnd -c ${1}.cfg -e thread_count=16 -o ${build_dir}/res | cut -f2 -d' ' | tr '\n' ';' >> ${results_dir}/${out_file}${2}
}

for m in ${mpi_nodes}
do
  for t in ${threads_to_test}
  do
      echo "name;nodes;sample_count;threads;mpi_nodes;parsing;simulation;visualization;" > ${results_dir}/${out_file}${m}
      for r in {1..5}
      do
        runonce ${data_dir}/synth-100t-1000n-4f-100000000s $m
      done
  done
done
