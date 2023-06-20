#!/bin/sh

./Module_variant_selection_RAM_savvy.pl sequences.fasta > Selected_sequences_2022_09_26.fa # be careful: contains sequences from non-human hosts!
grep '^>' Selected_sequences_2022_09_26.fa | sed -e 's|^> *||' -e 's/|.*//' | sort | uniq > tmp_selected
grep -c '>' sequences.fasta
grep -c '>' Selected_sequences_2022_09_26.fa
grep -v '^Virus_name Host$' Non_human_hosts_in_2022_09_26_release.txt | awk '{print $1}' | sort | uniq > tmp_non_human
echo "Counting selected sequences from human and non-human hosts (flag=1: selected variants from human donor; flag=2: unselected (because of too many N's or too short sequence) variants from non-human donor; flag=3: selected variants from non-human donor):"
cat tmp_selected tmp_non_human tmp_non_human | sort | uniq -c | awk '{print $1}' | sort -g | uniq -c
