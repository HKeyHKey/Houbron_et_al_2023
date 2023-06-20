#!/bin/bash
#SBATCH -n 1                    # Number of cores. For now 56 is the number max of core available
#SBATCH -N 1                    # Number of nodes. Ensure that all cores are on one machine (1max)
#SBATCH --mem-per-cpu=1000      # allocated memory
#SBATCH --partition=computepart # specify queue partiton
#SBATCH -t 0-08:00              # Runtime in D-HH:MM
#SBATCH -o slurmlog/hostname_%j.out      # File to which STDOUT will be written (! create slurmlog folder before)
#SBATCH -e slurmlog/hostname_%j.err      # File to which STDERR will be written (! create slurmlog folder before)
#SBATCH --mail-type=ALL         # Type of email notification- BEGIN,END,FAIL,ALL
#SBATCH --mail-user=herve.seitz@igh.cnrs.fr  # Email to which notifications will be sent

target=$1

for f in `ls Doped_Chunk_*_For_alignment_missed_for_$target'.aln'`
do ./Module_reasons_for_missed_variant_in_September_2022.pl $f 'BetaCoV/Wuhan/IVDC-HB-01/2019|'
done
cat Missed_not_because_of_ambiguity_in_Doped_Chunk_*_For_alignment_missed_for_$target'.fa' > Missed_not_because_of_ambiguity_for_$target'.fa'
