#!/bin/bash

build_dir=build/MaBoSS-GPU
results_dir=results
out_file=gpu_out_real.csv
data_dir=data

mkdir -p ${results_dir}

echo "name;nodes;sample_count;compilation;visualization;simulation;" > ${results_dir}/${out_file}

function runonce {
  for r in {1..5}
  do
    printf "$2;$3;$4;" >> ${results_dir}/${out_file}
    ${build_dir}/MaBoSS.GPU ${1}.bnd ${1}.cfg  2>&1 | grep "main>" | tail -n3 | cut -c52-62 | awk '{$1=$1;print}' | tr '\n' ';' >> ${results_dir}/${out_file}
    echo >> ${results_dir}/${out_file}
  done
}

runonce ${data_dir}/cellcycle cellcycle 10 1000000
runonce ${data_dir}/Montagud2022_Prostate_Cancer Montagud 133 1000000
runonce ${data_dir}/sizek sizek 87 1000000
