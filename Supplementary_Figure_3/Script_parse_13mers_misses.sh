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


#for target in GUGUCUUUAGCUA UGUCUUUAGCUAU CCAUUUGUAGUUU AUGAUGCACUCAA GUAAACAGAUUUA AAUGAUGCACUCA
#do grep ' (host: Human)$' Missed_2022_09_26_for_$target'.txt' | awk '{print $1}' | sort | uniq > tmp_$target
#done

#n=1
#for target in GUGUCUUUAGCUA UGUCUUUAGCUAU CCAUUUGUAGUUU AUGAUGCACUCAA GUAAACAGAUUUA AAUGAUGCACUCA
#do for i in `seq 1 $n`
#   do cat tmp_$target
#   done
#   n=`echo $n"*2" | bc`
#done | sort | uniq -c | awk '{print $1}' | sort -g | uniq -c

for target1 in GUGUCUUUAGCUA UGUCUUUAGCUAU CCAUUUGUAGUUU AUGAUGCACUCAA GUAAACAGAUUUA AAUGAUGCACUCA
do for target2 in UGUCUUUAGCUAU CCAUUUGUAGUUU AUGAUGCACUCAA GUAAACAGAUUUA AAUGAUGCACUCA
   do for target3 in CCAUUUGUAGUUU AUGAUGCACUCAA GUAAACAGAUUUA AAUGAUGCACUCA
      do if test $target1 != $target2 -a $target1 != $target3 -a $target3 != $target2
         then echo $target1" with "$target2" with "$target3":"
              cat tmp_$target1 tmp_$target2 tmp_$target2 tmp_$target3 tmp_$target3 tmp_$target3 tmp_$target3 | sort | uniq -c | awk '{print $1}' | sort -g | uniq -c
         fi
      done
   done
done
