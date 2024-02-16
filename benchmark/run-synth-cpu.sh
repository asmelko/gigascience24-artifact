#!/bin/bash

build_dir=build/MaBoSS-CPU
results_dir=results
out_file=cpu_out_synth.csv
data_dir=data

threads_to_test="64"

mkdir -p ${results_dir}

echo "max_time;nodes;formula_size;sample_count;threads;parsing;simulation;visualization;" > ${results_dir}/${out_file}

function runonce {
  for t in ${threads_to_test}
  do
    for r in {1..5}
    do
        printf "$2;$3;$4;$5;$t;" >> ${results_dir}/${out_file}
        ${build_dir}/MaBoSS_1024n ${1}.bnd -c ${1}.cfg -e thread_count=$t -o ${build_dir}/res | cut -f2 -d' ' | tr '\n' ';' >> ${results_dir}/${out_file}
        echo >> ${results_dir}/${out_file}
    done
  done
}

for i in {10..100..10}
do 
  runonce ${data_dir}/synth-100t-${i}n-4f-1000000s 100 $i 4 1000000
done

for i in {200..1000..100}
do 
  runonce ${data_dir}/synth-100t-${i}n-4f-1000000s 100 $i 4 1000000
done

for i in {1000000..10000000..1000000}
do 
  runonce ${data_dir}/synth-100t-100n-4f-${i}s 100 100 4 $i
done

for i in {100..1000..100}
do 
  runonce ${data_dir}/synth-${i}t-100n-4f-1000000s $i 100 4 1000000
done

for i in {4..49..5}
do 
  runonce ${data_dir}/synth-100t-100n-${i}f-1000000s 100 100 $i 1000000
done
