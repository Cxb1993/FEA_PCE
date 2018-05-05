#!/bin/sh

#  FEA_batch_create.sh
#  
#
#  Created by Gustavo Tapia on 5/12/17.
#

# sweep number
K=2

# name new batch job file and create new job based on template
BATCHFILE="sweep$K.job"
sed "s#\$K#$K#g" sweep_job.txt > $BATCHFILE

# submit batch job to LSF
bsub < $BATCHFILE
