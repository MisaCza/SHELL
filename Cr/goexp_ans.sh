#!/bin/bash
#PBS -A OPEN-15-57
#PBS -N Cr_elastic
#PBS -q qfree
#PBS -l select=1:ncpus=16:mpiprocs=16:ompthreads=1
#PBS -l walltime=09:59:59
#PBS -j oe
#PBS -S /bin/bash

ml purge
ml VASP/5.4.4-intel-2017c-mkl=cluster

export OMP_NUM_THREADS=1
export I_MPI_COMPATIBILITY=4
cd $PBS_O_WORKDIR

b=`basename $PBS_O_WORKDIR`
echo "$b" >log.vasp
SCRDIR=/scratch/"$USER"/"$b"_"$PBS_JOBID"/

echo $SCRDIR
echo $PBS_O_WORKDIR
mkdir -p $SCRDIR
cd $SCRDIR || exit

# copy input file to scratch
cp -r $PBS_O_WORKDIR/* .
sh $PBS_O_WORKDIR/ELASTIC_GXP.sh
#time mpirun vasp_std > log.vasp
##time mpirun vasp_ncl > log.vasp

# copy output file to home
cp -r * $PBS_O_WORKDIR/. && cd ..
sleep 60
#rm -rf "$SCRDIR"
exit

