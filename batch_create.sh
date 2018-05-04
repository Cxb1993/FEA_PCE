#!/bin/sh

#  FEA_batch_create.sh
#  
#
#  Created by Gustavo Tapia on 5/12/17.
#

# check for R packages to be installed
module load R/3.4.3-intel-2017A-Python-2.7.12-recommended-mt
Rscript check_packages.R

# iteration number - look for next iteration
K=$(($(ls | grep batch | grep .job | wc -l) + 1))
read -p "Next iteration is No. $K. Confirm? (yes/no): " YNCOMSOL
if [[ $YNCOMSOL = 'no' ]]; then
	exit 0
fi

# name new batch job file and read template contents
BATCHFILE="batch$K.job"
BATCHTEXT=$(cat batch_template.txt)

# write the batch job file
echo "#BSUB -L /bin/bash" > $BATCHFILE
echo "#BSUB -J FEA_PCE$K" >> $BATCHFILE
echo "#BSUB -o stdout$K.txt" >> $BATCHFILE
echo "#BSUB -e stderr$K.txt" >> $BATCHFILE
echo "$BATCHTEXT" >> $BATCHFILE

# submit batch job to LSF
bsub < $BATCHFILE
