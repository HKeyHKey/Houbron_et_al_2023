#!/bin/bash

for name in `grep '^>' Selected_13-mers.fa | sed -e 's|^> *||' -e 's| .*||'`
do seq=`grep -A 1 -w $name Selected_13-mers.fa | tail -1`
   hit=`grep '^ *31.... ' Perfect_hits_to_13-mer_$seq | awk '{print $2}'`
   ./Module_siRNA_duplex_design.pl $hit $name
done > siRNAs.fa
