#!/bin/bash

build_dir=build/MaBoSS-CPU
results_dir=results
out_file=cpu_out_real.csv
data_dir=data

threads_to_test="32 64"

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

runonce ${data_dir}/cellcycle cellcycle 10 1000000
runonce ${data_dir}/Montagud2022_Prostate_Cancer Montagud 133 1000000
runonce ${data_dir}/sizek sizek 87 1000000
