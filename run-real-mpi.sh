#!/bin/bash

build_dir=build/MaBoSS-MPI
results_dir=results
out_file=mpi_out_real.csv
data_dir=data

threads_to_test="20"
max_mpi_nodes=10

mkdir -p ${results_dir}

echo "name;nodes;sample_count;threads;mpi_nodes;parsing;simulation;visualization;" > ${results_dir}/${out_file}

function runonce {
  for m in `seq 1 ${max_mpi_nodes}`
  do
    for t in ${threads_to_test}
    do
        for r in {1..5}
        do
            printf "$2;$3;$4;$t;$m;" >> ${results_dir}/${out_file}
            mpirun -np $m ${build_dir}/MaBoSS_1024n ${1}.bnd -c ${1}.cfg -e thread_count=$t -o ${build_dir}/res | cut -f2 -d' ' | tr '\n' ';' >> ${results_dir}/${out_file}
            echo >> ${results_dir}/${out_file}
        done
    done
  done
}

runonce ${data_dir}/sizek sizek 87 1000000
