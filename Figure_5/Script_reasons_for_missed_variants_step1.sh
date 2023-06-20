#!/bin/bash

target=$1
grep ' (host: Human)$' Missed_2022_09_26_for_$target'.txt' | awk '{print $1}' | sort | uniq > tmp_$target
./Module_extracts_sequences_from_fasta.pl Selected_sequences_2022_09_26.fa tmp_$target > Missed_for_$target'.fa'
blastn -db EPI_ISL_402119.fasta -query Missed_for_$target'.fa' -evalue 0.001 -word_size 12 -outfmt 6 > Blast_output_missed_$target'.txt'
edited_target=`echo $target | tr U T`
hit_start=`tail -1 Fused_EPI_ISL_402119.fasta | sed 's|'$edited_target'.*||' | wc -m`
hit_end=`tail -1 Fused_EPI_ISL_402119.fasta | sed -e 's|'$edited_target'.*|'$edited_target'|' -e 's|.$||' | wc -m` # counting end position after removing the hit's terminal nucleotide, to compensate the fact that the end of line is counted
./Module_extracts_for_alignment.pl Blast_output_missed_$target'.txt' 'BetaCoV/Wuhan/IVDC-HB-01/2019|EPI_ISL_402119' $hit_start $hit_end Missed_for_$target'.fa' Fused_EPI_ISL_402119.fasta

