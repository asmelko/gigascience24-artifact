#!/bin/bash

########## Build ##########

# Build GPU version of MaBoSS
cmake -DCMAKE_BUILD_TYPE=Release -DMAX_NODES=1024 -B build/MaBoSS-GPU -S repos/MaBoSSG
cmake --build build/MaBoSS-GPU

# Build CPU version of MaBoSS
make -C repos/MaBoSS-env-2.0/engine/src clean
make -C repos/MaBoSS-env-2.0/engine/src MAXNODES=1024 -j `nproc`
mkdir -p build/MaBoSS-CPU
cp repos/MaBoSS-env-2.0/engine/src/MaBoSS_1024n build/MaBoSS-CPU/MaBoSS_1024n

########## Build ##########

########## Run GPU cellcycle ##########

build_dir=build/MaBoSS-GPU
results_dir=results
out_file=gpu_out_real_ktt.csv
data_dir=data

mkdir -p ${results_dir}

echo "name;nodes;sample_count;compilation;visualization;simulation;" > ${results_dir}/${out_file}

function runonce {
  printf "Running GPU $1 5 times "
  for r in {1..5}
  do
    printf "$2;$3;$4;" >> ${results_dir}/${out_file}
    ${build_dir}/MaBoSSG ${1}.bnd ${1}.cfg  2>&1 | grep "main>" | tail -n3 | cut -c52-62 | awk '{$1=$1;print}' | tr '\n' ';' >> ${results_dir}/${out_file}
    echo >> ${results_dir}/${out_file}
    printf "."
  done
  printf " done\n"
}

runonce ${data_dir}/cellcycle cellcycle 10 1000000

########## Run GPU cellcycle ##########

########## Run CPU cellcycle ##########

build_dir=build/MaBoSS-CPU
results_dir=results
out_file=cpu_out_real_ktt.csv
data_dir=data

threads_to_test="64"

mkdir -p ${results_dir}

echo "name;nodes;sample_count;threads;parsing;simulation;visualization;" > ${results_dir}/${out_file}

function runonce {
  printf "Running CPU $1 5 times "
  for t in ${threads_to_test}
  do
    for r in {1..5}
    do
        printf "$2;$3;$4;$t;" >> ${results_dir}/${out_file}
        ${build_dir}/MaBoSS_1024n ${1}.bnd -c ${1}.cfg -e thread_count=$t -o ${build_dir}/res | cut -f2 -d' ' | tr '\n' ';' >> ${results_dir}/${out_file}
        echo >> ${results_dir}/${out_file}
        printf "."
    done
  done
  printf " done\n"
}

runonce ${data_dir}/cellcycle cellcycle 10 1000000

########## Run CPU cellcycle ##########

Rscript plots/plots-fast.R
