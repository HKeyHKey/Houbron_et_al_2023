#!/bin/bash

ref='BetaCoV/Wuhan/IVDC-HB-01/2019|'

for set in `seq 1 100`
do for id in `grep -v '^CLUSTAL 2.1 multiple sequence alignment$' With_ref_Random_set_$set'.aln' | grep -v '^[ \*]*$' | awk '{print $1}' | sort | uniq`
   do seq=`awk '$1=="'$id'" {print $2}' With_ref_Random_set_$set'.aln' | perl -pe 's/\n//g'`
      echo $id $seq
   done > aligned_set_$set'.txt'
done
Rscript R_commands_display_alignment_from_random_sets 100 $ref
