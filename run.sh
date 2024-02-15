#!/bin/bash

# Build GPU version of MaBoSS
cmake -DCMAKE_BUILD_TYPE=Release -DMAX_NODES=1024 -B build/MaBoSSG -S repos/MaBoSSG
cmake --build build/MaBoSSG --target MaBoSSG

# Build CPU version of MaBoSS
make -C repos/MaBoSS-env-2.0/engine/src clean
make -C repos/MaBoSS-env-2.0/engine/src MAXNODES=1024 -j `nproc`
mkdir build/MaBoSS-CPU
cp repos/MaBoSS-env-2.0/engine/src/MaBoSS_1024n build/MaBoSS-CPU/MaBoSS_1024n

# Build MPI version of MaBoSS
make -C repos/MaBoSS-env-2.0/engine/src clean
make -C repos/MaBoSS-env-2.0/engine/src MAXNODES=1024 MPI_COMPAT=1 CXX=mpic++ -j `nproc`
mkdir build/MaBoSS-MPI
cp repos/MaBoSS-env-2.0/engine/src/MaBoSS_1024n build/MaBoSS-MPI/MaBoSS_1024n


# Run GPU version of MaBoSS
./run-real-gpu.sh

./run-real-cpu.sh

# Create synthetic data
./make-data.sh