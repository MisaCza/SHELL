#!/bin/bash

#load modules
ml purge
ml VASP/5.4.4-intel-2017c-mkl=cluster
export OMP_NUM_THREADS=1
export I_MPI_COMPATIBILITY=4

mkdir relaxation
# link files to the relaxation folder: (link didnt work for whatever reason)
cp ./source_files/* ./relaxation

cd relaxation
./AELAS

mpirun -np 4 vasp_std
