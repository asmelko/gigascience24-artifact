#!/bin/bash

# Build GPU version of MaBoSS
cmake -DCMAKE_BUILD_TYPE=Release -DMAX_NODES=1024 -B build/MaBoSS-GPU -S repos/MaBoSS.GPU
cmake --build build/MaBoSS-GPU

# Build CPU version of MaBoSS
make -C repos/MaBoSS/engine/src clean
make -C repos/MaBoSS/engine/src MAXNODES=1024 -j `nproc`
mkdir -p build/MaBoSS-CPU
cp repos/MaBoSS/engine/src/MaBoSS_1024n build/MaBoSS-CPU/MaBoSS_1024n

# Build MPI version of MaBoSS
make -C repos/MaBoSS/engine/src clean
make -C repos/MaBoSS/engine/src MAXNODES=1024 MPI_COMPAT=1 CXX=mpic++ -j `nproc`
mkdir -p build/MaBoSS-MPI
cp repos/MaBoSS/engine/src/MaBoSS_1024n build/MaBoSS-MPI/MaBoSS_1024n


echo Running GPU version of MaBoSS on real data
./benchmark/run-real-gpu.sh

echo Running CPU version of MaBoSS on real data
./benchmark/run-real-cpu.sh

echo Creating synthetic data
./make-data.sh

echo Running GPU version of MaBoSS on synthetic data
./benchmark/run-synth-gpu.sh

echo Running CPU version of MaBoSS on synthetic data
./benchmark/run-synth-cpu.sh

echo Running MPI version of MaBoSS on real data
./benchmark/run-real-mpi.sh

echo Running MPI version of MaBoSS on synthetic data
./benchmark/run-synth-mpi.sh

echo Plotting results
Rscript plots/plots.R
