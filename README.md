# Artifact Submission: HPC MaBoSS 

This is a replication package containing code and experimental results related to the paper titled: MaBoSS for HPC environments: Implementations of the continuous time Boolean model simulator for large CPU clusters and GPU accelerators.

## Overview

The artifact comprises the following directories:

* `benchmark` -- benchmarking scripts
* `data` -- the (`bnd`, `cfg`) model pairs on which the benchmarks were run
* `plots` -- scripts for generating results plots	
* `presented-results` -- plots (including some that were not included in the paper), CSV data files with measurements and R script that generated the plots from the data
* `repos` -- all the implementations of cross-correlation
  - `MaBoSS.GPU` -- GPU code (located under `src`)
  - `MaBoSS` -- CPU and MPI code (located under `engine/src`)


## Detailed artifact contents

`repo/MaBoSS.GPU/src` directory contains the source files to the CUDA kernels. Notably, the runtime compilation optimization can be viewed in `kernel_compiler.h/cpp` and `generator.h/cpp` source files, the simulation part in `jit_kernels/simulation.cu` and the stats computation part in `jit_kernels/final_states.cu` and `jit_kernels/window_average_small.cu`.

MPI implementation of CPU MaBoSS code can be found by searching for the `MPI_COMPAT` keyword in `repo/MaBoSS/engine/src` directory.


## Requirements for running the experiments

Hardware requirements:

* A CUDA-compatible GPU
* A (homogeneous) CPU cluster

Software requirements:

* [CUDA toolkit 12.2 or later](https://developer.nvidia.com/cuda-downloads) and appropriate driver
* an MPI implementation, such as `mpich`
* `cmake 3.18` or later 
* `flex` and `bison` libraries
* `R` software for plotting the graphs (see details below)

Let us present a few commands for your convenience that will allow you to set up the environment quickly:

Installing all dependencies (except CUDA and GPU driver) on Debian/Ubuntu:
```
sudo apt-get update && apt-get install -y g++ cmake r-base flex bison mpich
```

Installing all dependencies (except CUDA and GPU driver) on RHEL-like distribution:
```
sudo dnf install -y cmake gcc-c++ R flex bison mpich
```

R packages necessary for generating the plots:
```
sudo R -e "install.packages(c('ggplot2', 'cowplot', 'sitools', 'viridis', 'dplyr'), repos='https://cloud.r-project.org')"
```


## Running the experiments

Our experiments are designed to provide a comprehensive analysis of the aforementioned algorithms running various combinations of parameters computing different sizes of input instances. Therefore, the overall duration of **running the experiments is quite long** (around **2 to 3 days** on our GPU cluster and MareNostrum SC).

To provide a swift way to check the reproducibility of our experiments, we prepared a special script that runs only a subset of the benchmarks.

**Kick the tires:**

Just to see whether the code is working, run the following from the root directory:
```
./kick-the-tires.sh
```
The script should take about 10 minutes to finish. The script runs a subset of GPU experiments.

After the script runs, it will generate results in a CSV format in the `results` directory. It should contain 2 CSV files for CPU and GPU benchmark respectively. Each CSV file contains self-documenting headers. Finally, the plotting script is executed generating a single plot in the `plots` directory. 
More details on how the CSV results rows are processed into plots can be found in the `plots/plots-fast.R` script.

The generated plot file will be named `real.pdf` and it shows the comparison of CPU and GPU runtime on a small cellcycle model.


**Complete set of measurements:**

To run the complete benchmark, execute
```
./run-all.sh
```

## Measured results

The measured data and plots were stored in the `presented-results` directory. The directory also contains `plots.R` script, which was used to plot the data. It can be executed by `Rscript plots.R` if you wish to re-generate the plots from the data yourself. Here we describe each figure in the `presented-results/plots` directory:

| Plot | Description | Figure number in paper |
| --------------------------- | ----------- | -- |
| `real.pdf`| GPU benchmark on real-world dataset | Figure 1
| `sizek_mpi.pdf`| MPI benchmark on real-world dataset | Figure 4 
| `synth_mpi_speedup.pdf`| MPI strong-scaling speedup on synthetic dataset | Figure 5
| `synth_mpi.pdf`| MPI wall time on synthetic dataset | not included
| `nodes.pdf`|GPU benchmark on synthetic dataset |  Figure 2
| `nodes-compilation-big-NVIDIA RTX 3070 Laptop GPU.pdf`| Laptop GPU runtime compilation benchmark |   not included
| `nodes-compilation-big-NVIDIA Tesla A100 GPU.pdf`| Datacenter-grade GPU runtime compilation benchmark |  Figure 3
