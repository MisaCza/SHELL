#!/bin/bash

#load modules
ml purge
ml VASP/5.4.4-intel-2017c-mkl=cluster
export OMP_NUM_THREADS=1
export I_MPI_COMPATIBILITY=4

STARTDIR=$(pwd)
mkdir elastic || exit 255 #if mkdir fails exit shell
# link files to the relaxation folder: (link didnt work for whatever reason)
cp ./source_files/* ./elastic
cp /home/far0068/scripts/AELAS ./elastic/AELAS

cd elastic
./AELAS -g

# first layer of the loop
#for ((posnumber_prep=1;posnumber_prep<=3;posnumber_prep=posnumber_prep+1))
#        do
#	# numerification
#       posnumber=$posnumber_prep
#               if [[ ${#posnumber} -lt 2 ]] ; #always true!
#               then
#                       posnumber="00${posnumber}"
#                       posnumber="${posnumber: -2}"
#               fi
#
#	# second layer of the loop
#for  ((displacement_prep=1;displacement_prep<=13;displacement_prep=displacement_prep+1))
#        do
#	# numerification
#       displacement=$displacement_prep
#              if [[ ${#displacement} -lt 3 ]] ; # always true!
#               then
#                       displacement="00${displacement}"
#                       displacement="${displacement: -3}"
#               fi
for posnumber in {001..003}; do
  for displacement in {001..013}; do # does the same as above

    # avoid duplications:
    DIRNAME=POS_${posnumber}_${displacement}
    mkdir $DIRNAME || exit 255 #if mkdir fails exit shell

    # create soft links # avoid long names (hard to read)
    WORKDIR=/home/far0068/elastic/Cr
    ln -s $WORKDIR/source_files/* $WORKDIR/elastic/$DIRNAME/
    cp ../source_files/INCAR ./$DIRNAME/INCAR
    ln -s $WORKDIR/elastic/$DIRNAME.vasp $WORKDIR/elastic/$DIRNAME/POSCAR

    # move to the folder and make the last preparations
    MYDIR=$(pwd)
    cd $DIRNAME
    sed -i "s/ISIF = 7/ /" ./INCAR 

    # run the static calculation
    mpirun -np 4 vasp_std

    #copy the wanted file upwards
    cp OSZICAR ../OSZICAR_${posnumber}_${displacement}.vasp

    cd $MYDIR
  done
done

#finish up the calculation
./AELAS -d OSZICAR_{01..03}_{001..013}.vasp
cp ./ELADAT ../ELADAT
cd $STARTDIR #this is unnecessary though
