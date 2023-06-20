#!/bin/bash
#SBATCH -n 1                    # Number of cores. For now 56 is the number max of core available
#SBATCH -N 1                    # Number of nodes. Ensure that all cores are on one machine (1max)
#SBATCH --mem-per-cpu=3000      # allocated memory
#SBATCH --partition=computepart # specify queue partiton
#SBATCH -t 0-48:00              # Runtime in D-HH:MM
#SBATCH -o slurmlog/hostname_%j.out      # File to which STDOUT will be written (! create slurmlog folder before)
#SBATCH -e slurmlog/hostname_%j.err      # File to which STDERR will be written (! create slurmlog folder before)
#SBATCH --mail-type=ALL         # Type of email notification- BEGIN,END,FAIL,ALL
#SBATCH --mail-user=herve.seitz@igh.cnrs.fr  # Email to which notifications will be sent

target=$1

./Module_13mers_in_2022_09_26_dataset.pl Reoriented_antisense_missed_for_$target'.fa' $target Non_human_hosts_in_2022_09_26_release.txt > Missed_reoriented_2022_09_26_for_$target'.txt'
