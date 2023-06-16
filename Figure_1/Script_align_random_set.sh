#!/bin/bash

set=$1
cp Random_set_$set'.fa' With_ref_Random_set_$set'.fa'
cat EPI_ISL_402119.fasta >> With_ref_Random_set_$set'.fa'
clustalw With_ref_Random_set_$set'.fa'
