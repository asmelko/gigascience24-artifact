#!/bin/bash

# Build GPU version of MaBoSS
cmake -DCMAKE_BUILD_TYPE=Release -DMAX_NODES=1024 -B build/MaBoSS-GPU -S repos/MaBoSSG
cmake --build build/MaBoSS-GPU --target MaBoSSG

# Build CPU version of MaBoSS
make -C repos/MaBoSS-env-2.0/engine/src clean
make -C repos/MaBoSS-env-2.0/engine/src MAXNODES=1024 -j `nproc`
mkdir -p build/MaBoSS-CPU
cp repos/MaBoSS-env-2.0/engine/src/MaBoSS_1024n build/MaBoSS-CPU/MaBoSS_1024n

# Build MPI version of MaBoSS
make -C repos/MaBoSS-env-2.0/engine/src clean
make -C repos/MaBoSS-env-2.0/engine/src MAXNODES=1024 MPI_COMPAT=1 CXX=mpic++ -j `nproc`
mkdir -p build/MaBoSS-MPI
cp repos/MaBoSS-env-2.0/engine/src/MaBoSS_1024n build/MaBoSS-MPI/MaBoSS_1024n


echo Running GPU version of MaBoSS on real data
./run-real-gpu.sh

echo Running CPU version of MaBoSS on real data
./run-real-cpu.sh

echo Creating synthetic data
./make-data.sh

echo Running GPU version of MaBoSS on synthetic data
./run-synth-gpu.sh

echo Running CPU version of MaBoSS on synthetic data
./run-synth-cpu.sh
