#!/bin/bash
#SBATCH -n 1                    # Number of cores. For now 56 is the number max of core available
#SBATCH -N 1                    # Number of nodes. Ensure that all cores are on one machine (1max)
#SBATCH --mem-per-cpu=1000      # allocated memory
#SBATCH --partition=computepart # specify queue partiton
#SBATCH -t 7-00:00              # Runtime in D-HH:MM
#SBATCH -o slurmlog/hostname_%j.out      # File to which STDOUT will be written (! create slurmlog folder before)
#SBATCH -e slurmlog/hostname_%j.err      # File to which STDERR will be written (! create slurmlog folder before)
#SBATCH --mail-type=ALL         # Type of email notification- BEGIN,END,FAIL,ALL
#SBATCH --mail-user=herve.seitz@igh.cnrs.fr  # Email to which notifications will be sent

file=sequences_2021-01-08_08-46.fasta
sed 's|DATE|January 8, 2021|' R_commands_siRNA_ranking_template > R_commands_siRNA_ranking

bunzip2 Selected_$file'.bz2'

for f in `ls Missed_hits_for*.fa`;do ./Module_mismatch_statistics_on_missed_variants_September_2022.pl $f;done
for s in `ls Missed_hits_for*.fa | sed -e 's|Missed_hits_for_||' -e 's|\.fa$||'`
do guide_seed=`echo $s | rev | tr ACGT TGCA | cut -c 1-6`
   mapped_variants=`grep -c $s Selected_$file`
   missed_by_N=`grep -v ' Mismatch' Mismatch_details_in_Missed_hits_for_$s'.dat' | grep -c ' Ambiguity'`
   missed_by_unaccepted_mismatch=`grep -c ' Mismatch' Mismatch_details_in_Missed_hits_for_$s'.dat'`
   total_genes=`awk '$2=="'$guide_seed'" {print $3}' Off-target_predictions.dat`
   haplo_genes=`awk '$2=="'$guide_seed'" {print $4}' Off-target_predictions.dat`
   echo $s $mapped_variants $missed_by_N $missed_by_unaccepted_mismatch $total_genes $haplo_genes
done > siRNA_candidate_ranking_data_September_2022.dat
sed -e '1 s|.*|Candidate_13mer Number_of_matched_variants Number_of_mismatched_variants_only_because_of_sequence_ambiguity Number_of_mismatched_variants_because_of_unaccepted_mismatch Number_of_matched_human_genes Number_of_matched_haploinsufficient_human_genes\
&|' -e 's| |,|g' siRNA_candidate_ranking_data_September_2022.dat > siRNA_candidate_ranking_data_September_2022.csv
R CMD BATCH R_commands_siRNA_ranking_September_2022
