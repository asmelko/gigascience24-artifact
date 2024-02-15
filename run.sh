#!/bin/bash

# Build GPU version of MaBoSS
cmake -DCMAKE_BUILD_TYPE=Release -DMAX_NODES=1024 -B build/MaBoSSG -S repos/MaBoSSG
cmake --build build/MaBoSSG --target MaBoSSG

# Create synthetic data
./make-data.sh

# Run GPU version of MaBoSS
./run-real-gpu.sh
