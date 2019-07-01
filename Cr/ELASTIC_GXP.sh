#!/bin/bash

#load modules
ml purge
ml VASP/5.4.4-intel-2017c-mkl=cluster
export OMP_NUM_THREADS=1
export I_MPI_COMPATIBILITY=4

mkdir elastic
# link files to the relaxation folder: (link didnt work for whatever reason)
cp ./source_files/* ./elastic
cp /home/far0068/scripts/AELAS ./elastic/AELAS

cd elastic
./AELAS -g

# first layer of the loop
for ((posnumber_prep=1;posnumber_prep<=3;posnumber_prep=posnumber_prep+1))
        do
	# numerification
       posnumber=$posnumber_prep
               if [[ ${#posnumber} -lt 2 ]] ;
               then
                       posnumber="00${posnumber}"
                       posnumber="${posnumber: -2}"
               fi

	# second layer of the loop
for  ((displacement_prep=1;displacement_prep<=13;displacement_prep=displacement_prep+1))
        do
	# numerification
       displacement=$displacement_prep
               if [[ ${#displacement} -lt 3 ]] ;
               then
                       displacement="00${displacement}"
                       displacement="${displacement: -3}"
               fi

mkdir POS_${posnumber}_${displacement}

# create soft links
ln -s /home/far0068/elastic/Cr/source_files/* /home/far0068/elastic/Cr/elastic/POS_${posnumber}_${displacement}/
cp ../source_files/INCAR ./POS_${posnumber}_${displacement}/INCAR
ln -s /home/far0068/elastic/Cr/elastic/POS_${posnumber}_${displacement}.vasp /home/far0068/elastic/Cr/elastic/POS_${posnumber}_${displacement}/POSCAR

# move to the folder and make the last preparations
cd POS_${posnumber}_${displacement}
sed -i "s/ISIF = 7/ /" ./INCAR

# run the static calculation
mpirun -np 4 vasp_std

#copy the wanted file upwards
cp OSZICAR ../OSZICAR_${posnumber}_${displacement}.vasp

cd ..
	done
done

#finish up the calculation
./AELAS -d OSZICAR_{01..03}_{001..013}.vasp
cp ./ELADAT ../ELADAT
cd ..
