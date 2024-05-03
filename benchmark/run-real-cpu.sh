#!/bin/bash

#SBATCH --time=10:00:00           # walltime for the job in format (days-)hours:minutes:seconds
#SBATCH --cpus-per-task=64      # cpus per tasks
#SBATCH --mem=64000               # memory resource per node

build_dir=build/MaBoSS-CPU
results_dir=results
out_file=cpu_out_real.csv
data_dir=data

threads_to_test="1 2 4 8 16 32 48 64"

mkdir -p ${results_dir}

echo "name;nodes;sample_count;threads;parsing;simulation;visualization;" > ${results_dir}/${out_file}

function runonce {
  for t in ${threads_to_test}
  do
    for r in {1..5}
    do
        printf "$2;$3;$4;$t;" >> ${results_dir}/${out_file}
        ${build_dir}/MaBoSS_1024n ${1}.bnd -c ${1}.cfg -e thread_count=$t -o ${build_dir}/res | cut -f2 -d' ' | tr '\n' ';' >> ${results_dir}/${out_file}
        echo >> ${results_dir}/${out_file}
    done
  done
}

runonce ${data_dir}/sizek sizek 87 1000000
