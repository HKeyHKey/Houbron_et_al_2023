#!/bin/bash

file=$1
grep '^>' $file | sed 's|^> *||' > all.txt
R CMD BATCH R_commands_random_pick
for set in `seq 1 100`
do tail -n +2 Random_set_$set'.csv' | awk -F ',' '{print $2}' | sed 's|"||g' > Random_set_$set'.txt'
   ./Module_extracts_sequences_from_fasta.pl $file Random_set_$set'.txt' > Random_set_$set'.fa'
done
