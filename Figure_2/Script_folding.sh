#!/bin/bash
#SBATCH -n 1                    # Number of cores. For now 56 is the number max of core available
#SBATCH -N 1                    # Number of nodes. Ensure that all cores are on one machine (1max)
#SBATCH --mem-per-cpu=1000      # allocated memory
#SBATCH --partition=computepart # specify queue partiton
#SBATCH -t 0-48:00              # Runtime in D-HH:MM
#SBATCH -o slurmlog/hostname_%j.out      # File to which STDOUT will be written (! create slurmlog folder before)
#SBATCH -e slurmlog/hostname_%j.err      # File to which STDERR will be written (! create slurmlog folder before)
#SBATCH --mail-type=ALL         # Type of email notification- BEGIN,END,FAIL,ALL
#SBATCH --mail-user=herve.seitz@igh.cnrs.fr  # Email to which notifications will be sent

if test "$2" = ""
then echo "Please enter script arguments (e.g., ./Script_folding.sh EPI_ISL_402119.fasta ORF_coordinates_in_EPI_ISL_402119.txt). Must be a fasta file whose sequences fit on a single line each; and a text file (named 'ORF_coordinates_in_*.txt, with sequence name instead of the asterisk) containing Start and End positions for ORF's (sorted in increasing position order)."
     exit
fi


f=$1
cat $f | RNAfold -p
./Module_extract_pairing_proba.pl $f
./Module_substructure_folding.pl $f
ORF_coord=$2
nb_ORFs=`grep -v '^#' $ORF_coord | grep -vc '^Start End$'`
bp=1
for i in `seq 1 $nb_ORFs`
do start=`grep -v '^#' $ORF_coord | grep -v '^Start End$' | head -$i | tail -1 | awk '{print $1}'`
   end=`grep -v '^#' $ORF_coord | grep -v '^Start End$' | head -$i | tail -1 | awk '{print $2}'`
   last_position=`echo $start"-1" | bc`
   echo ">ORF_"$i > tmp_ORF_$i'.fa'
   if test $bp -le $last_position # it won't always be the case (ORFs NS7a and NS7b overlap by a few nucleotides)
   then for position in `seq $bp $last_position`
        do echo $position NA
        done
   else start=$bp
   fi
   tail -1 $1 | cut -c $start-$end >> tmp_ORF_$i'.fa'
   cat tmp_ORF_$i'.fa' | RNAfold -p > folding_output_$i'.txt'
   ./Module_extract_pairing_proba.pl tmp_ORF_$i'.fa'
   awk '{print $1+'$start'-1,$2}' Full_folding_pairing_proba_in_ORF_$i'_from_tmp_ORF_'$i'.dat'
   bp=`echo $end"+1" | bc`
done > ORF_folding_along_`echo $2 | sed -e 's|ORF_coordinates_in_||' -e 's|\.txt$||'`.dat
seq_length=`tail -1 $1 | wc -m`
seq_length=`echo $seq_length"-1" | bc`
for position in `seq $bp $seq_length`
do echo $position NA
done >> ORF_folding_along_`echo $2 | sed -e 's|ORF_coordinates_in_||' -e 's|\.txt$||'`.dat
