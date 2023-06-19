#!/bin/bash

file=$1
sed 's|DATE|January 8, 2021|' R_commands_siRNA_ranking_template > R_commands_siRNA_ranking


for f in `ls Missed_hits_for*.fa`;do ./Module_mismatch_statistics_on_missed_variants.pl $f;done
for s in `ls Missed_hits_for*.fa | sed -e 's|Missed_hits_for_||' -e 's|\.fa$||'`
do guide_seed=`echo $s | rev | tr ACGT TGCA | cut -c 1-6`
   mapped_variants=`grep -c $s Selected_$file`
   missed_by_N=`grep -c ': N$' Mismatch_details_in_Missed_hits_for_$s'.dat'`
   missed_by_unaccepted_mismatch=`grep -c 'Unaccepted_mismatch' Mismatch_details_in_Missed_hits_for_$s'.dat'`
   total_genes=`awk '$2=="'$guide_seed'" {print $3}' Off-target_predictions.dat`
   haplo_genes=`awk '$2=="'$guide_seed'" {print $4}' Off-target_predictions.dat`
   echo $s $mapped_variants $missed_by_N $missed_by_unaccepted_mismatch $total_genes $haplo_genes
done > siRNA_candidate_ranking_data.dat
sed -e '1 s|.*|Candidate_13mer Number_of_matched_variants Number_of_mismatched_variants_because_of_N Number_of_mismatched_variants_because_of_unaccepted_mismatch Number_of_matched_human_genes Number_of_matched_haploinsufficient_human_genes\
&|' -e 's| |,|g' siRNA_candidate_ranking_data.dat > siRNA_candidate_ranking_data.csv
R CMD BATCH R_commands_siRNA_ranking
