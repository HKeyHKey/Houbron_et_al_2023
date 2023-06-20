#!/bin/sh

if [ ! -f Fused_EPI_ISL_402119.fasta ]
then echo "I could not find file 'Fused_EPI_ISL_402119.fasta'. I need it: please copy it in the current directory."
     exit
fi
     

if test "$1" = ""
then echo "Please enter target 13-mer (i.e.: reverse-complement of guide nt 2-14; e.g., AGAACUUUAAGUC)."
     read target
else target=$1
fi

target=`echo $target | tr U T`

ref=`grep -o ".\{"1000"\}"$target".\{"1000"\}" Fused_EPI_ISL_402119.fasta`
ref_position='centered'
if test "$ref" = ""
then ref=`grep -o ".\{"10"\}"$target".\{"1990"\}" Fused_EPI_ISL_402119.fasta`
     ref_position='left'
fi
if test "$ref" = ""
then ref=`grep -o ".\{"1990"\}"$target".\{"10"\}" Fused_EPI_ISL_402119.fasta`
     ref_position='right'
fi
if test "$ref" = ""
then echo "Could not extract sequence context for "$target" in Fused_EPI_ISL_402119.fasta: please check what is wrong."
     exit
fi


for lineage in Alpha Beta Delta Gamma Lambda Mu Omicron
do for seq in `grep -v '^>' Selected_Extracted_sequences_$lineage'.fa' | grep -v $target`
   do grep -B 1 '^'$seq'$' Selected_Extracted_sequences_$lineage'.fa'
   done > Missed_$target'_in_'$lineage'.fa'
   echo ">ref" > tmp_for_align_$target'_'$lineage'.fa'
   echo $ref >> tmp_for_align_$target'_'$lineage'.fa'
   cat Missed_$target'_in_'$lineage'.fa' >> tmp_for_align_$target'_'$lineage'.fa'
   clustalw tmp_for_align_$target'_'$lineage'.fa' > /dev/null
   for id in `grep -v '^CLUSTAL' tmp_for_align_$target'_'$lineage'.aln' | awk '{print $1}' | sort | uniq | grep -v '^\**$'`
   do echo ">"$id
      awk '$1=="'$id'" {print $2}' tmp_for_align_$target'_'$lineage'.aln' | perl -pe 's/\n//g'
      echo ""
   done > tmp_aligned_$target'_'$lineage'.fa'
   start=`grep -A 1 '^>ref$' tmp_aligned_$target'_'$lineage'.fa' | tail -1 | sed 's|[ACGT].*||' | wc -m`
   case "$ref_position" in "centered") offset=1000;;
			   "left") offset=10;;
			   "right") offset=1990;;
   esac
   start_13mer=`echo $start"+"$offset | bc`
   end_13mer=`echo $start_13mer"+12" | bc`
   grep '^>' tmp_aligned_$target'_'$lineage'.fa' > tmp_headers
   grep -v '^>' tmp_aligned_$target'_'$lineage'.fa' | cut -c $start_13mer-$end_13mer > tmp_seq
   echo " *** In lineage "$lineage": ***"
   paste -d "\n" tmp_headers tmp_seq
   echo ""
done
