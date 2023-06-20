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

for target in GUGUCUUUAGCUA UGUCUUUAGCUAU CCAUUUGUAGUUU AUGAUGCACUCAA GUAAACAGAUUUA AAUGAUGCACUCA
do grep '^>' Missed_not_because_of_ambiguity_for_$target'.fa' | sed 's|^> *||'
done | sort | uniq > tmp_missed
echo "Variant Missed_13mer_targets" > Summary_missed_targets.txt
for id in `cat tmp_missed`
do missed_targets=`grep '^> *'$id'$' Missed_not_because_of_ambiguity_for_*.fa | sed -e 's|Missed_not_because_of_ambiguity_for_||' -e 's|\.fa:>.*||'`
   echo $id $missed_targets >> Summary_missed_targets.txt
done
