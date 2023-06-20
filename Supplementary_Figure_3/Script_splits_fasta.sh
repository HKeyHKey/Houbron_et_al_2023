#!/bin/bash
#SBATCH -n 1                    # Number of cores. For now 56 is the number max of core available
#SBATCH -N 1                    # Number of nodes. Ensure that all cores are on one machine (1max)
#SBATCH --mem-per-cpu=100000      # allocated memory
#SBATCH --partition=computepart # specify queue partiton
#SBATCH -t 0-48:00              # Runtime in D-HH:MM
#SBATCH -o slurmlog/hostname_%j.out      # File to which STDOUT will be written (! create slurmlog folder before)
#SBATCH -e slurmlog/hostname_%j.err      # File to which STDERR will be written (! create slurmlog folder before)
#SBATCH --mail-type=ALL         # Type of email notification- BEGIN,END,FAIL,ALL
#SBATCH --mail-user=herve.seitz@igh.cnrs.fr  # Email to which notifications will be sent

input=$1
chunk_size=$2
nb_lines=`echo $chunk_size"*2" | bc`

nb=`grep -c '>' $input`
nb_chunks=`echo $nb"/("$chunk_size"-1)" | bc`
before_last=`echo $nb_chunks"-1" | bc`
for chunk in `seq 1 $before_last`
do i=`echo "("$chunk"-1)*"$chunk_size"+1" | bc`
   j=`echo "("$i"-1)*2+1" | bc`
   tail -n +$j $input | head -$nb_lines > Chunk_$chunk'_'$input
done

chunk=$nb_chunks
j=`echo $j"+"$nb_lines | bc`
tail -n +$j $input > Chunk_$chunk'_'$input

echo "Verification:"
md5sum $input
for chunk in `seq 1 $nb_chunks`
do cat Chunk_$chunk'_'$input
done | md5sum
for chunk in `seq 1 $nb_chunks`
do grep -c '>' Chunk_$chunk'_'$input
done
