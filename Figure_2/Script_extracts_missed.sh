#!/bin/bash

file=$1
candidate=$2

./Module_extracts_missed.pl $candidate Selected_$file > missed_$candidate'.fa'
head -2 Selected_$file >> missed_$candidate'.fa'
position=`head -2 Selected_$file | tail -1 | sed 's|'$candidate'.*||' | wc -m`
start=`echo $position"-500" | bc`
end=`echo $position"+500" | bc`
grep '>' missed_$candidate'.fa' > tmp_1_$candidate
grep -v '>' missed_$candidate'.fa' | cut -c $start-$end > tmp_2_$candidate
paste -d '\n' tmp_1_$candidate tmp_2_$candidate > extract_missed_$candidate'.fa'

if test `grep -c '^>' extract_missed_$candidate'.fa'` -lt 10000 # exclude candidates which do not perfectly match a large number of variants (their alignment would take forever, and anyway they are not the most interesting candidates)
then clustalw extract_missed_$candidate'.fa'
fi

if test -f extract_missed_$candidate'.aln' # Some candidates will be exluced here: those mapping too close to the genome's extremities to be aligned in every variant, and those whose non-matched variants were deliberately not aligned: cf above
then for id in `grep -v '^CLUSTAL 2.1 multiple sequence alignment$' extract_missed_$candidate'.aln' | grep -v '^ *$' | awk '{print $1}' | sort | uniq | grep -v '\*'`
     do seq=`awk '$1=="'$id'" {print $2}' extract_missed_$candidate'.aln' | perl -pe 's/\n//g'`
        echo $id $seq
     done > formatted_extract_missed_$candidate'.aln'
     peeled=`head -1 Selected_$file | sed 's|^> *||' | cut -c 1-30` # Because clustalw cuts sequence names after 30 characters
     for id in `awk '{print $1}' formatted_extract_missed_$candidate'.aln'`
     do if test "$id" = "$peeled"
        then echo ">REF_"$id
        else echo ">"$id
        fi
        awk '$1=="'$id'" {print $2}' formatted_extract_missed_$candidate'.aln' | cut -c `./Module_position_in_alignment.pl $peeled $candidate`	
     done > Missed_hits_for_$candidate'.fa'
fi
